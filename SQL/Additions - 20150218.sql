DELIMITER $$


DROP VIEW IF EXISTS ResFeaturesVw $$

CREATE VIEW ResFeaturesVw AS
select ReservationID, BedFeatureID as Bed_FeatureID, ProximityID, count(ReservationID) as Qty from res_features group by ReservationID, BedFeatureID, ProximityID;

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

DELIMITER ;