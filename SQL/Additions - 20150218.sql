DELIMITER $$
DROP VIEW IF EXISTS roomfeaturesvw $$

CREATE VIEW roomfeaturesvw AS 
select RoomID AS RoomID
,BedType AS Bed_FeatureID
,0 AS ProximityID
,count(RoomID) AS Qty 
from room_beds 
group by RoomID,BedType 
union 
select r.RoomID AS RoomID
,bwf.FeatureID AS Bed_FeatureID
,bwf.ProximityID AS ProximityID
,1 AS Qty 
from 
room r 
join building_wing_features bwf on bwf.BuildingID = r.BuildingID and bwf.WingID = r.WingID
;$$


/***************************************************************************************************************************************/
DROP VIEW IF EXISTS ResFeaturesVw $$

CREATE VIEW ResFeaturesVw AS
select ReservationID, BedFeatureID as Bed_FeatureID, ProximityID, count(ReservationID) as Qty from res_features group by ReservationID, BedFeatureID, ProximityID
Union
select 
r.RoomID, bwf.FeatureID as Bed_FeatureID, bwf.ProximityID, 1 as Qty
from room r
join BUILDING_WING_FEATURES bwf on bwf.BuildingID=r.BuildingID and bwf.WingID=r.WingID 

Order by RoomID;
$$

 
DROP VIEW IF EXISTS ReservationInfoVw $$

CREATE VIEW ReservationInfoVw AS
SELECT 
r.ReservationID
,r.ParentResID
,r.BillToID
,c.FirstName as BillToFirstName
,c.LastName  as BillToLastName
, r.GuestID
, c2.FirstName as GuestFirstName
, c2.LastName as GuestLastName
, r.EventID
, e.EventName
, e.HostID
, c3.FirstName as HostFirstName
, c3.LastName as HostLastName
, r.RoomType
, rt.Name as RoomTypeName
, r.StartDate
, r.EndDate
, r.Rate
, r.Deposit
, r.RoomID
, r.Smoking
, r.ConvertedToStay

, GROUP_CONCAT(concat(rf.Bed_FeatureID,',',rf.ProximityID) SEPARATOR'|')  as Features
, GROUP_CONCAT(case rf.qty when 1 then tn.Name else concat(rf.qty,'-', tn.Name,'s') end order by rf.Bed_FeatureID) as Feature_Description

FROM RESERVATION r
JOIN ResFeaturesVw rf on rf.ReservationID=r.ReservationID
JOIN TYPE_NAME tn on rf.Bed_FeatureID=TypeNameID
JOIN CUSTOMER c on c.CustomerID=r.BillToID
Left Outer Join CUSTOMER c2 on c2.CustomerID=r.GuestID
LEFT Outer Join `EVENT` e on e.EventID=r.EventID
LEFT OUTER JOIN CUSTOMER c3 on c3.CustomerID=e.HostID
JOIN TYPE_NAME rt on rt.TypeNameID=r.RoomType

WHERE R.ConvertedToStay = 0
and r.EndDate >= NOW()
group by r.ReservationID

;
$$ 

/*************************************************************************************************************************************/
DROP VIEW IF EXISTS `StayInfoVw` $$

CREATE VIEW `StayInfoVw` AS
SELECT 
s.StayID
,s.BillToID
,c.FirstName as BillToFirstName
,c.LastName  as BillToLastName
, s.GuestID
, c2.FirstName as GuestFirstName
, c2.LastName as GuestLastName
, s.EventID
, e.EventName
, e.HostID
, c3.FirstName as HostFirstName
, c3.LastName as HostLastName
, s.ReservationID
, r.Rate	ReservationRate
, rm.Rate	RoomRate
, s.RoomID
, room.RoomNumber
, s.RoomType
, rt.Name as RoomTypeName
, s.CheckIn
, s.AnticipatedCheckOut
, s.CheckOut

, GROUP_CONCAT(concat(rf.Bed_FeatureID,',',rf.ProximityID) SEPARATOR'|')  as Features
, GROUP_CONCAT(case rf.qty when 1 then tn.Name else concat(rf.qty,'-', tn.Name,'s') end order by rf.Bed_FeatureID) as Feature_Description

FROM STAY s
JOIN RoomFeaturesVw rf on rf.RoomID=s.RoomID
JOIN TYPE_NAME tn on rf.Bed_FeatureID=TypeNameID
JOIN CUSTOMER c on c.CustomerID=s.BillToID
Left Outer Join CUSTOMER c2 on c2.CustomerID=s.GuestID
LEFT Outer Join `EVENT` e on e.EventID=s.EventID
LEFT OUTER JOIN CUSTOMER c3 on c3.CustomerID=e.HostID
LEFT OUTER JOIN RESERVATION r on r.ReservationID=s.ReservationID
JOIN TYPE_NAME rt on rt.TypeNameID=s.RoomType
JOIN ROOM_DETAIL rm on rm.RoomID=s.RoomID and rm.RoomType=s.RoomType
join ROOM  on room.RoomID=s.RoomID

WHERE IFNULL(s.Checkout,NOW()) >= DATE_ADD(NOW(), INTERVAL -14 DAY)
group by s.StayID;$$ 


 /*******************************************************************************************************************************************/
DROP PROCEDURE IF EXISTS `GetAvailablityByFeaturesSp`; $$

CREATE PROCEDURE `GetAvailablityByFeaturesSp` (
pStartDate 	DATETIME
, pEndDATE	DateTime
)
BEGIN
DECLARE cReservationID, cRoomType, cSmoking, BREAK, cExampleRoom, i int default 0;
DECLARE cRate		dec(12,2) default 0;

#MY SQL is so poor that you have to declare all before you process anything!!!!!!!
DECLARE reservation_cur CURSOR FOR
	select ReservationID , RoomType , Rate , Smoking
		FROM RESERVATION 
       where ROOMID IS NULL AND ConvertedToStay=0
       and (StartDate Between pStartDate and pEndDate or EndDate Between pStartDate and pEndDate);
       

DECLARE CONTINUE HANDLER FOR NOT FOUND SET BREAK= 1; #HANDLER FOR CURSOR AND SELECT INTO

#FIRST LOAD ALL THE AVAILABLE ROOMS
DROP TABLE IF EXISTS tmp_reservationmap;
CREATE TEMPORARY TABLE tmp_reservationmap (RoomsAvailable Int, SmokingAllowed Int, Beds VARCHAR(100), Rate DEC(12,2), Features Varchar(255), RoomRank INT, RoomFeatures Varchar(100), ExampleRoom int, RoomsReserved Int);

INSERT INTO tmp_reservationmap
SELECT 
	COUNT(sri.RoomID) as RoomsAvailable
	, SmokingAllowed
	, LTRIM(RTRIM(Beds)) AS BEDS
	, Rate
	, Features
	, RoomRank
	, Concat(BedTypes, ',',FeatureIDs) RoomFeatures
    , MIN(sri.RoomID) EXAMPLEROOM
	, 0
	from SleepRoomInfoVw sri
	left outer join RoomsBookedVw bk on bk.RoomId=sri.RoomID and (bk.StartDate Between pStartDate and pEndDate or bk.EndDate Between pStartDate and pEndDate)
	WHERE bk.RoomID is null
       
	Group by SmokingAllowed, sri.Beds, Features, RoomRank, Rate, BedTypes, FeatureIDs;
	#ORDER BY RATE#

#find a list of room types that the reservations will not work with
DROP TABLE IF EXISTS tmp_NonMatchingResRoom;
CREATE TEMPORARY TABLE tmp_NonMatchingResRoom (EXAMPLEROOM INT, RESERVATIONID INT);

INSERT INTO tmp_NonMatchingResRoom
select 
distinct
rm.ExampleRoom 
, rfw.ReservationID

from tmp_reservationmap rm
join ResFeaturesVW rfw
join Reservation r on r.ReservationID=rfw.ReservationID 
left outer join RoomFeaturesVw rfv on rm.ExampleRoom = rfv.RoomID and rfw.Bed_FeatureID=rfv.Bed_FeatureID and rfw.ProximityID<=rfv.ProximityID and rfw.Qty<=rfv.Qty

where rfv.RoomID is null
and r.ROOMID IS NULL AND ConvertedToStay=0 and (r.StartDate Between pStartDate and pEndDate or r.EndDate Between pStartDate and pEndDate)
;


#start working through the cursor
set BREAK=0;

OPEN reservation_cur;

get_reservation: LOOP
	
    fetch reservation_cur INTO cReservationId, cRoomType, cRate, cSmoking;
	
	IF break = 1 THEN LEAVE get_reservation; END IF;
     
	set i=i+1; #loop counter
    
    
	 Select 
    COALESCE(rm.EXAMPLEROOM,0) into cExampleRoom
     FROM tmp_reservationmap rm
     LEFT OUTER JOIN tmp_NonMatchingResRoom nmr on nmr.EXAMPLEROOM=rm.ExampleRoom and nmr.ReservationID=cReservationID
     WHERE nmr.EXAMPLEROOM is null
     and RoomsReserved<RoomsAvailable
     and SmokingAllowed = cSmoking
     ORDER BY ifnull(Rate,0), ifnull(RoomRank,0) LIMIT 1;
     
		IF BREAK=1 THEN SET BREAK= 0; END IF;  #IF NO MATCHING ROWS ARE FOUND IN THE SELECT INTO
   
    
     UPDATE tmp_reservationmap set RoomsReserved=RoomsReserved+1 where ExampleRoom=cExampleRoom;
     

END LOOP get_reservation;
CLOSE reservation_cur;

select * from tmp_reservationmap order by Rate, RoomRank;

#select i;
END;
$$


DROP PROCEDURE IF EXISTS `CaldStayBalanceSp`; $$

CREATE PROCEDURE `CaldStayBalanceSp` (
pStayID		Int
, pCustomerID Int )

BEGIN
 DECLARE BALANCE DEC(12,2);
 
 SELECT SUM(AMOUNT) into BALANCE FROM STAY_CHARGES WHERE StayID=pStayID and ChargeTo=pCustomerID;
 
 IF BALANCE = 0 THEN
	UPDATE STAY_CHARGES SET PaidDate = NOW();
END IF;

END;$$


/*************************************************************************************************************************************/

DROP PROCEDURE IF EXISTS `MakePaymentSp`; $$

CREATE PROCEDURE `MakePaymentSp` (
pStayID		Int
, pCustomerID Int
, pAmount	DEC(12,2)
, pPaymentType Int
)
Begin
if (pStayID is not null and pCustomerID is not null )then
   begin

		if IFNULL(pPaymentType,0) =0 THEN
			SELECT TypeNameID into pPaymentType from Type_Name where UsageID = 'ChargeType' and Name = 'Payment';
		end if;


   INSERT INTO STAY_CHARGES(STAYID, ChargeTo, ChargeType, Amount, ChargeDate, DueDate, PaidDate) 
		values (StayId, pCustomerID, pPaymentType,-1*pAmount, Now(), Now(), Now());
    
   
   CALL CalStayBalanceSp(pStayID, pCustomerID); #IF ZERO, CLOSES THE CHARGES
    end;
end if; 

End;$$


/*************************************************************************************************************************************/

DROP PROCEDURE IF EXISTS `GenerateCleaningRequestSp`; $$

CREATE PROCEDURE `GenerateCleaningRequestSp` (
pRoomID int )
BEGIN
    
    insert into MAINTENANCE_TICKET(RoomID, StartDate, AnticipatedEndDate, MaintenanceType) Values(pRoomID, Now(), ADDTIME(CONVERT(curdate(),DATETIME),'0 15:00:00.0'), (SELECT TASKNAMEID from TASK_NAME WHERE UsageID='MaintenanceType' and Name='Cleaning'));

END;$$


/*************************************************************************************************************************************/

DROP PROCEDURE IF EXISTS `CheckOutSp`; $$

CREATE PROCEDURE `CheckOutSp` (
pStayID int )
BEGIN
DECLARE vROOMID INT;

	SELECT RoomID into vROOMID from STAY WHERE STAYID=pStayID;
	UPDATE STAY SET CheckOut=NOW() WHERE StayID=pStayID;
    
    CALL GenerateCleaningRequestSp(vROOMID);

END;$$

*************************************************************************************************************************************/

DROP PROCEDURE IF EXISTS `ReassignRoomSp`; $$

CREATE PROCEDURE `ReassignRoomSp` (
pOldStayID	int
,pNewRoomID int
,pNewRate 	int)
COMMENT 'CLOSES OUT CURRENT ROOM, COPIES INFO TO NEW ROOM, AND CHARGES'

BEGIN
DECLARE vBillToID, vGuestID, vReservationID, vEventID, vRoomType, vNewStayID, vRoomCharges, vBalanceTransfer INT;
DECLARE vAnticipatedCheckOut DATETIME;
DECLARE vBALANCE, vDeposit DEC(12,2) default 0;

SELECT TypeNameID into vRoomCharges from Type_Name where UsageID = 'ChargeType' and Name = 'Room Charges';
SELECT TypeNameID into vBalanceTransfer from Type_Name where UsageID = 'ChargeType' and Name = 'Balance Transfer';


# First set up a new stay with the new room, deposit is zero as we will copy those over
    Select BillToID, GuestID, ReservationID, EventID, RoomType, AnticipatedCheckOut, IFNULL(pNewRate,ReservationRate) INTO
    vBillToID, vGuestID, vReservationID, vEventID, vRoomType, vAnticipatedCheckOut, pNewRate
    FROM STAYINFOVW WHERE STAYID=pOldStayID;
    
    CALL InsertStaySp(vBillToID, vGuestID, vReservationID, vEventID, pNewRoom, vRoomType, vAnticipatedCheckOut, pNewRate, 0);
	SELECT LAST_INSERT_ID() into vNewStayID;
   
   
   
    #move charges from last room to this room BILLTO first and then GUEST --do not include today's room charge as it would be duplicated
    SELECT SUM(AMOUNT) INTO vBALANCE FROM STAY_CHARGES WHERE StayID=pOldStayID and ChargeTo=vBillToID and not(ChargeType=vRoomCharges and ChargeDate=CURDATE());
    IF IFNULL(vBALANCE,0)<>0 THEN
    INSERT INTO STAY_CHARGES(STAYID, ChargeTo, ChargeType, Amount, ChargeDate, DueDate) 
        values (vNewStayId, vBillToID, vBalanceTransfer,vBALANCE, CURDATE(), vAnticipatedCheckOut);
	END IF;

	#CREDIT THE ENTIRE BALANCE OF THE ROOM FOR THE BILLTO
 SELECT SUM(AMOUNT) INTO vBALANCE FROM STAY_CHARGES WHERE StayID=pOldStayID and ChargeTo=vBillToID ;
    IF IFNULL(vBALANCE,0)<>0 THEN
    INSERT INTO STAY_CHARGES(STAYID, ChargeTo, ChargeType, Amount, ChargeDate, DueDate, PaidDate) 
        values (pOldStayId, vBillToID, vBalanceTransfer,-1*vBALANCE, CURDATE(), vAnticipatedCheckOut, NOW());
	END IF;
 
	#Move the balance of the Guest
 SELECT SUM(AMOUNT) INTO vBALANCE FROM STAY_CHARGES WHERE StayID=pOldStayID and ChargeTo=vGuestID ;
    IF IFNULL(vBALANCE,0)<>0 THEN
    begin
    #create new
    INSERT INTO STAY_CHARGES(STAYID, ChargeTo, ChargeType, Amount, ChargeDate, DueDate) 
        values (vNewStayId, vGuestID, vBalanceTransfer,-vBALANCE, CURDATE(), vAnticipatedCheckOut);
	#close out old
	 INSERT INTO STAY_CHARGES(STAYID, ChargeTo, ChargeType, Amount, ChargeDate, DueDate, PaidDate) 
        values (pOldStayId, vGuestID, vBalanceTransfer,-1*vBALANCE, CURDATE(), vAnticipatedCheckOut, NOW());
	end;
	END IF;
 
	CALL CHECKOUTSP(pOldStayID);
	CALL CalStayBalanceSp(pOldStayId, vGuestID);
    CALL CalStayBalanceSp(pOldStayId, vBillToID);
 
 
END;$$




DROP VIEW IF EXISTS `StayChargesVw` $$

CREATE VIEW `StayChargesVw` AS
SELECT 
sc.StayID
, s.RoomID
, rm.RoomNumber
, sc.ChargeTo
, c.FirstName 
, c.LastName
, sc.ChargeType
, ct.Name as ChargeDesc
, sc.ChargeDescription
, sc.Amount
, sc.ChargeDate
, sc.DueDate
, sc.PaidDate

from STAY_CHARGES sc
join TYPE_NAME ct on ct.TypeNameID=sc.ChargeType
join STAY s on s.StayID-sc.StayID
join ROOM rm on rm.RoomID=s.RoomID
JOIN CUSTOMER c on c.CustomerID=sc.ChargeTo

WHERE IFNULL(s.Checkout,NOW()) >= DATE_ADD(NOW(), INTERVAL -14 DAY) 
#COMMENT 'USED TO SUMMARIZE CHARGES WITHOUT CREATING JOINS IN THE UI'
;$$

/************************************************************************************/
DROP VIEW IF EXISTS `OpenMaintTicketsVw` $$

CREATE VIEW `OpenMaintTicketsVw` AS

SELECT 
mt.MaintTicketID
, mt.RoomID
, r.RoomNumber
, mt.StartDate
, mt.AnticipatedEndDate
, mt.MaintenanceType
, tn.Name as MaintTypeDesc
, mt.TaskDescription
FROM MAINTENANCE_TICKET mt
JOIN ROOM r  on r.RoomID=mt.RoomID
join Type_Name tn on tn.TypeNameID=mt.MaintenanceType
where EndDate is null;$$


/*************************************************************************************************************************************/

DROP PROCEDURE IF EXISTS `UpdateMaintTicketSp`; $$

CREATE PROCEDURE `UpdateMaintTicketSp` (
pMaintTicketID  INT
, pMaintenaceDate	DATETIME
, pEMPLOYEEID	INT
, pNOTES		VARCHAR(255)
, pCloseTicket	INT)
COMMENT 'simple procedure that adds logs and can close a maintenance ticket (close ticket=1'
BEGIN
	INSERT INTO MAINTENANCE_LOG (MaintTicketID, MaintenanceDate, EmployeeID, Notes) Values(pMaintTicketID, pMaintenanceDate, pEmployeeID, pNotes);
    
    if pCloseTicket = 1 then
		UPDATE MAINTENANCE_TICKET SET EndDAte = pMaintenanceDate where MaintTicketID=pMaintTicketID and pMaintenanceDate>StartDate;
	end if;
END;$$

DELIMITER ;