delimiter $$
DROP VIEW IF EXISTS SuiteBedsVw $$

CREATE VIEW SuiteBedsVw AS

select 
r.ParentRoomID as RoomID
, rb.BedType
, rb.BedSequence
from room r
join room pr on pr.roomid=r.ParentRoomID
join room_detail rd on rd.roomid=pr.roomid and rd.RoomType in (Select TypeNameID from Type_Name where UsageID='RoomType' and Name = 'Suite')
join room_beds rb on rb.RoomID=r.RoomID

UNION

SELECT
r.RoomID
, rb.BedType
, rb.BedSequence
from room r
join room_detail rd on rd.roomid=r.roomid and rd.RoomType in (Select TypeNameID from Type_Name where UsageID='RoomType' and Name = 'Suite')
join room_beds rb on rb.RoomID=r.RoomID;

$$
/*****************************************************************************************************************************************/
DROP VIEW IF EXISTS SuiteBedsSummaryVw $$

CREATE VIEW SuiteBedsSummaryVw AS
SELECT 
sb.RoomID
, COUNT(sb.BedSequence) as Qty
, MIN(sb.BedSequence) as BedSequence
, sb.BedType
from SuiteBedsVw sb group by sb.RoomID, sb.BedType; $$

/*****************************************************************************************************************************************/


DROP VIEW IF EXISTS SuiteRoomInfoVw $$
 
CREATE VIEW SuiteRoomInfoVw AS
Select
  r.RoomID
, r.RoomNumber
, b.Name as BuildingName
, w.Name as WingName
, r.Floor as FloorNumber
, case when wf.SmokingProhibited = 1 then 0 when rd.PermitSmoking = 0 then 0 else 1 end as SmokingAllowed
, GROUP_CONCAT(concat(rb.Qty, '-',bd.Name) order by rb.BedType) as Beds
, GROUP_CONCAT(distinct rb.BedType order by rb.BedSequence) as BedTypes
, bwf.Features
, bwf.FeatureIds
, bwf.FeatureRank+ sum(bd.UsageRank) as RoomRank
, rd.Rate
, rd.Capacity
from room r
join Type_Name b on b.TypeNameID = r.BuildingID
join Type_Name w on w.TypeNameID = r.WingID
join WING_FLOOR wf on wf.BuildingId = r.BuildingID and wf.WingId=r.WingID and wf.FloorNumber=r.Floor
join BuildWingFeatVw bwf on bwf.BuildingID=r.BuildingId and bwf.WingId=r.WingId
join ROOM_DETAIL rd on r.RoomID=rd.RoomID and RoomType in (Select TypeNameID from Type_Name where UsageID='RoomType' and Name = 'Suite')
join SuiteBedsSummaryVw  rb on rb.RoomID=r.RoomId
JOIN Type_Name bd on bd.TypeNameID=rb.BedType

 group by r.RoomID ;$$
 
 /**************************************************************************************************************************************/
 DROP VIEW IF EXISTS SleepBedsSummaryVw $$

CREATE VIEW SleepBedsSummaryVw AS
SELECT 
sb.RoomID
, COUNT(sb.BedSequence) as Qty
, MIN(sb.BedSequence) as BedSequence
, sb.BedType
from room_beds sb group by sb.RoomID, sb.BedType; $$

/****************************************************************************************************************************************/
DROP VIEW IF EXISTS SleepRoomInfoVw $$

CREATE VIEW SleepRoomInfoVw AS

Select
  r.RoomID
, r.RoomNumber
, b.Name as BuildingName
, w.Name as WingName
, r.Floor as FloorNumber
, case when wf.SmokingProhibited = 1 then 0 when rd.PermitSmoking = 0 then 0 else 1 end as SmokingAllowed
, GROUP_CONCAT(concat(rb.Qty, '-',bd.Name) order by rb.BedType) as Beds
, GROUP_CONCAT(rb.BedType order by rb.BedSequence) as BedTypes
, bwf.Features
, bwf.FeatureIds
, bwf.FeatureRank+ sum(bd.UsageRank) as RoomRank
, rd.Rate
, rd.Capacity
from room r
join Type_Name b on b.TypeNameID = r.BuildingID
join Type_Name w on w.TypeNameID = r.WingID
join WING_FLOOR wf on wf.BuildingId = r.BuildingID and wf.WingId=r.WingID and wf.FloorNumber=r.Floor
join BuildWingFeatVw bwf on bwf.BuildingID=r.BuildingId and bwf.WingId=r.WingId

join ROOM_DETAIL rd on r.RoomID=rd.RoomID and RoomType in (Select TypeNameID from Type_Name where UsageID='RoomType' and Name = 'Sleeping')
JOIN SleepBedsSummaryVw rb on rb.RoomID=r.RoomID
JOIN Type_Name bd on bd.TypeNameID=rb.BedType

group by r.RoomID
; $$

/****************************************************************************************************************************************/
DROP VIEW IF EXISTS MeetingRoomInfoVw $$

CREATE VIEW MeetingRoomInfoVw AS
Select
  r.RoomID
, r.RoomNumber
, b.Name as BuildingName
, w.Name as WingName
, r.Floor as FloorNumber
, case when wf.SmokingProhibited = 1 then 0 when rd.PermitSmoking = 0 then 0 else 1 end as SmokingAllowed
, GROUP_CONCAT(concat(rb.Qty, '-',bd.Name) order by rb.BedType) as Beds
, GROUP_CONCAT(rb.BedType order by rb.BedSequence) as BedTypes
, bwf.Features
, bwf.FeatureIds
, bwf.FeatureRank+ sum(bd.UsageRank) as RoomRank
, rd.Rate
, rd.Capacity
from room r
join Type_Name b on b.TypeNameID = r.BuildingID
join Type_Name w on w.TypeNameID = r.WingID
join WING_FLOOR wf on wf.BuildingId = r.BuildingID and wf.WingId=r.WingID and wf.FloorNumber=r.Floor
join BuildWingFeatVw bwf on bwf.BuildingID=r.BuildingId and bwf.WingId=r.WingId
join ROOM_DETAIL rd on r.RoomID=rd.RoomID and RoomType in (Select TypeNameID from Type_Name where UsageID='RoomType' and Name = 'Meeting')
JOIN SleepBedsSummaryVw rb on rb.RoomID=r.RoomID
JOIN Type_Name bd on bd.TypeNameID=rb.BedType

group by r.RoomID;

$$

/*************************************************************************************************************************************************/

DROP VIEW IF EXISTS RoomsBookedVw $$

CREATE VIEW RoomsBookedVw AS
select   RoomID, CheckIn  AS StartDate, AnticipatedCheckOut AS EndDate
from STAY
WHERE CheckOut is null

UNION
#BOOK PARENT ROOMS WHEN CHILD IS CHECK OUT
select   DISTINCT ParentRoomID as RoomID, CheckIn  AS StartDate, AnticipatedCheckOut AS EndDate
from STAY s
join room r on r.ROOMID=s.RoomID
WHERE CheckOut is null and r.ParentRoomID is not null

UNION
#BOOK CHILDREN WHEN PARENT IS CHECK OUT
SELECT r.RoomID, CheckIn  AS StartDate, AnticipatedCheckOut AS EndDate
from STAY s
join room r on r.ParentRoomID=s.RoomID
WHERE CheckOut is null

UNION
# RESERVATIONS
SELECT RoomID, StartDate, EndDate
from RESERVATION
WHERE RoomID is not null and IFNULL(ConvertedToStay,0) = 0

UNION
#BOOK PARENT ROOMS WHEN CHILD IS RESERVED
SELECT DISTINCT r.ParentRoomID as RoomID, StartDate, EndDate
from RESERVATION res
JOIN ROOM r on r.RoomID=res.RoomID
WHERE r.ParentRoomID is not null and IFNULL(ConvertedToStay,0) = 0

UNION
#BOOK CHILDREN ROOMS WHEN PARENT IS RESERVED
SELECT DISTINCT r.RoomID, StartDate, EndDate
from RESERVATION res
JOIN ROOM r on r.ParentRoomID=res.RoomID
WHERE r.ParentRoomID is not null and IFNULL(ConvertedToStay,0) = 0


###MAINTENANCE
UNION
SELECT ROOMID, StartDate, AnticipatedEndDate
from MAINTENANCE_TICKET
WHERE EndDate is NULL

UNION
#BOOK PARENT ROOMS WHEN CHILD IS IN MAINT
SELECT   R.PARENTROOMID AS ROOMID, mt.StartDate, mt.AnticipatedEndDate
from MAINTENANCE_TICKET mt
JOIN ROOM R ON R.ROOMID=MT.ROOMID
WHERE EndDate is NULL

UNION
#BOOK CHILD WHEN PARENT IS IN MAINT
SELECT  R.ROOMID, mt.StartDate, mt.AnticipatedEndDate
from MAINTENANCE_TICKET mt
JOIN ROOM R ON R.PARENTROOMID=MT.ROOMID
WHERE EndDate is NULL
; $$

/********************************************************************************************************************************/

DROP VIEW IF EXISTS ReservationInfoVw $$

CREATE VIEW ReservationInfoVw AS
SELECT 
r.ReservationID
,r.ParentResID
,r.BillToID
,c.FirstName as BillToFirstName
,c.LastName  as BillToLastName
,a1.Address1 as BillToAddress1
,a1.Address2 as BillToAddress2
,a1.City     as BillToCity
,a1.State    as BillToState
,a1.Zip      as BillToZip
,a1.Country  as BillToCountry
,p1.PhoneNum as BillToPhone
, r.GuestID
, IFNULL(c2.FirstName, c.FirstName) as GuestFirstName
, IFNULL(c2.LastName, C.LastName) as GuestLastName
, a2.Address1  as GuestAddress1
, a2.Address2  as GuestAddress2
, a2.City      as GuestCity
, a2.State     as GuestState
, a2.Zip       as GuestZip
, a2.Country   as GuestCountry
, p2.PhoneNum  as GuestPhone
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
JOIN ADDRESS a1 on r.BillToID = a1.CustomerID and a1.AddressSeq = 0
JOIN PHONE p1 on r.BillToID=p1.CustomerID and p1.PhoneNumSeq =0

Left Outer Join CUSTOMER c2 on c2.CustomerID=r.GuestID
LEFT Outer Join `EVENT` e on e.EventID=r.EventID
LEFT OUTER JOIN CUSTOMER c3 on c3.CustomerID=e.HostID
JOIN ADDRESS a2 on r.GuestID = a2.CustomerID and a2.AddressSeq = 0
JOIN PHONE p2 on r.GuestID=p2.CustomerID and p2.PhoneNumSeq =0

JOIN TYPE_NAME rt on rt.TypeNameID=r.RoomType



WHERE R.ConvertedToStay = 0
and r.EndDate >= NOW()
group by r.ReservationID;

$$

/**************************************************************************************************************************/




DROP PROCEDURE IF EXISTS `GetAvailableRoomsSp`; $$

CREATE PROCEDURE `GetAvailableRoomsSp` (

pStartDate		DateTime
,pEndDate		DateTime
, pRoomType		INT
, pSmoking		INT
, pRequirements	Varchar(255))
Begin
  
   #start by parsing the pRequirements into a temp table (wanted to use an table defined function, but  . . . .)
  	DECLARE PrevDel INT Default 1;
	DECLARE NextDel INT Default 1;
    DECLARE i		INT DEFAULT 0;
	DECLARE str CHAR(5);

DROP TABLE IF EXISTS tmp_FEATURES;
CREATE TEMPORARY TABLE  tmp_FEATURES ( FeatureSequence	Int	, Bed_FeatureID		Int	, ProximityID		Int);
DROP TABLE IF EXISTS tmp_unmachedrooms;
CREATE TEMPORARY TABLE tmp_unmachedrooms(RoomID INT);

if length(ifnull(pRequirements,''))>3 then
BEGIN
    
	parse_loop: LOOP
		Set NextDel = Locate('|',pRequirements,PrevDel);
		if NextDel = 0 then 
			SET NextDel = LENGTH(pRequirements)+1;
		elseif NextDel =1 then 
			begin
			Set PrevDel = 2;
			Set NextDel = Locate('|',pRequirements,PrevDel);
			end;
		end if;
		Set str = SUBSTR(pRequirements,PrevDel,NextDel-PrevDel);
	if str='' then
		LEAVE parse_loop;
	end if;

	INSERT INTO tmp_FEATURES (Bed_FeatureID, ProximityID, FeatureSequence) values(SUBSTRING_INDEX(str,',',1),SUBSTRING_INDEX(str,',',-1),i);
		Set PrevDel = NextDel+1;
        Set i=i+1;
	end LOOP parse_loop;
    
    ############create a temp table with a list where of all rooms that don't meet the requirement criteria
 
     
    INSERT INTO tmp_unmachedrooms 
    SELECT DISTINCT R.ROOMID
		FROM ROOM R
		JOIN tmp_Features tf
		LEFT OUTER JOIN ROOMFEATURESVW RFV on r.ROOMID=RFV.ROOMID AND tf.Bed_FeatureID=RFV.Bed_FeatureID
		where RFV.ROOMID IS NULL;
            INSERT INTO tmp_unmachedrooms 
     #FOR THE SUITES       
    SELECT DISTINCT R.PARENTROOMID
		FROM ROOM R
		JOIN tmp_Features tf
		LEFT OUTER JOIN ROOMFEATURESVW RFV on r.ROOMID=RFV.ROOMID AND tf.Bed_FeatureID=RFV.Bed_FeatureID
		where RFV.ROOMID IS NULL;
END;  #if pFeatures <3
END IF;
    
   
	IF pRoomType = (Select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Sleeping') then
    BEGIN
		SELECT 
			sr.RoomID, sr.RoomNumber, sr.BuildingName, sr.WingName, sr.FloorNumber, sr.SmokingAllowed, sr.Capacity, sr.Beds, sr.BedTypes, sr.Features, sr.FeatureIDs
        FROM SleepRoomInfoVw sr
        where sr.RoomID not in (Select RoomID from RoomsBookedVw rb where pStartDate between rb.StartDate and rb.EndDate or pEndDate between rb.StartDate and rb.EndDate)
        and 	sr.RoomID not in (select RoomID from tmp_unmachedrooms)
        and pSmoking = sr.SmokingAllowed ;
    
    END;
    ELSEIF pRoomType = (Select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Suite') then
		BEGIN
			SELECT 
				sr.RoomID, sr.RoomNumber, sr.BuildingName, sr.WingName, sr.FloorNumber, sr.SmokingAllowed, sr.Capacity, sr.Beds, sr.BedTypes, sr.Features, sr.FeatureIDs
			FROM SuiteRoomInfoVw sr
			where sr.RoomID not in (Select RoomID from RoomsBookedVw rb where pStartDate between rb.StartDate and rb.EndDate or pEndDate between rb.StartDate and rb.EndDate)
			and 	sr.RoomID not in (select RoomID from tmp_unmachedrooms)
			and pSmoking = sr.SmokingAllowed ;
		
		END;
     ELSEIF pRoomType = (Select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Meeting') then
		BEGIN
			SELECT 
				sr.RoomID, sr.RoomNumber, sr.BuildingName, sr.WingName, sr.FloorNumber, sr.SmokingAllowed, sr.Capacity, sr.Beds, sr.BedTypes, sr.Features, sr.FeatureIDs
			FROM MeetingRoomInfoVw sr
			where sr.RoomID not in (Select RoomID from RoomsBookedVw rb where pStartDate between rb.StartDate and rb.EndDate or pEndDate between rb.StartDate and rb.EndDate)
			and 	sr.RoomID not in (select RoomID from tmp_unmachedrooms);
			#and pSmoking = sr.SmokingAllowed 
		
		END;
    END IF;
	

END $$




DROP PROCEDURE IF EXISTS `InsertStaySp`; $$

CREATE PROCEDURE `InsertStaySp` (
  pBillToID  INT
, pGuestID	INT
, pReservationID	INT
, pEventID		Int
, pRoomID	Int
, pRoomType Int
, pAnticipatedCheckOut	DateTime
, pRate DEC(12,2)
, pDeposit DEC(12,2)

)
BEGIN
	DECLARE StayID, StayLength, i INT;


		IF pReservationID is Not NULL and pRoomID is Not Null THEN
			BEGIN
            SELECT
				IFNULL(pGuestID,r.GuestID)
            ,	IFNULL(pEventID,r.EventID)
            , 	IFNULL(pAnticipatedCheckOut, r.EndDate)
            , 	IFNULL(pRate,r.Rate)
            , 	IFNULL(pDeposit,r.Deposit)
            , 	IFNULL(pRoomType,r.RoomType)
			,	IFNULL(pBillToID, r.BillToID)

            into pGuestID
			,	pEventID
            , 	pAnticipatedCheckOut
            ,	pRate
            , 	pDeposit
            ,	pRoomType
            ,   pBillToID
            FROM RESERVATION r where r.ReservationID=pReservationID;

            END;
		END IF;
        
        
	if (pBillToID is not null and pRoomID is Not Null) then
    Begin
		INSERT INTO STAY (BillToID, GuestID, ReservationID, EventID, RoomID, RoomType, CheckIn, AnticipatedCheckOut) values (pBillToID, pGuestID, pReservationID, pEventID, pRoomID, pRoomType, NOW(), pAnticipatedCheckOut);
		SELECT LAST_INSERT_ID() into StayID;
	
    
		SET STAYLENGTH = DATEDIFF(pAnticipatedCheckOut,CURDATE());
        SET i=0;
		WHILE i <STAYLENGTH DO 
        
        INSERT INTO STAY_CHARGES(STAYID, ChargeTo, ChargeType, Amount, ChargeDate, DueDate) 
        values (StayId, pBillToID, (SELECT TypeNameID from Type_Name where UsageID = 'ChargeType' and Name = 'Room Charges'),pRate, ADDDATE(CURDATE(),i), pAnticipatedCheckOut);
		set i=i+1;
        END WHILE;

		IF IFNULL(pDeposit,0)<> 0 THEN
                INSERT INTO STAY_CHARGES(STAYID, ChargeTo, ChargeType, Amount, ChargeDate, DueDate) 
					values (StayId, pBillToID, (SELECT TypeNameID from Type_Name where UsageID = 'ChargeType' and Name = 'Deposit'),-1*pRate, Now(), pAnticipatedCheckOut);
        END IF;

		End;
       
       IF pReservationID is Not NULL then 
                    UPDATE RESERVATION SET ConvertedToStay = 1 where ReservationID = pReservationID;
		end if;

    end if;  # billtoid, roomid

END;


$$




delimiter ;

