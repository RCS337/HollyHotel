SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `TYPE_NAME`
-- -----------------------------------------------------
START TRANSACTION;
USE `hollyhotel`;
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_numlist
(NUM  INT NOT NULL) ;
INSERT INTO tmp_numlist VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20);


INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BuildingID', 'Main Building', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BuildingID', 'Heritage Building', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BuildingID', 'Savanah Building', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'North Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'East Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'South Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'West Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Single Bed', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Double Bed', 2);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Queen Bed', 3);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'King Bed', 4);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Fold Out Couch', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Roll-Away Bed', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Hide-Away Bed (Wall)', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'RoomType', 'Sleeping', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'RoomType', 'Meeting', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'RoomType', 'Suite', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Breakfast', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Lunch', 2);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Dinner', 3);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Bar', 4);

INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Indoor Pool', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Outdoor Pool', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Parking Garage', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Loading Dock', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Handicap Accessible', 0);

INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'ProximityID', 'None', 0);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'ProximityID', 'Near', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'ProximityID', 'Adjacent', 2);

INSERT INTO BUILDING_WING(BuildingID, WingID, NumberOfFloors) (
select t1.TypeNameID, t2.TypeNameID
, case t1.Name When 'Main Building' then 4
			   When 'Heritage Building' then 3
               else 2
               end  as NumberOfFloors
from type_name t1
join type_name t2
 where t1.UsageID = 'BuildingID' 
 and t2.UsageID = 'WingId'
 order by t1.TypeNameID, t2.TypeNameID);

#INSERT WING/FLOOR DETAILS

INSERT INTO WING_FLOOR
(SELECT DISTINCT BuildingID, WingID, NUM 
, (BuildingID + WingID +Floors)%2 as Smoking
from Building_Wing, tmp_numlist 
WHERE NUM<= (SELECT MAX(NumberOfFloors) FROM BUILDING_WING) ORDER BY bUILDINGid, wINGid, fLOORS)
;


#Insert rooms
INSERT INTO ROOM(BuildingID, WingID, Floor, RoomNumber)
(SELECT DISTINCT BuildingID, WingID, FloorNumber 
, CONCAT(BUILDINGID, LPAD(WINGID,2,0), LPAD(FloorNumber,2,0), LPAD(NUM,2,0))
from WING_FLOOR, tmp_numlist 
WHERE NUM<= 20 ORDER BY bUILDINGid, wINGid,  FLOORnUMBER, NUM);

/*
  Suites are in 7,8, 15,16 of each wing that are made up of the sleeping being one less and the meeting room is one higher
  Room 1 is a suite with only one entrance (cannot be split)
  
*/

#Specify Parent Room
UPDATE ROOM r1
join ROOM r2 on r1.RoomNumber =r2.RoomNumber-2 or r1.RoomNumber= r2.RoomNumber+2
Set r1.ParentRoomID = r2.RoomID
where Right(r2.RoomNumber,2) in (7,8, 15,16 );


#Insert Suites First
INSERT INTO ROOM_DETAIL(ROOMID,ROOMTYPE,CAPACITY,PERMITSMOKING, RATE)
Select RoomID, (select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Suite') as RoomType, CASE WHEN Right(r.RoomNumber,2) in (7,8) then 6 else 5 end as capacity, (RoomID%3)%2 as PermitSmoking, 250 as Rate
from Room r where Right(r.RoomNumber,2) in (1,7,8, 15,16 );


#Insert Meeting Rooms Next (Room 1s can be both!)
INSERT INTO ROOM_DETAIL(ROOMID,ROOMTYPE,CAPACITY,PERMITSMOKING, RATE, Toliet)
Select r.RoomID, (select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Meeting') as RoomType, CASE WHEN Right(r.RoomNumber,2) in (9,10) then 10 else 6 end as capacity
, ifnull(rd.PermitSmoking,(r.RoomID%3)%2) as PermitSmoking
, 250 as Rate
, (r.ROOMID+r.BuildingID+r.WingId+r.Floor)%2 as Toilet
from Room r 
LEFT OUTER JOIN ROOM_DETAIL rd ON ifnull(r.ParentRoomID,r.RoomID)=rd.RoomID and rd.RoomType = (select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Suite')
where Right(r.RoomNumber,2) in (1,9,10,17,18);


#Insert Sleeping Rooms Last (Room 1s can be both!)
INSERT INTO ROOM_DETAIL(ROOMID,ROOMTYPE,CAPACITY,PERMITSMOKING, RATE, ExtraSpace)
Select r.RoomID, (select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Sleeping') as RoomType
, CASE WHEN Right(r.RoomNumber,2)%3 = 0 then 6 else 4 end as capacity
, ifnull(rd.PermitSmoking,(r.RoomID%3)%2) as PermitSmoking
, 115 as Rate
, CASE WHEN Right(r.RoomNumber,2)%3 = 0 then 1 else 0 end as ExtraSpace
from Room r 
LEFT OUTER JOIN ROOM_DETAIL rd ON ifnull(r.ParentRoomID,r.RoomID)=rd.RoomID and rd.RoomType = (select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Suite')
where Right(r.RoomNumber,2) not in (7,8,9,10,15,16,17,18);


#Fix pricing, that will help assign the beds
#SET ROOM RATE FOR KING + EXTRA SPACE
UPDATE ROOM_DETAIL SET RATE = 230
WHERE RoomType = (SELECT TypeNameID from Type_Name where UsageID = 'RoomType' and Name IN ('Sleeping')) and ExtraSpace = 1 and roomid%3 = 0;

#SET ROOM RATE FOR QUEEN + EXTRA SPACE
UPDATE ROOM_DETAIL SET RATE = 200
WHERE RoomType = (SELECT TypeNameID from Type_Name where UsageID = 'RoomType' and Name IN ('Sleeping')) and ExtraSpace = 1 and roomid%3 <> 0;

#SET ROOM RATE FOR TWO KINGS (all rooms that are part of a suite should be kings)
UPDATE ROOM_DETAIL rd 
JOIN ROOM R ON r.RoomID=rd.RoomID
SET RATE = 170
WHERE RoomType = (SELECT TypeNameID from Type_Name where UsageID = 'RoomType' and Name IN ('Sleeping')) and ExtraSpace = 0 and r.ParentRoomID is not null ;

#SET ROOM RATE FOR TWO Queens (half of the remaining + Room #1 on each floor/Wing)
UPDATE ROOM_DETAIL rd 
JOIN ROOM R ON r.RoomID=rd.RoomID
SET RATE = 140
WHERE RIGHT(r.RoomNumber,2)='01' and Rate = 115;


UPDATE ROOM_DETAIL 
SET RATE = 140
where rate = 115 and roomid%11 in (0,3,5,7);


#INSERT FIRST TWO BEDS FOR SLEEPING ROOMS
INSERT INTO ROOM_BEDS
SELECT 
rd.RoomID
,NUM as BedSequence
, CASE 
	WHEN rd.RATE in (140,200) then (SELECT TypeNameID from Type_Name where UsageID = 'BedType' and Name IN ('Queen Bed'))
    WHEN rd.RATE in (170,230) then (SELECT TypeNameID from Type_Name where UsageID = 'BedType' and Name IN ('King Bed'))
    WHEN rd.RATE in (115) then (SELECT TypeNameID from Type_Name where UsageID = 'BedType' and Name IN ('Double Bed'))
    end as BedType
FROM ROOM_DETAIL rd
, TMP_NUMLIST
WHERE RoomType = (SELECT TypeNameID from Type_Name where UsageID = 'RoomType' and Name IN ('Sleeping'))
AND NUM<3
ORDER BY ROOMID, NUM;


#Add the Extra Beds
INSERT INTO ROOM_BEDS SELECT ROOMID, 3, (SELECT TypeNameID from Type_Name where UsageID = 'BedType' and Name IN ('Fold Out Couch')) FROM ROOM_DETAIL WHERE eXTRAsPACE = 1 AND ROOMID%3=0;
INSERT INTO ROOM_BEDS SELECT ROOMID, 3, (SELECT TypeNameID from Type_Name where UsageID = 'BedType' and Name IN ('Roll-Away Bed')) FROM ROOM_DETAIL WHERE eXTRAsPACE = 1 AND ROOMID%3<>0;

#Some meeting rooms have beds in the wall
INSERT INTO ROOM_BEDS SELECT ROOMID, 1, (SELECT TypeNameID from Type_Name where UsageID = 'BedType' and Name IN ('Hide-Away Bed (Wall)')) FROM ROOM_DETAIL WHERE Toliet = 1 AND ROOMID%3 IN (0,1) and ROOMID NOT IN (SELECT DISTINCT ROOMID FROM ROOM_BEDS);

#Add Wing Features

#ADD OUTDOOR POOL TO SAVANAH
INSERT INTO BUILDING_WING_FEATURES
SELECT BUILDINGID, WINGID, (SELECT TypeNameID from Type_Name where UsageID = 'FeatureID' and Name = 'Outdoor Pool') as FeatureID, (SELECT TypeNameID from Type_Name where UsageID = 'ProximityID' and Name = 'Adjacent') as ProximityID
FROM BUILDING_WING 
WHERE BUILDINGID = (SELECT TypeNameID from Type_Name where UsageID = 'BUILDINGID' and Name = 'Savanah Building');

#ADD INDOOR POOL TO MAIN
INSERT INTO BUILDING_WING_FEATURES
SELECT BUILDINGID, WINGID, (SELECT TypeNameID from Type_Name where UsageID = 'FeatureID' and Name = 'Indoor Pool') as FeatureID, (SELECT TypeNameID from Type_Name where UsageID = 'ProximityID' and Name = 'Adjacent') as ProximityID
FROM BUILDING_WING 
WHERE BUILDINGID = (SELECT TypeNameID from Type_Name where UsageID = 'BUILDINGID' and Name = 'Main Building');

#ADD loading docks to the east/west wings
INSERT INTO BUILDING_WING_FEATURES
SELECT BUILDINGID, WINGID, (SELECT TypeNameID from Type_Name where UsageID = 'FeatureID' and Name = 'Loading Dock') as FeatureID, (SELECT TypeNameID from Type_Name where UsageID = 'ProximityID' and Name = 'Adjacent') as ProximityID
FROM BUILDING_WING 
WHERE WingID in (SELECT TypeNameID from Type_Name where UsageID = 'WINGID' and Name IN ('East Wing', 'West Wing'));

#Add Parking garages right next to north and east
INSERT INTO BUILDING_WING_FEATURES
SELECT BUILDINGID, WINGID, (SELECT TypeNameID from Type_Name where UsageID = 'FeatureID' and Name = 'Parking Garage') as FeatureID, (SELECT TypeNameID from Type_Name where UsageID = 'ProximityID' and Name = 'Adjacent') as ProximityID
FROM BUILDING_WING 
WHERE WingID in (SELECT TypeNameID from Type_Name where UsageID = 'WINGID' and Name IN ('East Wing', 'North Wing'));


#Add Parking garages near to West
INSERT INTO BUILDING_WING_FEATURES
SELECT BUILDINGID, WINGID, (SELECT TypeNameID from Type_Name where UsageID = 'FeatureID' and Name = 'Parking Garage') as FeatureID, (SELECT TypeNameID from Type_Name where UsageID = 'ProximityID' and Name = 'Near') as ProximityID
FROM BUILDING_WING 
WHERE WingID in (SELECT TypeNameID from Type_Name where UsageID = 'WINGID' and Name IN ('West Wing'));


#Add Handicap Accessiblity to North and South
INSERT INTO BUILDING_WING_FEATURES
SELECT BUILDINGID, WINGID, (SELECT TypeNameID from Type_Name where UsageID = 'FeatureID' and Name = 'Handicap Accessible') as FeatureID, (SELECT TypeNameID from Type_Name where UsageID = 'ProximityID' and Name = 'Adjacent') as ProximityID
FROM BUILDING_WING 
WHERE WingID in (SELECT TypeNameID from Type_Name where UsageID = 'WINGID' and Name IN ('North Wing', 'South Wing'));

#Mark as non Handicap Accessiblity to East/West
INSERT INTO BUILDING_WING_FEATURES
SELECT BUILDINGID, WINGID, (SELECT TypeNameID from Type_Name where UsageID = 'FeatureID' and Name = 'Handicap Accessible') as FeatureID, (SELECT TypeNameID from Type_Name where UsageID = 'ProximityID' and Name = 'None') as ProximityID
FROM BUILDING_WING 
WHERE WingID in (SELECT TypeNameID from Type_Name where UsageID = 'WINGID' and Name not IN ('North Wing', 'South Wing'));


#standard customer insert
CALL InsUpStdCustomerSp (NULL,'Jack','Smith',NULL,'123 Main Street',NULL,NULL,NULL,'Rapid City','SD','55432','USA','3333333333');
CALL InsUpStdCustomerSp (NULL,'Sarah','Jones',NULL,'456 Oak Street',NULL,NULL,NULL,'Madison','WI','53711','USA','8478892698');
CALL InsUpStdCustomerSp (NULL,'Bob','Henry',NULL,'789 Maple Street',NULL,NULL,NULL,'New York','NY','34521','USA','9661745639');
CALL InsUpStdCustomerSp (NULL,'Jordan','Smith',NULL,'123 Breeze Terrace',NULL,NULL,NULL,'Orono','MN','54677','USA','3783247022');
CALL InsUpStdCustomerSp (NULL,'Zak','Showalter',NULL,'4567 Midvale Bolavard',NULL,NULL,NULL,'Germantown','WI','53799','USA','7669203284');
CALL InsUpStdCustomerSp (NULL,'Matt','Ferris',NULL,'7789 Singel Way',NULL,NULL,NULL,'Appleton','WI','53798','USA','9054114346');
CALL InsUpStdCustomerSp (NULL,'Aaron','Moesch',NULL,'8986 Rembrant Rd.',NULL,NULL,NULL,'Green Bay','WI','53797','USA','8089971622');
CALL InsUpStdCustomerSp (NULL,'Nigel','Hayes',NULL,'3456 Lake Street',NULL,NULL,NULL,'Toledo','OH','43567','USA','7829173741');
CALL InsUpStdCustomerSp (NULL,'Jordan','Hill',NULL,'2321 Golf Way',NULL,NULL,NULL,'Pasadena','CA','89765','USA','4810991268');
CALL InsUpStdCustomerSp (NULL,'Traevon','Jackson',NULL,'8976 Bluemound Road',NULL,NULL,NULL,'Westerville','OH','43598','USA','4973317989');
CALL InsUpStdCustomerSp (NULL,'Duje','Dukan',NULL,'8766 Mountain Pass',NULL,NULL,NULL,'Deerfield','IL','50987','USA','1013474941');
CALL InsUpStdCustomerSp (NULL,'Sam','Dekker',NULL,'5432 Indian Trail',NULL,NULL,NULL,'Sheboygan','WI','53723','USA','4322971273');
CALL InsUpStdCustomerSp (NULL,'T.J.','Schlundt',NULL,'9876 River Road',NULL,NULL,NULL,'Oconomowoc','WI','53768','USA','4112827962');
CALL InsUpStdCustomerSp (NULL,'Josh','Gasser',NULL,'8765 Meandering Way',NULL,NULL,NULL,'Port Washington','WI','53700','USA','7863041811');
CALL InsUpStdCustomerSp (NULL,'Ethan','Happ',NULL,'3422 Lake Shore Drive',NULL,NULL,NULL,'Malan','IL','50965','USA','5065147246');
CALL InsUpStdCustomerSp (NULL,'Bronson','Koenig',NULL,'1234 N. Third Ave.',NULL,NULL,NULL,'La Crosse','WI','53789','USA','9657079860');
CALL InsUpStdCustomerSp (NULL,'Vitto','Brown',NULL,'8765 First Street',NULL,NULL,NULL,'Bowling Green','OH','43512','USA','6094026818');
CALL InsUpStdCustomerSp (NULL,'Riley','Dearring',NULL,'9854 Mississippi Rd.',NULL,NULL,NULL,'Minnetonka','MN','54622','USA','7612892932');
CALL InsUpStdCustomerSp (NULL,'Frank','Kaminski',NULL,'6832 Flat Rd.',NULL,NULL,NULL,'Lisle','IL','50933','USA','6610627680');



DROP TABLE tmp_numlist;
COMMIT;