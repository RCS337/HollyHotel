DELIMITER $$


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