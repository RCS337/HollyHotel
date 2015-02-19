SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

-- -----------------------------------------------------
-- Data for table `TYPE_NAME`
-- -----------------------------------------------------
START TRANSACTION;
USE `hollyhotel`;
DROP TABLE if exists tmp_numlist;
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_numlist
(NUM  INT NOT NULL) ;
INSERT INTO tmp_numlist VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12),(13),(14),(15),(16),(17),(18),(19),(20);

INSERT INTO `USERS`(USERNAME, PASSWORD) VALUES ('admin','7f6dde9c0562845a15bc5291199d40aad35e9a8b'), ('frontdesk','de3a3a66a6215118e85510ffe3311743aa1db6d7'),('maint','312ab2bbc37fcbfacbf7fb6e31312878632b9bdf');

INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BuildingID', 'Main Building', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BuildingID', 'Heritage Building', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BuildingID', 'Savanah Building', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'North Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'East Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'South Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'WingID', 'West Wing', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Single Bed', 2);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Double Bed', 3);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Queen Bed', 4);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'King Bed', 5);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Fold Out Couch', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Roll-Away Bed', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'BedType', 'Hide-Away Bed (Wall)', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'RoomType', 'Sleeping', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'RoomType', 'Meeting', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'RoomType', 'Suite', NULL);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Breakfast', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Lunch', 2);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Dinner', 3);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'MealID', 'Bar', 4);

INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Indoor Pool', 4);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Outdoor Pool', 3);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Parking Garage', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Loading Dock', 1);
INSERT INTO `TYPE_NAME` ( `UsageID`, `Name`, `UsageRank`) VALUES ( 'FeatureID', 'Handicap Accessible', 2);

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
, (BuildingID + WingID +NumberOfFloors)%2 as Smoking
from Building_Wing, tmp_numlist 
WHERE NUM<= (SELECT MAX(NumberOfFloors) FROM BUILDING_WING) ORDER BY BuildingID, WingID, NumberOfFloors)
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

CALL InsUpStdCustomerSp (NULL,'Art','Schmitt',NULL,'70357 Lily Heights',NULL,NULL,NULL,'North Kayleyborough','MO','12756','USA','1339561484');
CALL InsUpStdCustomerSp (NULL,'Murphy','Toy',NULL,'65678 Devon Manors',NULL,NULL,NULL,'East Madisonfurt','MA','52175','USA','5426894378');
CALL InsUpStdCustomerSp (NULL,'Jessy','Upton',NULL,'174 Schuppe Rapids',NULL,NULL,NULL,'Ameliefurt','OH','91701','USA','0486947203');
CALL InsUpStdCustomerSp (NULL,'Amber','Miller',NULL,'383 Rosenbaum Tunnel',NULL,NULL,NULL,'Andersonview','AL','19978','USA','8332383879');
CALL InsUpStdCustomerSp (NULL,'Natasha','Hegmann',NULL,'74875 DuBuque Pine',NULL,NULL,NULL,'South Hermina','MI','16504','USA','1182550279');
CALL InsUpStdCustomerSp (NULL,'Eino','Brown',NULL,'8719 Nils Hollow',NULL,NULL,NULL,'Albertland','GE','84643','USA','2920765052');
CALL InsUpStdCustomerSp (NULL,'Adela','Hermann',NULL,'8207 Sipes Ford',NULL,NULL,NULL,'East Amiyaburgh','MI','46248','USA','5416739714');
CALL InsUpStdCustomerSp (NULL,'Rowan','Schmidt',NULL,'2713 Bergstrom Springs',NULL,NULL,NULL,'South Bo','KA','94446','USA','0792343610');
CALL InsUpStdCustomerSp (NULL,'Kristy','Jacobs',NULL,'2850 Sanford Motorway',NULL,NULL,NULL,'Port Vladimirmouth','CO','09753','USA','1642541521');
CALL InsUpStdCustomerSp (NULL,'Gia','Adams',NULL,'054 Auer Rapids',NULL,NULL,NULL,'Noelialand','OK','11824','USA','3514075197');
CALL InsUpStdCustomerSp (NULL,'Hilbert','Simonis',NULL,'6490 McKenzie Club',NULL,NULL,NULL,'Lizamouth','NE','07459','USA','1417341580');
CALL InsUpStdCustomerSp (NULL,'Teresa','Lakin',NULL,'84434 Hills Forest',NULL,NULL,NULL,'South Garrisonbury','AL','30912','USA','8609910510');
CALL InsUpStdCustomerSp (NULL,'Blanche','Hansen',NULL,'997 Estevan Place',NULL,NULL,NULL,'Ornview','NO','97787','USA','6703888306');
CALL InsUpStdCustomerSp (NULL,'Anjali','Rodriguez',NULL,'2280 Nicklaus Neck',NULL,NULL,NULL,'Sipesport','NE','72672','USA','1381174563');
CALL InsUpStdCustomerSp (NULL,'Beulah','Oberbrunner',NULL,'847 Germaine Throughway',NULL,NULL,NULL,'Lake Holdenborough','NE','82608','USA','1360976362');
CALL InsUpStdCustomerSp (NULL,'Mariah','Dietrich',NULL,'8519 Meggie Fields',NULL,NULL,NULL,'Josueberg','MI','96563','USA','4470146728');
CALL InsUpStdCustomerSp (NULL,'Oceane','Kreiger',NULL,'040 Kathlyn Fort',NULL,NULL,NULL,'Medhurstside','TE','45853','USA','8982937724');
CALL InsUpStdCustomerSp (NULL,'Derek','DAmore',NULL,'08432 Boehm Passage',NULL,NULL,NULL,'New Berniceport','IL','26187','USA','1438875517');
CALL InsUpStdCustomerSp (NULL,'Irma','Gerhold',NULL,'235 Cierra Court',NULL,NULL,NULL,'Huelshire','KE','60422','USA','7688947705');
CALL InsUpStdCustomerSp (NULL,'Juliet','Gulgowski',NULL,'2089 Reba Camp',NULL,NULL,NULL,'Kohlermouth','NE','57583','USA','7067584566');
CALL InsUpStdCustomerSp (NULL,'Alicia','Batz',NULL,'752 Kunze Islands',NULL,NULL,NULL,'North Damion','SO','05803','USA','3190890011');
CALL InsUpStdCustomerSp (NULL,'Quinton','Wisozk',NULL,'919 Philip Drive',NULL,NULL,NULL,'Port Ramona','NE','10430','USA','7381700436');
CALL InsUpStdCustomerSp (NULL,'Marilie','Moen',NULL,'09752 August Ford',NULL,NULL,NULL,'Kautzerberg','NE','47044','USA','3572456685');
CALL InsUpStdCustomerSp (NULL,'Cesar','McGlynn',NULL,'9330 Deonte Rue',NULL,NULL,NULL,'Greenville','MI','56011','USA','2846876356');
CALL InsUpStdCustomerSp (NULL,'Eleanore','Hackett',NULL,'799 Heller Plains',NULL,NULL,NULL,'Tremblayport','GE','52451','USA','0118476797');
CALL InsUpStdCustomerSp (NULL,'Bailey','Klocko',NULL,'57479 Padberg Point',NULL,NULL,NULL,'Wunschbury','RH','39808','USA','7483470950');
CALL InsUpStdCustomerSp (NULL,'Juliet','Dach',NULL,'590 Neal Grove',NULL,NULL,NULL,'Beahanstad','NE','6414','USA','2513789935');
CALL InsUpStdCustomerSp (NULL,'Vivienne','Walter',NULL,'545 Wisoky Trace',NULL,NULL,NULL,'Noraburgh','WY','78095','USA','4340790962');
CALL InsUpStdCustomerSp (NULL,'Jerome','Hammes',NULL,'38519 Bartoletti Junctions',NULL,NULL,NULL,'South Anabelhaven','MA','35193','USA','7843092058');
CALL InsUpStdCustomerSp (NULL,'Ransom','Baumbach',NULL,'094 Alexander Ridges',NULL,NULL,NULL,'Darlenemouth','NE','16735','USA','1652196862');
CALL InsUpStdCustomerSp (NULL,'Delmer','King',NULL,'261 Dameon Mission',NULL,NULL,NULL,'Alexaneberg','MA','80793','USA','1529416804');
CALL InsUpStdCustomerSp (NULL,'Devin','Murazik',NULL,'68780 Veum Forks',NULL,NULL,NULL,'Stokesshire','OK','88390','USA','1175588915');
CALL InsUpStdCustomerSp (NULL,'Sabrina','Bauch',NULL,'773 Declan Island',NULL,NULL,NULL,'New Alessiaton','KE','05192','USA','6786455738');
CALL InsUpStdCustomerSp (NULL,'Thurman','Cremin',NULL,'65904 Uriel Route',NULL,NULL,NULL,'Lilianeport','CO','13861','USA','1314867357');
CALL InsUpStdCustomerSp (NULL,'Brian','Armstrong',NULL,'98177 Emma Dale',NULL,NULL,NULL,'North Bayleeport','KE','75842','USA','1097786527');
CALL InsUpStdCustomerSp (NULL,'Zoe','Rosenbaum',NULL,'7274 Gustave Points',NULL,NULL,NULL,'Ratkestad','IL','73802','USA','1545768792');
CALL InsUpStdCustomerSp (NULL,'Josefa','Mertz',NULL,'8760 Mittie Square',NULL,NULL,NULL,'New Stacy','IO','95930','USA','1353900738');
CALL InsUpStdCustomerSp (NULL,'Everett','Kuhn',NULL,'0596 Tomas Green',NULL,NULL,NULL,'North Rodrick','AR','87822','USA','8961852983');
CALL InsUpStdCustomerSp (NULL,'Susie','Hahn',NULL,'6196 Vivian Loop',NULL,NULL,NULL,'North Gayleton','CO','93179','USA','1899954335');
CALL InsUpStdCustomerSp (NULL,'Viola','Huels',NULL,'67866 Taylor Walk',NULL,NULL,NULL,'South Darionview','AR','24246','USA','4706892011');
CALL InsUpStdCustomerSp (NULL,'Vivianne','Wintheiser',NULL,'5947 Torp Brook',NULL,NULL,NULL,'Port Charlotte','NE','39198','USA','9277427068');
CALL InsUpStdCustomerSp (NULL,'Lincoln','Fahey',NULL,'8295 Abagail Causeway',NULL,NULL,NULL,'Maraview','MI','36554','USA','3475250955');
CALL InsUpStdCustomerSp (NULL,'Otilia','Torphy',NULL,'347 Jillian Crest',NULL,NULL,NULL,'Saraiton','OH','57351','USA','9103300964');
CALL InsUpStdCustomerSp (NULL,'Dennis','Hills',NULL,'85141 Kendrick Neck',NULL,NULL,NULL,'Spinkastad','NE','1120','USA','5298958018');
CALL InsUpStdCustomerSp (NULL,'Harold','Hackett',NULL,'456 Wanda Highway',NULL,NULL,NULL,'Port Curtfort','NO','14661','USA','0467723022');
CALL InsUpStdCustomerSp (NULL,'Modesta','Senger',NULL,'441 Geovanny Fork',NULL,NULL,NULL,'Hanemouth','OK','49062','USA','4136892232');
CALL InsUpStdCustomerSp (NULL,'Troy','Keebler',NULL,'79750 Waters Ports',NULL,NULL,NULL,'East Antonehaven','OK','19381','USA','1538556135');
CALL InsUpStdCustomerSp (NULL,'Syble','Shields',NULL,'9153 Maymie Keys',NULL,NULL,NULL,'Port Damienberg','RH','36318','USA','1048255729');
CALL InsUpStdCustomerSp (NULL,'Alexa','Bergnaum',NULL,'23050 Lesley Fields',NULL,NULL,NULL,'Roderickfurt','KE','76851','USA','1646155366');
CALL InsUpStdCustomerSp (NULL,'Afton','Kertzmann',NULL,'502 Maybelle Divide',NULL,NULL,NULL,'East Elroy','FL','69691','USA','2476653017');
CALL InsUpStdCustomerSp (NULL,'Kimberly','Leannon',NULL,'29052 Jimmie Stream',NULL,NULL,NULL,'East Murraytown','MO','21577','USA','1518929470');
CALL InsUpStdCustomerSp (NULL,'Juana','Williamson',NULL,'8089 Lynn Village',NULL,NULL,NULL,'South Myrtie','WY','01458','USA','1961331222');
CALL InsUpStdCustomerSp (NULL,'Karlee','Runolfsson',NULL,'126 Cartwright Alley',NULL,NULL,NULL,'East Maybell','HA','96308','USA','9976853406');
CALL InsUpStdCustomerSp (NULL,'Dee','Schmidt',NULL,'6424 Anderson Turnpike',NULL,NULL,NULL,'Luciousview','MO','08624','USA','4313720798');
CALL InsUpStdCustomerSp (NULL,'Arvid','Cummings',NULL,'407 Stark Hollow',NULL,NULL,NULL,'Lueilwitzshire','WY','04358','USA','2812405391');
CALL InsUpStdCustomerSp (NULL,'Kira','Stracke',NULL,'02909 Marquardt Burg',NULL,NULL,NULL,'New Zoratown','CO','57480','USA','8608444480');
CALL InsUpStdCustomerSp (NULL,'Haylie','Hammes',NULL,'684 Miller Roads',NULL,NULL,NULL,'Lake Reganview','MA','14328','USA','0371681655');
CALL InsUpStdCustomerSp (NULL,'Daphnee','Bashirian',NULL,'7387 Royce Squares',NULL,NULL,NULL,'Erickmouth','KA','21982','USA','7120797992');
CALL InsUpStdCustomerSp (NULL,'Destiny','Kuphal',NULL,'4113 Rosenbaum Loop',NULL,NULL,NULL,'North Beau','NE','50084','USA','2905814561');
CALL InsUpStdCustomerSp (NULL,'Guadalupe','Schulist',NULL,'473 Adela Drives',NULL,NULL,NULL,'Schusterside','KA','23742','USA','9333590847');
CALL InsUpStdCustomerSp (NULL,'Johan','Bogisich',NULL,'060 Hackett Plains',NULL,NULL,NULL,'Lake Marlen','AL','99198','USA','6776140670');
CALL InsUpStdCustomerSp (NULL,'Eulalia','Von',NULL,'1481 Rempel Spurs',NULL,NULL,NULL,'Rudybury','NE','65823','USA','1224809200');
CALL InsUpStdCustomerSp (NULL,'Larry','Kuvalis',NULL,'552 Lisa Alley',NULL,NULL,NULL,'Francescoland','MI','49112','USA','1250529198');
CALL InsUpStdCustomerSp (NULL,'Sven','Dickinson',NULL,'617 Murray Port',NULL,NULL,NULL,'Ryanstad','AR','45627','USA','1040310401');
CALL InsUpStdCustomerSp (NULL,'Jaylen','Hyatt',NULL,'6397 Kozey Fall',NULL,NULL,NULL,'Rogahnstad','NE','03175','USA','1578493422');
CALL InsUpStdCustomerSp (NULL,'Ernestina','Sanford',NULL,'7373 Gottlieb Orchard',NULL,NULL,NULL,'New Josianestad','MA','23954','USA','1600320831');
CALL InsUpStdCustomerSp (NULL,'Christine','Johnson',NULL,'11930 Parker Mission',NULL,NULL,NULL,'Tamiamouth','NE','01934','USA','1112395045');
CALL InsUpStdCustomerSp (NULL,'Eryn','Nolan',NULL,'038 Rae Shoals',NULL,NULL,NULL,'Edwardoburgh','MA','19688','USA','8173409673');
CALL InsUpStdCustomerSp (NULL,'Zane','Mayert',NULL,'00680 Armstrong Inlet',NULL,NULL,NULL,'Binsfort','MI','88204','USA','0270674367');
CALL InsUpStdCustomerSp (NULL,'Bernhard','Kling',NULL,'44118 Balistreri Cliffs',NULL,NULL,NULL,'South Xavierfort','VI','13896','USA','3585981501');
CALL InsUpStdCustomerSp (NULL,'Marjory','Runolfsdottir',NULL,'637 Assunta Road',NULL,NULL,NULL,'Stewartfurt','WA','95872','USA','1443135405');
CALL InsUpStdCustomerSp (NULL,'Isabell','Legros',NULL,'18610 Johns Place',NULL,NULL,NULL,'Davionfort','PE','60106','USA','4857160776');
CALL InsUpStdCustomerSp (NULL,'Raegan','Hettinger',NULL,'9000 Waylon Overpass',NULL,NULL,NULL,'Lake Forestmouth','SO','25463','USA','1772840547');
CALL InsUpStdCustomerSp (NULL,'Reba','Gorczany',NULL,'422 Haleigh Causeway',NULL,NULL,NULL,'East Orionshire','MO','49978','USA','5394765024');
CALL InsUpStdCustomerSp (NULL,'Dion','DAmore',NULL,'4586 Kuhn Stravenue',NULL,NULL,NULL,'Keeganfurt','IO','59089','USA','1215388452');
CALL InsUpStdCustomerSp (NULL,'Hassan','Rutherford',NULL,'781 Joany Vista',NULL,NULL,NULL,'Port Guiseppe','MI','09681','USA','0870456434');
CALL InsUpStdCustomerSp (NULL,'Tito','Haley',NULL,'838 Vince Shores',NULL,NULL,NULL,'Port Armand','MI','8983','USA','1358381029');
CALL InsUpStdCustomerSp (NULL,'Amelie','Hagenes',NULL,'775 Roberts Inlet',NULL,NULL,NULL,'West Stephany','MA','81742','USA','1943163389');
CALL InsUpStdCustomerSp (NULL,'Cale','Heathcote',NULL,'30005 Breitenberg Port',NULL,NULL,NULL,'East Nicklausshire','SO','76035','USA','0300818185');
CALL InsUpStdCustomerSp (NULL,'Olen','Mayer',NULL,'8572 Alexis Pine',NULL,NULL,NULL,'South Veldahaven','IO','18895','USA','1984188890');
CALL InsUpStdCustomerSp (NULL,'Romaine','Towne',NULL,'8053 Josefa Mountains',NULL,NULL,NULL,'Raphaelleview','NE','26614','USA','4835331704');
CALL InsUpStdCustomerSp (NULL,'Alvera','Konopelski',NULL,'69273 Fahey Lodge',NULL,NULL,NULL,'Mayaborough','MA','79651','USA','7586521486');
CALL InsUpStdCustomerSp (NULL,'Carolyn','Kilback',NULL,'61290 Jaylin Roads',NULL,NULL,NULL,'East Sammy','NE','90741','USA','0960627271');
CALL InsUpStdCustomerSp (NULL,'Randi','Pouros',NULL,'0323 Lee Underpass',NULL,NULL,NULL,'South Rachael','NE','17112','USA','8641276758');
CALL InsUpStdCustomerSp (NULL,'Kayden','Klein',NULL,'4015 Cormier Ridge',NULL,NULL,NULL,'Stammview','MO','03316','USA','8172595520');
CALL InsUpStdCustomerSp (NULL,'Ona','Emard',NULL,'12811 Wunsch Parks',NULL,NULL,NULL,'New Loy','TE','61181','USA','9206362805');
CALL InsUpStdCustomerSp (NULL,'Ellen','Greenholt',NULL,'3834 Edmund Cape',NULL,NULL,NULL,'Manuelahaven','WI','53082','USA','1256322990');
CALL InsUpStdCustomerSp (NULL,'Katharina','Cronin',NULL,'79194 Nader Ranch',NULL,NULL,NULL,'Reynoldsfort','OK','9554','USA','7969622743');
CALL InsUpStdCustomerSp (NULL,'Ada','Johns',NULL,'205 Sarina Way',NULL,NULL,NULL,'Franceshaven','KA','57168','USA','1015230479');
CALL InsUpStdCustomerSp (NULL,'Cornelius','Toy',NULL,'62605 Bernhard Points',NULL,NULL,NULL,'Heathcotestad','OR','21277','USA','8920293742');
CALL InsUpStdCustomerSp (NULL,'Jana','Hyatt',NULL,'68449 Caleb Haven',NULL,NULL,NULL,'Rossiechester','NE','20241','USA','1917428731');
CALL InsUpStdCustomerSp (NULL,'Jannie','Nolan',NULL,'03611 Ankunding Brooks',NULL,NULL,NULL,'Rachelleburgh','NE','2004','USA','7009913929');
CALL InsUpStdCustomerSp (NULL,'Alene','Conroy',NULL,'07055 Blanda Isle',NULL,NULL,NULL,'New Paris','AL','36373','USA','9150748750');
CALL InsUpStdCustomerSp (NULL,'Pattie','Buckridge',NULL,'6598 Abel View',NULL,NULL,NULL,'Scotberg','NE','89549','USA','6765584826');
CALL InsUpStdCustomerSp (NULL,'Retha','Gislason',NULL,'8545 Ali Gardens',NULL,NULL,NULL,'North Aleenhaven','AL','80333','USA','9120411223');
CALL InsUpStdCustomerSp (NULL,'Rosalinda','Bergnaum',NULL,'24392 Ashley Loaf',NULL,NULL,NULL,'West Adam','MA','28718','USA','9466825162');
CALL InsUpStdCustomerSp (NULL,'Elmore','Rath',NULL,'9519 Rowe Throughway',NULL,NULL,NULL,'Krisland','NE','14946','USA','3411335175');
CALL InsUpStdCustomerSp (NULL,'Jace','Howe',NULL,'8669 Pansy Curve',NULL,NULL,NULL,'Konopelskiport','NE','15126','USA','0885735069');
CALL InsUpStdCustomerSp (NULL,'Bianka','Feeney',NULL,'0958 Rigoberto Trail',NULL,NULL,NULL,'Buckstad','WI','30346','USA','6795644102');
CALL InsUpStdCustomerSp (NULL,'Alison','Prosacco',NULL,'1827 Corwin Shore',NULL,NULL,NULL,'New Margaritaport','IN','64925','USA','8653465024');
CALL InsUpStdCustomerSp (NULL,'Kallie','Wiza',NULL,'78326 Kelley Lodge',NULL,NULL,NULL,'Port Maxiechester','CO','24311','USA','6868884105');
CALL InsUpStdCustomerSp (NULL,'Derick','Haag',NULL,'0128 Kelli Plain',NULL,NULL,NULL,'Katarinaside','IN','74964','USA','1841588944');
CALL InsUpStdCustomerSp (NULL,'Jaime','Aufderhar',NULL,'1598 Vena Dale',NULL,NULL,NULL,'North Jenaberg','NE','78509','USA','1226726913');
CALL InsUpStdCustomerSp (NULL,'Ardella','Romaguera',NULL,'5951 Ladarius Expressway',NULL,NULL,NULL,'Bernierchester','IL','19851','USA','1075495764');
CALL InsUpStdCustomerSp (NULL,'Clare','Bartoletti',NULL,'77698 Terry Villages',NULL,NULL,NULL,'Jonatanberg','NE','80396','USA','3531353463');
CALL InsUpStdCustomerSp (NULL,'Laney','Prosacco',NULL,'86275 Nader Views',NULL,NULL,NULL,'Koelpinland','NO','26924','USA','1476027163');
CALL InsUpStdCustomerSp (NULL,'Lela','Lang',NULL,'542 Glennie Causeway',NULL,NULL,NULL,'Madelynnmouth','OR','49926','USA','2749519766');
CALL InsUpStdCustomerSp (NULL,'Mikel','Reynolds',NULL,'6309 Dicki Gardens',NULL,NULL,NULL,'Lake Gaetano','GE','81639','USA','9410674842');
CALL InsUpStdCustomerSp (NULL,'Halie','Kub',NULL,'0241 Georgiana Forge',NULL,NULL,NULL,'Enosfort','WE','31310','USA','1899228636');
CALL InsUpStdCustomerSp (NULL,'Cortney','Zemlak',NULL,'64744 Roosevelt Fords',NULL,NULL,NULL,'Janessatown','WY','79255','USA','1563271931');
CALL InsUpStdCustomerSp (NULL,'Logan','Schneider',NULL,'71086 Marielle Neck',NULL,NULL,NULL,'Lakintown','KE','15394','USA','2738672351');
CALL InsUpStdCustomerSp (NULL,'Cleora','Krajcik',NULL,'3164 Walter Road',NULL,NULL,NULL,'Gretaside','NE','09636','USA','1629751705');
CALL InsUpStdCustomerSp (NULL,'Nathen','Bins',NULL,'893 Hammes Gateway',NULL,NULL,NULL,'Broderickville','HA','12176','USA','0567364640');
CALL InsUpStdCustomerSp (NULL,'Geoffrey','Feest',NULL,'230 Moriah Spur',NULL,NULL,NULL,'Lake Breanne','MI','94208','USA','9003881499');
CALL InsUpStdCustomerSp (NULL,'Khalil','Kilback',NULL,'050 Stamm Viaduct',NULL,NULL,NULL,'Boehmchester','VE','86094','USA','2355433186');
CALL InsUpStdCustomerSp (NULL,'Joannie','Deckow',NULL,'32178 Bahringer Roads',NULL,NULL,NULL,'Oleland','AL','99437','USA','3402317767');
CALL InsUpStdCustomerSp (NULL,'Howard','Friesen',NULL,'650 Estelle Mountain',NULL,NULL,NULL,'Conorfurt','WY','60952','USA','6651242537');
CALL InsUpStdCustomerSp (NULL,'Lempi','Fay',NULL,'860 Halle Wells',NULL,NULL,NULL,'Lake Wainohaven','NE','76588','USA','1716176646');
CALL InsUpStdCustomerSp (NULL,'Arlo','Mertz',NULL,'7821 Hermann Spring',NULL,NULL,NULL,'South Chadd','SO','71211','USA','5542330742');
CALL InsUpStdCustomerSp (NULL,'Savannah','Kilback',NULL,'7725 Corwin Forge',NULL,NULL,NULL,'Roxaneberg','IO','96811','USA','1795340182');
CALL InsUpStdCustomerSp (NULL,'Ayla','Langworth',NULL,'51837 Mante Forest',NULL,NULL,NULL,'West Jarredtown','AR','44284','USA','1447214898');
CALL InsUpStdCustomerSp (NULL,'Lacy','Witting',NULL,'7678 Weissnat Valley',NULL,NULL,NULL,'Gulgowskiburgh','OK','96560','USA','1522458163');
CALL InsUpStdCustomerSp (NULL,'Thurman','Swaniawski',NULL,'9087 Keenan Squares',NULL,NULL,NULL,'Rutherfordstad','OH','40119','USA','1355793560');
CALL InsUpStdCustomerSp (NULL,'Wyatt','Armstrong',NULL,'1467 Greenfelder Divide',NULL,NULL,NULL,'West Izaiah','MA','08649','USA','1187461275');
CALL InsUpStdCustomerSp (NULL,'Einar','Kutch',NULL,'1914 Lakin Square',NULL,NULL,NULL,'North Mitchellbury','OH','67170','USA','2275869205');
CALL InsUpStdCustomerSp (NULL,'Estell','Keeling',NULL,'26710 Steuber Port',NULL,NULL,NULL,'North Aisha','MI','10466','USA','1288164662');
CALL InsUpStdCustomerSp (NULL,'Jimmie','Ritchie',NULL,'11068 Kylee Island',NULL,NULL,NULL,'West Cletus','AL','46747','USA','7554454674');
CALL InsUpStdCustomerSp (NULL,'Javon','Zboncak',NULL,'0841 Lindsey Islands',NULL,NULL,NULL,'Lake Savannahmouth','NE','98407','USA','1154393530');
CALL InsUpStdCustomerSp (NULL,'Clifford','Volkman',NULL,'68835 Roxanne Squares',NULL,NULL,NULL,'Minervamouth','ID','1577','USA','1300339977');
CALL InsUpStdCustomerSp (NULL,'Deborah','Miller',NULL,'23098 Baby Fall',NULL,NULL,NULL,'West Alexandraborough','WE','8619','USA','7491912367');
CALL InsUpStdCustomerSp (NULL,'Earnestine','Simonis',NULL,'98991 Gorczany Mills',NULL,NULL,NULL,'South Nia','WY','93232','USA','0755867013');
CALL InsUpStdCustomerSp (NULL,'April','Kuhic',NULL,'06441 Langosh Rue',NULL,NULL,NULL,'Cassandreside','KA','87594','USA','4415248971');
CALL InsUpStdCustomerSp (NULL,'Nella','Wiegand',NULL,'7333 Libbie Ramp',NULL,NULL,NULL,'Velvaland','NO','44047','USA','7176393591');
CALL InsUpStdCustomerSp (NULL,'Flo','Gislason',NULL,'2605 Hilbert Islands',NULL,NULL,NULL,'West Jodiestad','MI','63508','USA','0375204955');
CALL InsUpStdCustomerSp (NULL,'Maryam','Kessler',NULL,'0113 Krajcik Roads',NULL,NULL,NULL,'Rolfsonhaven','CO','10308','USA','3590367091');
CALL InsUpStdCustomerSp (NULL,'Patrick','Denesik',NULL,'6772 Dalton Green',NULL,NULL,NULL,'South Maxine','SO','89398','USA','1671239928');
CALL InsUpStdCustomerSp (NULL,'Alivia','Hills',NULL,'7458 Neoma Loaf',NULL,NULL,NULL,'West Luisahaven','NO','97663','USA','3111662184');
CALL InsUpStdCustomerSp (NULL,'Palma','Bins',NULL,'894 Eula Fort',NULL,NULL,NULL,'North Jodie','NE','47276','USA','1164135287');
CALL InsUpStdCustomerSp (NULL,'Casimir','Zemlak',NULL,'914 Hand Cape',NULL,NULL,NULL,'Bergeberg','IO','23766','USA','4271872647');
CALL InsUpStdCustomerSp (NULL,'April','Flatley',NULL,'154 Annabelle Manor',NULL,NULL,NULL,'Romaguerafurt','VI','41271','USA','1239744902');
CALL InsUpStdCustomerSp (NULL,'Hallie','Fadel',NULL,'44493 Kathlyn Isle',NULL,NULL,NULL,'Bereniceport','LO','56781','USA','2062449997');
CALL InsUpStdCustomerSp (NULL,'Aimee','Cartwright',NULL,'28008 Kacey Underpass',NULL,NULL,NULL,'New Desmond','MI','60121','USA','7807664812');
CALL InsUpStdCustomerSp (NULL,'Ulices','Treutel',NULL,'84284 Addie Common',NULL,NULL,NULL,'Russelville','NE','36941','USA','5585241764');
CALL InsUpStdCustomerSp (NULL,'Santa','Berge',NULL,'1954 Turcotte Rapid',NULL,NULL,NULL,'Harrisville','MI','61965','USA','7175876791');
CALL InsUpStdCustomerSp (NULL,'Magdalena','Kuhlman',NULL,'833 Eldon Islands',NULL,NULL,NULL,'Kochstad','AR','96628','USA','9066708398');
CALL InsUpStdCustomerSp (NULL,'Kattie','Becker',NULL,'2248 Savannah Extension',NULL,NULL,NULL,'Spinkahaven','FL','47704','USA','2325675182');
CALL InsUpStdCustomerSp (NULL,'Aliyah','Lind',NULL,'05195 Genesis Rapid',NULL,NULL,NULL,'Port Boyd','NO','09425','USA','1872285466');
CALL InsUpStdCustomerSp (NULL,'Gennaro','Bosco',NULL,'03729 Odie Viaduct',NULL,NULL,NULL,'Maximusburgh','IO','24172','USA','3627728974');
CALL InsUpStdCustomerSp (NULL,'Sheldon','Quitzon',NULL,'9391 Mertz Port',NULL,NULL,NULL,'Kanebury','TE','15886','USA','2751297188');
CALL InsUpStdCustomerSp (NULL,'Alene','Russel',NULL,'3573 Pagac Coves',NULL,NULL,NULL,'New Alexandria','MI','63808','USA','1859041810');
CALL InsUpStdCustomerSp (NULL,'Esmeralda','Hoeger',NULL,'967 Quincy Crescent',NULL,NULL,NULL,'Crooksfort','SO','50852','USA','7463932638');
CALL InsUpStdCustomerSp (NULL,'Arno','Crona',NULL,'15488 Lakin Shores',NULL,NULL,NULL,'New Abbeyshire','GE','72042','USA','6660931415');
CALL InsUpStdCustomerSp (NULL,'Verona','Gerlach',NULL,'44446 Alex Wells',NULL,NULL,NULL,'East Geovannychester','AL','80137','USA','9395716705');
CALL InsUpStdCustomerSp (NULL,'Lorna','Cole',NULL,'387 Greenholt Valley',NULL,NULL,NULL,'Gloverchester','IN','30061','USA','5155854687');
CALL InsUpStdCustomerSp (NULL,'Ubaldo','Hessel',NULL,'243 Jewess River',NULL,NULL,NULL,'Haagstad','PE','15965','USA','3426381063');
CALL InsUpStdCustomerSp (NULL,'Antonette','Waters',NULL,'5594 Schowalter Crossing',NULL,NULL,NULL,'Aubreestad','LO','30219','USA','2541337752');
CALL InsUpStdCustomerSp (NULL,'Liana','Reynolds',NULL,'90718 Nikolaus Coves',NULL,NULL,NULL,'Port Rylan','DE','4837','USA','2688808515');
CALL InsUpStdCustomerSp (NULL,'Micah','Effertz',NULL,'7606 Blanda Terrace',NULL,NULL,NULL,'Runolfssonton','NE','57805','USA','2923537006');
CALL InsUpStdCustomerSp (NULL,'Tommie','Beier',NULL,'83350 Aniya Parkways',NULL,NULL,NULL,'Port Rubyhaven','OK','06237','USA','8216123682');
CALL InsUpStdCustomerSp (NULL,'Kailyn','Bailey',NULL,'1824 Maia Drive',NULL,NULL,NULL,'North Juliemouth','NE','78983','USA','6186094208');
CALL InsUpStdCustomerSp (NULL,'Cleve','Herzog',NULL,'8119 Isaiah Centers',NULL,NULL,NULL,'South Norbertofort','HA','99491','USA','1944812159');
CALL InsUpStdCustomerSp (NULL,'Fleta','Greenfelder',NULL,'26234 Jerald Meadow',NULL,NULL,NULL,'West Robb','CA','20404','USA','1778910042');
CALL InsUpStdCustomerSp (NULL,'Miracle','Wolff',NULL,'837 Clinton Station',NULL,NULL,NULL,'South Immanuel','NE','30344','USA','7921890844');
CALL InsUpStdCustomerSp (NULL,'Monty','Okuneva',NULL,'49872 Clinton Mill',NULL,NULL,NULL,'West Adrian','IN','67192','USA','7285365078');
CALL InsUpStdCustomerSp (NULL,'Kevin','Wuckert',NULL,'58488 Beier Locks',NULL,NULL,NULL,'Port Reeceview','TE','29537','USA','1726311673');
CALL InsUpStdCustomerSp (NULL,'Grant','Johnston',NULL,'83629 Ahmed Fork',NULL,NULL,NULL,'Busterbury','MI','77274','USA','0451096981');
CALL InsUpStdCustomerSp (NULL,'Geoffrey','Tremblay',NULL,'835 Addie Orchard',NULL,NULL,NULL,'Carmelshire','CA','10647','USA','6145884469');
CALL InsUpStdCustomerSp (NULL,'Dena','Armstrong',NULL,'9713 Davion Underpass',NULL,NULL,NULL,'Lake Carlie','PE','95451','USA','1743097485');
CALL InsUpStdCustomerSp (NULL,'Ariel','Wiza',NULL,'407 Satterfield Corner',NULL,NULL,NULL,'Vonberg','NE','92786','USA','5948391497');
CALL InsUpStdCustomerSp (NULL,'Claud','Cormier',NULL,'966 Howell Drive',NULL,NULL,NULL,'Lake Ocie','CA','91464','USA','6117904637');
CALL InsUpStdCustomerSp (NULL,'Edd','Schowalter',NULL,'3442 Boyer Well',NULL,NULL,NULL,'Eldafort','SO','92684','USA','2826139715');
CALL InsUpStdCustomerSp (NULL,'Jameson','Adams',NULL,'61233 Daron Walk',NULL,NULL,NULL,'Lake Elbert','NO','67319','USA','7492240971');
CALL InsUpStdCustomerSp (NULL,'Orville','Dickinson',NULL,'5856 Zita Pine',NULL,NULL,NULL,'Gulgowskistad','MI','90749','USA','4907320159');
CALL InsUpStdCustomerSp (NULL,'Micheal','Torphy',NULL,'2276 Boyle Garden',NULL,NULL,NULL,'New Jaclynmouth','GE','82042','USA','1709461050');
CALL InsUpStdCustomerSp (NULL,'Caesar','Reynolds',NULL,'3962 Wisoky Lane',NULL,NULL,NULL,'Madonnachester','WE','21748','USA','1030101746');
CALL InsUpStdCustomerSp (NULL,'Willy','Ratke',NULL,'2135 Marianne River',NULL,NULL,NULL,'Seanton','MI','37665','USA','1931272617');
CALL InsUpStdCustomerSp (NULL,'Sheridan','Windler',NULL,'310 Jolie Stravenue',NULL,NULL,NULL,'North Ivah','OR','64413','USA','0841458878');
CALL InsUpStdCustomerSp (NULL,'Peggie','Smitham',NULL,'5699 Helen Viaduct',NULL,NULL,NULL,'Dillanchester','MA','9138','USA','0999606146');
CALL InsUpStdCustomerSp (NULL,'Jamarcus','Abernathy',NULL,'687 Josiane Road',NULL,NULL,NULL,'Dawsonshire','WI','48510','USA','4431230466');
CALL InsUpStdCustomerSp (NULL,'Robert','Walsh',NULL,'229 Kuhn Meadows',NULL,NULL,NULL,'Braunville','NE','33086','USA','8127712262');
CALL InsUpStdCustomerSp (NULL,'Tristin','Lynch',NULL,'8071 Shyann Springs',NULL,NULL,NULL,'Schneiderborough','KA','39342','USA','9493035565');
CALL InsUpStdCustomerSp (NULL,'Faustino','Langosh',NULL,'4639 Beer Mission',NULL,NULL,NULL,'Port Trishachester','SO','53027','USA','9638608922');
CALL InsUpStdCustomerSp (NULL,'Samara','Cole',NULL,'99103 Candelario Isle',NULL,NULL,NULL,'Mauriceshire','GE','85150','USA','2582137029');
CALL InsUpStdCustomerSp (NULL,'Imelda','Mohr',NULL,'737 Pollich Trail',NULL,NULL,NULL,'Beatriceton','AL','64454','USA','6040983433');
CALL InsUpStdCustomerSp (NULL,'Alba','McClure',NULL,'651 Javonte Street',NULL,NULL,NULL,'Streichville','HA','87550','USA','1119153191');
CALL InsUpStdCustomerSp (NULL,'Martina','Fisher',NULL,'26362 Greenholt Parkway',NULL,NULL,NULL,'Rosalynview','WE','97470','USA','8422956341');
CALL InsUpStdCustomerSp (NULL,'Nicole','Ryan',NULL,'08134 Funk Shores',NULL,NULL,NULL,'West Jordi','TE','79789','USA','5942589207');
CALL InsUpStdCustomerSp (NULL,'Abner','Denesik',NULL,'13131 Vernie Mount',NULL,NULL,NULL,'North Gregoriaside','UT','04047','USA','1330481258');
CALL InsUpStdCustomerSp (NULL,'Elaina','Zieme',NULL,'447 Welch Alley',NULL,NULL,NULL,'Bartonberg','IO','14974','USA','1215781866');
CALL InsUpStdCustomerSp (NULL,'Ralph','Conn',NULL,'2442 Cruickshank Parkways',NULL,NULL,NULL,'West Hassanshire','AL','76206','USA','5511089559');
CALL InsUpStdCustomerSp (NULL,'Ola','Stokes',NULL,'12099 Anahi Prairie',NULL,NULL,NULL,'Lake Monteville','GE','02557','USA','4132192487');
CALL InsUpStdCustomerSp (NULL,'Alvis','Schiller',NULL,'530 Gleichner Motorway',NULL,NULL,NULL,'Lonzomouth','CO','48606','USA','1968226718');
CALL InsUpStdCustomerSp (NULL,'Orlo','Bosco',NULL,'17477 Janie Wells',NULL,NULL,NULL,'New Kayceebury','MA','62699','USA','1715330575');
CALL InsUpStdCustomerSp (NULL,'Vesta','Windler',NULL,'791 Wiza Drive',NULL,NULL,NULL,'Padbergside','KA','46006','USA','1975031521');
CALL InsUpStdCustomerSp (NULL,'Levi','Boyle',NULL,'17535 Kaylee Forge',NULL,NULL,NULL,'Raphaelleside','IO','21093','USA','4362729478');
CALL InsUpStdCustomerSp (NULL,'Flossie','Bruen',NULL,'9013 Bins Ranch',NULL,NULL,NULL,'Treutelstad','OH','11632','USA','1754677847');
CALL InsUpStdCustomerSp (NULL,'Lura','Weimann',NULL,'12068 Carlie Gardens',NULL,NULL,NULL,'North Jerrold','NO','57134','USA','8081287582');
CALL InsUpStdCustomerSp (NULL,'Paxton','Swaniawski',NULL,'0937 Terrell Overpass',NULL,NULL,NULL,'South Ewaldside','GE','81777','USA','6388166668');
CALL InsUpStdCustomerSp (NULL,'Marcelino','Schmidt',NULL,'29251 Jast Squares',NULL,NULL,NULL,'Dietrichfurt','OR','85133','USA','0592719848');
CALL InsUpStdCustomerSp (NULL,'Mallie','Rohan',NULL,'97325 Bartell Way',NULL,NULL,NULL,'West Evelynmouth','WY','48179','USA','1909497585');
CALL InsUpStdCustomerSp (NULL,'Vivian','Bosco',NULL,'544 Zachary Flats',NULL,NULL,NULL,'Wardport','NE','9200','USA','4369075529');
CALL InsUpStdCustomerSp (NULL,'Sigrid','Kemmer',NULL,'22834 Hilll Walk',NULL,NULL,NULL,'East Patrickside','MI','40911','USA','4409812310');
CALL InsUpStdCustomerSp (NULL,'Jewell','Veum',NULL,'0714 Claire Wells',NULL,NULL,NULL,'Pedroport','VE','03001','USA','7996093383');
CALL InsUpStdCustomerSp (NULL,'Hattie','Harªann',NULL,'3246 Ritchie Inlet',NULL,NULL,NULL,'North Vaughnstad','VE','40686','USA','8137711844');
CALL InsUpStdCustomerSp (NULL,'Liliana','Larson',NULL,'2978 Runolfsson Greens',NULL,NULL,NULL,'West Shealand','WY','53830','USA','0471858921');
CALL InsUpStdCustomerSp (NULL,'Deborah','Wintheiser',NULL,'1577 Rosemary Well',NULL,NULL,NULL,'Daphneybury','AR','57132','USA','0862548111');
CALL InsUpStdCustomerSp (NULL,'Sammy','Torp',NULL,'6663 Paul Unions',NULL,NULL,NULL,'Wilsonfort','MA','16446','USA','5268356537');
CALL InsUpStdCustomerSp (NULL,'Casey','Corkery',NULL,'0920 Icie Wells',NULL,NULL,NULL,'Hillardside','AL','00308','USA','2607372614');
CALL InsUpStdCustomerSp (NULL,'Cecile','Ratke',NULL,'6236 Rath Dam',NULL,NULL,NULL,'New Coraview','WA','58035','USA','3314279268');
CALL InsUpStdCustomerSp (NULL,'Letitia','Schuppe',NULL,'9041 Yolanda Lane',NULL,NULL,NULL,'Lincolnberg','TE','39349','USA','1265288549');
CALL InsUpStdCustomerSp (NULL,'Veronica','Larson',NULL,'966 Rowe Cove',NULL,NULL,NULL,'Mohrhaven','MA','75918','USA','2265686099');
CALL InsUpStdCustomerSp (NULL,'Emma','Lynch',NULL,'362 Littel Canyon',NULL,NULL,NULL,'South Glenda','ID','40171','USA','9430300539');
CALL InsUpStdCustomerSp (NULL,'Gertrude','Rosenbaum',NULL,'42160 Ludie Light',NULL,NULL,NULL,'Port Sylvester','NE','76655','USA','9719951608');
CALL InsUpStdCustomerSp (NULL,'Marian','Prohaska',NULL,'463 Tyrese Rapid',NULL,NULL,NULL,'East Omatown','CA','8071','USA','0280647208');
CALL InsUpStdCustomerSp (NULL,'Cynthia','Homenick',NULL,'90469 Ethelyn Loop',NULL,NULL,NULL,'Ernserland','MI','95977','USA','9057906769');
CALL InsUpStdCustomerSp (NULL,'Niko','Yost',NULL,'92318 Keira Run',NULL,NULL,NULL,'West Ona','SO','21328','USA','8102454470');
CALL InsUpStdCustomerSp (NULL,'Jett','OKeefe',NULL,'38299 Langworth Lodge',NULL,NULL,NULL,'Laneyside','VE','68449','USA','3947166543');
CALL InsUpStdCustomerSp (NULL,'Maymie','Hilll',NULL,'305 Franz Isle',NULL,NULL,NULL,'Loistown','NE','18868','USA','3414680546');
CALL InsUpStdCustomerSp (NULL,'Levi','Howe',NULL,'36676 Ryleigh Radial',NULL,NULL,NULL,'Brekkemouth','MA','63608','USA','2837325921');
CALL InsUpStdCustomerSp (NULL,'Buck','Douglas',NULL,'945 Klein Heights',NULL,NULL,NULL,'Lake Caylabury','VE','64503','USA','4121925969');
CALL InsUpStdCustomerSp (NULL,'Leora','Champlin',NULL,'8429 Thomas Underpass',NULL,NULL,NULL,'East Dollybury','MA','38805','USA','1348110330');
CALL InsUpStdCustomerSp (NULL,'Deron','Morar',NULL,'6755 Ward Underpass',NULL,NULL,NULL,'Raynorborough','NO','03104','USA','6102404041');
CALL InsUpStdCustomerSp (NULL,'Gracie','Jacobi',NULL,'145 Arlene Grove',NULL,NULL,NULL,'Dickenston','KA','3337','USA','6650998020');
CALL InsUpStdCustomerSp (NULL,'Stewart','Hagenes',NULL,'949 Vicky Forks',NULL,NULL,NULL,'Raynorchester','IO','82358','USA','9642529256');
CALL InsUpStdCustomerSp (NULL,'Laurine','Little',NULL,'627 Carmel Forges',NULL,NULL,NULL,'South Hassieport','KE','03273','USA','3367760639');
CALL InsUpStdCustomerSp (NULL,'Clyde','Murazik',NULL,'134 Parisian Spurs',NULL,NULL,NULL,'New Shawnaside','AL','00504','USA','0021793255');
CALL InsUpStdCustomerSp (NULL,'Juliet','Bauch',NULL,'5409 Murphy Isle',NULL,NULL,NULL,'New Jonmouth','VE','25132','USA','8857927710');
CALL InsUpStdCustomerSp (NULL,'Kassandra','Braun',NULL,'445 Legros Light',NULL,NULL,NULL,'Hackettbury','NE','69772','USA','0945158224');
CALL InsUpStdCustomerSp (NULL,'Colten','Nienow',NULL,'95536 Streich Stream',NULL,NULL,NULL,'South Ursulahaven','NE','23781','USA','1048384754');
CALL InsUpStdCustomerSp (NULL,'Adolf','Weissnat',NULL,'87043 Rau Avenue',NULL,NULL,NULL,'Ewellfort','NE','42061','USA','1420442929');
CALL InsUpStdCustomerSp (NULL,'Janie','Crona',NULL,'6156 Jovanny Via',NULL,NULL,NULL,'Hermanville','NE','43737','USA','2091157219');
CALL InsUpStdCustomerSp (NULL,'Gerardo','Spencer',NULL,'518 Torp River',NULL,NULL,NULL,'Markstown','AL','3656','USA','2281293679');
CALL InsUpStdCustomerSp (NULL,'Llewellyn','Kuhlman',NULL,'8508 OKeefe Trail',NULL,NULL,NULL,'West Rebekahside','MA','66813','USA','1655908594');
CALL InsUpStdCustomerSp (NULL,'Alexandria','McDermott',NULL,'35301 Haag Mount',NULL,NULL,NULL,'South Orlomouth','DE','52521','USA','3115603461');
CALL InsUpStdCustomerSp (NULL,'Ryan','Senger',NULL,'7893 Schuppe Corner',NULL,NULL,NULL,'Bruenland','IO','69668','USA','1349072900');
CALL InsUpStdCustomerSp (NULL,'Candida','Denesik',NULL,'2592 Bartoletti Forge',NULL,NULL,NULL,'Waelchimouth','IO','62418','USA','4239338509');
CALL InsUpStdCustomerSp (NULL,'Danny','Mayert',NULL,'6718 Teresa Plaza',NULL,NULL,NULL,'West Christop','MO','32604','USA','8680979982');
CALL InsUpStdCustomerSp (NULL,'Trace','Thiel',NULL,'404 Dino Mall',NULL,NULL,NULL,'Gleichnerfort','OK','06560','USA','8441122566');
CALL InsUpStdCustomerSp (NULL,'Devyn','Haley',NULL,'1179 Gregorio Club',NULL,NULL,NULL,'North Dewayne','MI','64623','USA','1795447403');
CALL InsUpStdCustomerSp (NULL,'Darian','Sanford',NULL,'0142 Fritsch Orchard',NULL,NULL,NULL,'Port Toneymouth','MI','78973','USA','6329849748');
CALL InsUpStdCustomerSp (NULL,'Jolie','Ebert',NULL,'022 Beier Vista',NULL,NULL,NULL,'West Estherfurt','OK','91147','USA','4473693742');
CALL InsUpStdCustomerSp (NULL,'Ryley','Lang',NULL,'7531 Sipes Estates',NULL,NULL,NULL,'Lake Elainatown','KA','96159','USA','1405907693');
CALL InsUpStdCustomerSp (NULL,'Madelynn','Bahringer',NULL,'9623 Jaleel Drive',NULL,NULL,NULL,'Lake Eldon','RH','28303','USA','4418262818');
CALL InsUpStdCustomerSp (NULL,'Eldred','Steuber',NULL,'635 Aleen Drives',NULL,NULL,NULL,'Port Robertomouth','MA','21712','USA','2485214249');
CALL InsUpStdCustomerSp (NULL,'Laverna','Koelpin',NULL,'412 Stephany Plains',NULL,NULL,NULL,'Kuhlmanburgh','IN','13358','USA','6206026187');
CALL InsUpStdCustomerSp (NULL,'Garett','Kling',NULL,'49582 Germaine Light',NULL,NULL,NULL,'Binsport','CO','52848','USA','1069122186');
CALL InsUpStdCustomerSp (NULL,'Isac','Skiles',NULL,'6597 Liam Ramp',NULL,NULL,NULL,'North Nilsberg','TE','56833','USA','5736483032');
CALL InsUpStdCustomerSp (NULL,'Russel','Oberbrunner',NULL,'306 Renner Trail',NULL,NULL,NULL,'Goyetteview','MI','62272','USA','9463649519');
CALL InsUpStdCustomerSp (NULL,'Yadira','Stark',NULL,'143 Stokes Fords',NULL,NULL,NULL,'North Eliezer','OK','59568','USA','1851143844');
CALL InsUpStdCustomerSp (NULL,'Carolyn','Predovic',NULL,'3525 Marcelina Squares',NULL,NULL,NULL,'New Maeve','AR','47897','USA','5248712967');
CALL InsUpStdCustomerSp (NULL,'Ernest','Botsford',NULL,'878 Schultz Roads',NULL,NULL,NULL,'Kiaraland','SO','48788','USA','1994590168');
CALL InsUpStdCustomerSp (NULL,'Benton','Boehm',NULL,'601 Jacobson Hill',NULL,NULL,NULL,'Pollichhaven','IN','09224','USA','1625241626');
CALL InsUpStdCustomerSp (NULL,'Timmothy','Hettinger',NULL,'219 Florence Ridge',NULL,NULL,NULL,'New Kevonfurt','CA','86476','USA','5105385696');
CALL InsUpStdCustomerSp (NULL,'Orville','Prosacco',NULL,'42677 Amelia Stravenue',NULL,NULL,NULL,'South Vincenzochester','MI','74165','USA','6543134812');
CALL InsUpStdCustomerSp (NULL,'Nicholas','Schmidt',NULL,'4294 Adell Parks',NULL,NULL,NULL,'Yazminside','IN','48541','USA','5651281213');
CALL InsUpStdCustomerSp (NULL,'Rico','Halvorson',NULL,'925 Amara Forges',NULL,NULL,NULL,'South Dena','NE','62688','USA','4037290590');
CALL InsUpStdCustomerSp (NULL,'Lazaro','Murazik',NULL,'5953 Brisa Field',NULL,NULL,NULL,'Macmouth','TE','73360','USA','1130091399');
CALL InsUpStdCustomerSp (NULL,'Mohammed','Will',NULL,'173 Valentin Fords',NULL,NULL,NULL,'North Kelsi','NE','88726','USA','2082090536');
CALL InsUpStdCustomerSp (NULL,'Emilio','Ferry',NULL,'953 Tromp Island',NULL,NULL,NULL,'Port Soledad','AR','49529','USA','1158391610');
CALL InsUpStdCustomerSp (NULL,'Bobbie','Wiza',NULL,'55283 Haag Isle',NULL,NULL,NULL,'Lake Tomasa','NE','39923','USA','7859989296');
CALL InsUpStdCustomerSp (NULL,'Jonas','Rutherford',NULL,'63184 Block Lodge',NULL,NULL,NULL,'South Autumnview','CO','20404','USA','2097216474');
CALL InsUpStdCustomerSp (NULL,'Demetrius','Gislason',NULL,'98847 Gerlach Stream',NULL,NULL,NULL,'East Roman','AL','36652','USA','1737866327');
CALL InsUpStdCustomerSp (NULL,'Amalia','VonRueden',NULL,'31201 Harvey Estates',NULL,NULL,NULL,'Port Aglae','GE','31028','USA','9131996941');
CALL InsUpStdCustomerSp (NULL,'Stacy','Koch',NULL,'452 Emard Rest',NULL,NULL,NULL,'Franeckiberg','CA','56082','USA','0656431873');
CALL InsUpStdCustomerSp (NULL,'Mercedes','Zieme',NULL,'218 Elda Station',NULL,NULL,NULL,'Earnestbury','UT','34392','USA','9730846703');
CALL InsUpStdCustomerSp (NULL,'Maxine','Hansen',NULL,'341 Mallory Greens',NULL,NULL,NULL,'Conroyton','MO','44773','USA','1629912150');
CALL InsUpStdCustomerSp (NULL,'Myrtle','Bruen',NULL,'5503 Benton Spurs',NULL,NULL,NULL,'New Laury','WA','40333','USA','1518095890');
CALL InsUpStdCustomerSp (NULL,'Maeve','Rowe',NULL,'8747 Bins Ports',NULL,NULL,NULL,'West Zoila','KE','50276','USA','6219196068');
CALL InsUpStdCustomerSp (NULL,'Ozella','Mayert',NULL,'398 Ashleigh Groves',NULL,NULL,NULL,'South Fidelfort','LO','28566','USA','5478911794');
CALL InsUpStdCustomerSp (NULL,'Lenny','Terry',NULL,'31032 Carmel Mews',NULL,NULL,NULL,'North Kareem','NE','58970','USA','3960971904');
CALL InsUpStdCustomerSp (NULL,'Nigel','Ondricka',NULL,'02725 Baumbach Highway',NULL,NULL,NULL,'Port Era','HA','12347','USA','2853821779');
CALL InsUpStdCustomerSp (NULL,'Delpha','Wintheiser',NULL,'048 Rafaela Point',NULL,NULL,NULL,'Zacharyburgh','TE','53688','USA','9290788091');
CALL InsUpStdCustomerSp (NULL,'Hillard','Harªann',NULL,'036 Collier Loaf',NULL,NULL,NULL,'Selenaport','NO','83798','USA','7126615806');
CALL InsUpStdCustomerSp (NULL,'Mortimer','Huel',NULL,'5079 Schmeler Camp',NULL,NULL,NULL,'Jodiechester','MI','93624','USA','1515004706');
CALL InsUpStdCustomerSp (NULL,'Justice','Auer',NULL,'2558 Conroy Harbors',NULL,NULL,NULL,'Royalville','NO','84381','USA','3944839786');
CALL InsUpStdCustomerSp (NULL,'Janie','Murazik',NULL,'60280 Alivia Turnpike',NULL,NULL,NULL,'Mikelfort','MA','80724','USA','2608248150');
CALL InsUpStdCustomerSp (NULL,'Charlie','Hyatt',NULL,'287 Swaniawski Extension',NULL,NULL,NULL,'West Wayneton','VI','27098','USA','2532343074');
CALL InsUpStdCustomerSp (NULL,'Asha','White',NULL,'458 Stoltenberg Spurs',NULL,NULL,NULL,'Ellaview','NE','40357','USA','7493523097');
CALL InsUpStdCustomerSp (NULL,'Anabelle','Morar',NULL,'055 Patience Villages',NULL,NULL,NULL,'Port Martinabury','WI','93630','USA','1041895036');
CALL InsUpStdCustomerSp (NULL,'Christop','Boehm',NULL,'6332 Rowland Corner',NULL,NULL,NULL,'Reingerview','UT','52621','USA','3670493009');
CALL InsUpStdCustomerSp (NULL,'Kristian','Hand',NULL,'46286 Erna Streets',NULL,NULL,NULL,'Maritzamouth','TE','44636','USA','7454862244');
CALL InsUpStdCustomerSp (NULL,'Tevin','Kohler',NULL,'13319 Feil Street',NULL,NULL,NULL,'Lynchchester','NE','95629','USA','0511628627');
CALL InsUpStdCustomerSp (NULL,'Diamond','Padberg',NULL,'5770 Davis Corner',NULL,NULL,NULL,'East Nikoport','MA','69386','USA','5042662654');
CALL InsUpStdCustomerSp (NULL,'Cordie','Schuppe',NULL,'0969 Gorczany Groves',NULL,NULL,NULL,'Augustineborough','NO','37703','USA','6402497917');
CALL InsUpStdCustomerSp (NULL,'Brandy','McCullough',NULL,'7248 Raynor Ridge',NULL,NULL,NULL,'Lindgrenfort','NE','29132','USA','3566401574');
CALL InsUpStdCustomerSp (NULL,'Juanita','Ryan',NULL,'05822 Greenfelder Estate',NULL,NULL,NULL,'Lake Curt','IL','08857','USA','6203332380');
CALL InsUpStdCustomerSp (NULL,'Kaitlyn','Blick',NULL,'5414 Schimmel Wall',NULL,NULL,NULL,'West Antonettefort','AL','84671','USA','0764009051');
CALL InsUpStdCustomerSp (NULL,'Jasmin','Lowe',NULL,'7108 Jerde Point',NULL,NULL,NULL,'Lake Kathleenville','SO','66870','USA','5730690036');
CALL InsUpStdCustomerSp (NULL,'Gloria','Upton',NULL,'42127 Jermaine Passage',NULL,NULL,NULL,'Soledadborough','MA','65827','USA','7026124028');
CALL InsUpStdCustomerSp (NULL,'Roberta','Thiel',NULL,'360 Stiedemann Pike',NULL,NULL,NULL,'Lake Miracleshire','RH','19970','USA','8279835006');
CALL InsUpStdCustomerSp (NULL,'Oleta','Langworth',NULL,'227 Alison Port',NULL,NULL,NULL,'South Devin','NE','26730','USA','1783663884');
CALL InsUpStdCustomerSp (NULL,'Delfina','Casper',NULL,'3204 Welch Gardens',NULL,NULL,NULL,'Casperton','PE','91277','USA','1125287622');
CALL InsUpStdCustomerSp (NULL,'Rebekah','McGlynn',NULL,'77208 Lockman Mission',NULL,NULL,NULL,'Lake Yasmeenberg','NO','74844','USA','8027045680');
CALL InsUpStdCustomerSp (NULL,'Elouise','Simonis',NULL,'308 Friesen Trafficway',NULL,NULL,NULL,'Emardfurt','NO','1316','USA','1884085266');
CALL InsUpStdCustomerSp (NULL,'Thaddeus','Roberts',NULL,'585 Ashtyn Island',NULL,NULL,NULL,'South Rutheland','DE','25264','USA','7378772065');
CALL InsUpStdCustomerSp (NULL,'Esperanza','Cassin',NULL,'57403 Durgan Shoal',NULL,NULL,NULL,'South Alycia','MA','30211','USA','0950650458');
CALL InsUpStdCustomerSp (NULL,'Rowena','Schiller',NULL,'074 Friesen Oval',NULL,NULL,NULL,'East Rosendofort','MI','73120','USA','8563005037');
CALL InsUpStdCustomerSp (NULL,'Maxime','Davis',NULL,'152 Zena Port',NULL,NULL,NULL,'Lake Ardenmouth','MI','31305','USA','1143951732');
CALL InsUpStdCustomerSp (NULL,'Joannie','Purdy',NULL,'1397 Reynolds Mountain',NULL,NULL,NULL,'New Vadaville','DE','4672','USA','1988933321');
CALL InsUpStdCustomerSp (NULL,'Jettie','Wiza',NULL,'3033 Stracke Divide',NULL,NULL,NULL,'Guªannstad','NE','01448','USA','0886529109');
CALL InsUpStdCustomerSp (NULL,'Kory','Morar',NULL,'209 Kunze Greens',NULL,NULL,NULL,'Port Damionland','SO','17443','USA','5052287282');
CALL InsUpStdCustomerSp (NULL,'Willard','Satterfield',NULL,'7248 Corwin Well',NULL,NULL,NULL,'West Corineville','MA','29087','USA','9728965442');
CALL InsUpStdCustomerSp (NULL,'Scot','Runolfsdottir',NULL,'759 Kunze Garden',NULL,NULL,NULL,'New Jettton','IL','36603','USA','9845738388');
CALL InsUpStdCustomerSp (NULL,'Arch','Kshlerin',NULL,'6392 Hillary Pike',NULL,NULL,NULL,'Urielview','IO','54885','USA','7773883919');
CALL InsUpStdCustomerSp (NULL,'Ed','Gulgowski',NULL,'14780 Lang Forest',NULL,NULL,NULL,'Leuschkemouth','FL','91375','USA','7418960334');
CALL InsUpStdCustomerSp (NULL,'Dana','Hansen',NULL,'65835 Coy Roads',NULL,NULL,NULL,'Smithchester','WI','71708','USA','1222546597');
CALL InsUpStdCustomerSp (NULL,'Jazlyn','Simonis',NULL,'22165 Herman Fort',NULL,NULL,NULL,'East Tavaresborough','TE','74305','USA','1215151316');
CALL InsUpStdCustomerSp (NULL,'Bernhard','DuBuque',NULL,'779 Carmen Station',NULL,NULL,NULL,'Lake Hobartside','OH','49991','USA','5646599542');
CALL InsUpStdCustomerSp (NULL,'Lavinia','Haley',NULL,'16085 Ottis Trail',NULL,NULL,NULL,'Ezequielberg','MO','80739','USA','3301173703');
CALL InsUpStdCustomerSp (NULL,'Katelyn','Lehner',NULL,'13910 Sanford Crossroad',NULL,NULL,NULL,'Hodkiewiczfort','KE','49400','USA','1432753334');
CALL InsUpStdCustomerSp (NULL,'Jayda','Stoltenberg',NULL,'160 Auer Village',NULL,NULL,NULL,'Keshaunland','NE','60992','USA','1905517689');
CALL InsUpStdCustomerSp (NULL,'Lacey','Lang',NULL,'862 Rolando Lane',NULL,NULL,NULL,'Macborough','WY','22193','USA','3535678895');
CALL InsUpStdCustomerSp (NULL,'Willy','Gleichner',NULL,'493 Electa Roads',NULL,NULL,NULL,'West Demondview','AR','73367','USA','6195209277');
CALL InsUpStdCustomerSp (NULL,'Omari','Reinger',NULL,'1230 Adaline Plaza',NULL,NULL,NULL,'East Ruthieborough','VI','55196','USA','1064916074');
CALL InsUpStdCustomerSp (NULL,'Jesse','Beer',NULL,'014 Wisoky Locks',NULL,NULL,NULL,'Matildehaven','MI','5111','USA','3190336707');
CALL InsUpStdCustomerSp (NULL,'Dakota','Turner',NULL,'944 Alia Mall',NULL,NULL,NULL,'Kelvinstad','KA','82687','USA','8323460691');
CALL InsUpStdCustomerSp (NULL,'Josie','OKeefe',NULL,'617 Kurtis Expressway',NULL,NULL,NULL,'Lamontport','CA','45778','USA','0627257980');
CALL InsUpStdCustomerSp (NULL,'Kiarra','Hettinger',NULL,'1301 Aurelia Burgs',NULL,NULL,NULL,'East Dallasfort','CO','23469','USA','1083589544');
CALL InsUpStdCustomerSp (NULL,'Hayley','Glover',NULL,'9797 Abby Island',NULL,NULL,NULL,'New Gage','NE','08187','USA','1298285003');
CALL InsUpStdCustomerSp (NULL,'Billie','Dare',NULL,'673 Hand Glens',NULL,NULL,NULL,'North Zaria','NE','63421','USA','1275197073');
CALL InsUpStdCustomerSp (NULL,'Harmony','McGlynn',NULL,'6650 Olaf Drive',NULL,NULL,NULL,'Kunzefurt','UT','34538','USA','2429367018');
CALL InsUpStdCustomerSp (NULL,'Donny','Langosh',NULL,'114 White Dale',NULL,NULL,NULL,'Johnathonmouth','FL','9305','USA','2469662221');
CALL InsUpStdCustomerSp (NULL,'Samson','Rodriguez',NULL,'67686 Fisher Village',NULL,NULL,NULL,'South Karinefort','NO','41746','USA','5046832324');
CALL InsUpStdCustomerSp (NULL,'Everett','Jacobi',NULL,'4167 Wuckert Haven',NULL,NULL,NULL,'Zeldahaven','TE','29067','USA','0757340772');
CALL InsUpStdCustomerSp (NULL,'Wallace','Runte',NULL,'50054 Wolff Place',NULL,NULL,NULL,'New Vinniehaven','AL','07272','USA','1977166106');
CALL InsUpStdCustomerSp (NULL,'Vivien','Glover',NULL,'09061 Nikolaus Groves',NULL,NULL,NULL,'McCluretown','NE','60769','USA','1249850335');
CALL InsUpStdCustomerSp (NULL,'Geo','Kilback',NULL,'21782 Steuber Courts',NULL,NULL,NULL,'Deondreville','OH','47339','USA','1722655633');
CALL InsUpStdCustomerSp (NULL,'Kellen','Kihn',NULL,'193 Gleason Prairie',NULL,NULL,NULL,'Port Eriberto','NE','75352','USA','2400088723');
CALL InsUpStdCustomerSp (NULL,'Effie','Jewess',NULL,'621 Kay Mission',NULL,NULL,NULL,'Tillmanborough','TE','7259','USA','1597033516');
CALL InsUpStdCustomerSp (NULL,'Darlene','Walter',NULL,'3297 Melvina Passage',NULL,NULL,NULL,'Jermainefort','CO','23017','USA','1893929966');
CALL InsUpStdCustomerSp (NULL,'Novella','Casper',NULL,'582 Anahi Extension',NULL,NULL,NULL,'Lake Lavernfurt','VI','15943','USA','1838489424');
CALL InsUpStdCustomerSp (NULL,'Lawrence','Ryan',NULL,'9890 Jammie Hollow',NULL,NULL,NULL,'Jonasland','NO','66224','USA','7145409668');
CALL InsUpStdCustomerSp (NULL,'Rubie','Metz',NULL,'523 Schroeder Prairie',NULL,NULL,NULL,'West Josianne','TE','9624','USA','6691322022');
CALL InsUpStdCustomerSp (NULL,'Merl','Rempel',NULL,'7814 Flatley Lock',NULL,NULL,NULL,'Cassiestad','NO','79714','USA','1943343700');
CALL InsUpStdCustomerSp (NULL,'Kayla','Glover',NULL,'219 Paula Corners',NULL,NULL,NULL,'Kundestad','UT','28915','USA','5589022432');
CALL InsUpStdCustomerSp (NULL,'Elfrieda','Zieme',NULL,'536 Emmanuelle Crossroad',NULL,NULL,NULL,'Moorestad','NE','22079','USA','9372823860');
CALL InsUpStdCustomerSp (NULL,'Herminia','Bartell',NULL,'2275 Julie Inlet',NULL,NULL,NULL,'New Cynthiaville','RH','25163','USA','9185971322');
CALL InsUpStdCustomerSp (NULL,'Judge','Quigley',NULL,'8593 Skiles Circles',NULL,NULL,NULL,'Ferrytown','FL','24918','USA','1669909601');
CALL InsUpStdCustomerSp (NULL,'Terrence','Bins',NULL,'423 Dahlia Way',NULL,NULL,NULL,'Mullerton','TE','27468','USA','4219260787');
CALL InsUpStdCustomerSp (NULL,'Shanie','Bartell',NULL,'6776 Jaylen Villages',NULL,NULL,NULL,'Lake Bailee','FL','96086','USA','2039874005');
CALL InsUpStdCustomerSp (NULL,'Ruby','Zieme',NULL,'126 Terry Glens',NULL,NULL,NULL,'Hesselview','NO','12384','USA','2960154007');
CALL InsUpStdCustomerSp (NULL,'Delbert','Von',NULL,'99304 Mckenzie Wall',NULL,NULL,NULL,'Amelymouth','UT','61508','USA','1493964129');
CALL InsUpStdCustomerSp (NULL,'Israel','Larkin',NULL,'334 Dana Drive',NULL,NULL,NULL,'Gregoryside','MI','30335','USA','1442718285');
CALL InsUpStdCustomerSp (NULL,'Mellie','Sanford',NULL,'8792 Oma Lane',NULL,NULL,NULL,'Port Amely','KE','95815','USA','5603642812');
CALL InsUpStdCustomerSp (NULL,'Flavio','Sporer',NULL,'719 Esperanza Rapids',NULL,NULL,NULL,'Trantowmouth','MA','12636','USA','3250571894');
CALL InsUpStdCustomerSp (NULL,'Kamren','Harris',NULL,'61457 Auer Corner',NULL,NULL,NULL,'North Alexandrefurt','MI','67566','USA','2313287528');
CALL InsUpStdCustomerSp (NULL,'Bryana','Shields',NULL,'478 Boyle Port',NULL,NULL,NULL,'East Keaton','SO','25107','USA','7637278187');
CALL InsUpStdCustomerSp (NULL,'Christelle','Eichmann',NULL,'7196 Clifton Forks',NULL,NULL,NULL,'New Kaia','HA','89950','USA','8925244149');
CALL InsUpStdCustomerSp (NULL,'Pierce','Bins',NULL,'06079 Moen Ferry',NULL,NULL,NULL,'Dickistad','MI','41090','USA','8267151115');
CALL InsUpStdCustomerSp (NULL,'Kristofer','Morar',NULL,'57123 Irma Heights',NULL,NULL,NULL,'West Jerome','IN','17127','USA','7105277364');
CALL InsUpStdCustomerSp (NULL,'Albertha','Harvey',NULL,'828 Barry Run',NULL,NULL,NULL,'Romafurt','MO','21748','USA','1124287557');
CALL InsUpStdCustomerSp (NULL,'Tamara','Schmidt',NULL,'874 Koelpin Avenue',NULL,NULL,NULL,'North Raymouth','IL','64822','USA','5975836417');
CALL InsUpStdCustomerSp (NULL,'Jannie','Barrows',NULL,'351 Vinnie Trail',NULL,NULL,NULL,'South Ricobury','MA','49963','USA','5176121125');
CALL InsUpStdCustomerSp (NULL,'Aubree','Kreiger',NULL,'1342 Maggie Center',NULL,NULL,NULL,'West Frederik','LO','23322','USA','1334105033');
CALL InsUpStdCustomerSp (NULL,'Destinee','Daugherty',NULL,'72350 Patrick Trafficway',NULL,NULL,NULL,'Frederikton','OK','86415','USA','3712774393');
CALL InsUpStdCustomerSp (NULL,'Brent','Padberg',NULL,'670 Brekke Spurs',NULL,NULL,NULL,'Nyasiaville','WI','52045','USA','7711487539');
CALL InsUpStdCustomerSp (NULL,'Clay','Abernathy',NULL,'251 Klocko Cape',NULL,NULL,NULL,'East Aniyah','NE','10333','USA','4322153231');
CALL InsUpStdCustomerSp (NULL,'Parker','Lebsack',NULL,'6888 Fadel Village',NULL,NULL,NULL,'New Giovanna','WY','51115','USA','8383646356');
CALL InsUpStdCustomerSp (NULL,'Eleonore','Rath',NULL,'7849 Boyle Radial',NULL,NULL,NULL,'Fridashire','WE','64768','USA','1946086448');
CALL InsUpStdCustomerSp (NULL,'Jewell','Crona',NULL,'788 Grant Fork',NULL,NULL,NULL,'East Allantown','GE','45496','USA','3013873425');
CALL InsUpStdCustomerSp (NULL,'Koby','Veum',NULL,'1223 Carmelo Lane',NULL,NULL,NULL,'Gerlachtown','SO','7295','USA','1870547169');
CALL InsUpStdCustomerSp (NULL,'Asa','Fritsch',NULL,'6642 Melody Hollow',NULL,NULL,NULL,'Lake Yasmineview','TE','33049','USA','1783648239');
CALL InsUpStdCustomerSp (NULL,'Ebba','Heathcote',NULL,'822 Champlin Road',NULL,NULL,NULL,'Madysonfurt','MA','10546','USA','3268761526');
CALL InsUpStdCustomerSp (NULL,'Toy','Boyle',NULL,'396 Hilll Rue',NULL,NULL,NULL,'Reicherthaven','WE','97997','USA','1032309313');
CALL InsUpStdCustomerSp (NULL,'Hipolito','Hegmann',NULL,'44532 Allie Plaza',NULL,NULL,NULL,'Lake Ryder','KE','72357','USA','1620388650');
CALL InsUpStdCustomerSp (NULL,'Graciela','Kub',NULL,'5703 Green Dale',NULL,NULL,NULL,'Nienowfurt','ID','57075','USA','7034102047');
CALL InsUpStdCustomerSp (NULL,'Jennings','Watsica',NULL,'07259 Upton Oval',NULL,NULL,NULL,'North Abbigail','CO','41757','USA','1598281972');
CALL InsUpStdCustomerSp (NULL,'Creola','Corwin',NULL,'70948 Lehner Courts',NULL,NULL,NULL,'Port Dorthyland','IO','69857','USA','1785011305');
CALL InsUpStdCustomerSp (NULL,'Alan','Fadel',NULL,'193 Winona Spring',NULL,NULL,NULL,'Bradtkeberg','IN','10299','USA','1526973260');
CALL InsUpStdCustomerSp (NULL,'Raheem','Rau',NULL,'4645 Declan Island',NULL,NULL,NULL,'New Jaredmouth','AL','11853','USA','7644677298');
CALL InsUpStdCustomerSp (NULL,'Mateo','Koss',NULL,'301 Gulgowski Dale',NULL,NULL,NULL,'West Orvillebury','MA','33933','USA','0200021285');
CALL InsUpStdCustomerSp (NULL,'Dahlia','Prohaska',NULL,'20427 Mosciski Flats',NULL,NULL,NULL,'Cassidyborough','OK','36998','USA','7393355732');
CALL InsUpStdCustomerSp (NULL,'Aimee','Stanton',NULL,'215 Murazik Unions',NULL,NULL,NULL,'Lake Curt','PE','98219','USA','2014387190');
CALL InsUpStdCustomerSp (NULL,'Fern','Effertz',NULL,'904 Kohler Course',NULL,NULL,NULL,'Port Abner','NE','75209','USA','6673628779');
CALL InsUpStdCustomerSp (NULL,'Jake','Rogahn',NULL,'7100 Orn Creek',NULL,NULL,NULL,'West Addison','MI','49348','USA','1933346940');
CALL InsUpStdCustomerSp (NULL,'Bailee','McGlynn',NULL,'353 Thiel Junctions',NULL,NULL,NULL,'Stonebury','AL','39731','USA','2853068361');
CALL InsUpStdCustomerSp (NULL,'Ethel','Ferry',NULL,'41430 Pollich Groves',NULL,NULL,NULL,'New Chestermouth','NO','23430','USA','4295877686');
CALL InsUpStdCustomerSp (NULL,'Eloisa','Spencer',NULL,'9349 Emanuel Overpass',NULL,NULL,NULL,'Hodkiewiczfort','MI','31725','USA','5274400244');
CALL InsUpStdCustomerSp (NULL,'Linwood','Davis',NULL,'0640 Olson Avenue',NULL,NULL,NULL,'Kozeytown','RH','5601','USA','8271635604');
CALL InsUpStdCustomerSp (NULL,'Elouise','Bahringer',NULL,'737 Pagac Green',NULL,NULL,NULL,'Hickleside','WY','57476','USA','1567736243');
CALL InsUpStdCustomerSp (NULL,'Rhett','Bode',NULL,'180 Karen Causeway',NULL,NULL,NULL,'Torpburgh','MI','46663','USA','8442677678');
CALL InsUpStdCustomerSp (NULL,'Pedro','Ziemann',NULL,'229 Bechtelar Crossroad',NULL,NULL,NULL,'Mustafaview','AL','62888','USA','2419058474');
CALL InsUpStdCustomerSp (NULL,'Amalia','Pagac',NULL,'649 Estelle Knoll',NULL,NULL,NULL,'Kreigerside','MA','15313','USA','1847994116');
CALL InsUpStdCustomerSp (NULL,'Mona','Von',NULL,'258 Auer Centers',NULL,NULL,NULL,'Hamillborough','MI','96835','USA','4720338311');
CALL InsUpStdCustomerSp (NULL,'Archibald','Boyle',NULL,'75423 Shany Island',NULL,NULL,NULL,'Padbergton','VI','57266','USA','7988551716');
CALL InsUpStdCustomerSp (NULL,'Cecelia','Zemlak',NULL,'16359 Kris Overpass',NULL,NULL,NULL,'West Leannabury','NE','65658','USA','0775528760');
CALL InsUpStdCustomerSp (NULL,'Lempi','Hamill',NULL,'761 Lebsack Ville',NULL,NULL,NULL,'Lake Eldredfort','MO','92416','USA','1078451149');
CALL InsUpStdCustomerSp (NULL,'Elody','Sporer',NULL,'50572 Garrison Trace',NULL,NULL,NULL,'South Waylon','WA','52584','USA','1866899337');
CALL InsUpStdCustomerSp (NULL,'Davon','Keeling',NULL,'576 Blanche Wall',NULL,NULL,NULL,'Madelynnchester','VI','16495','USA','8831037484');
CALL InsUpStdCustomerSp (NULL,'Webster','Beatty',NULL,'87580 Greyson Inlet',NULL,NULL,NULL,'Michealland','NO','49985','USA','3829061426');
CALL InsUpStdCustomerSp (NULL,'Ellen','Predovic',NULL,'052 Zulauf Dale',NULL,NULL,NULL,'North Roselynberg','WA','98813','USA','6232112510');
CALL InsUpStdCustomerSp (NULL,'Angelita','Cremin',NULL,'8836 Jacobson Falls',NULL,NULL,NULL,'East Lavinia','MO','7206','USA','1403270532');
CALL InsUpStdCustomerSp (NULL,'Ladarius','Leannon',NULL,'420 Pacocha Stravenue',NULL,NULL,NULL,'West Ebba','VI','38281','USA','0437355594');
CALL InsUpStdCustomerSp (NULL,'Winston','Trantow',NULL,'5358 Fred Wells',NULL,NULL,NULL,'Morganborough','CA','63777','USA','1822830921');
CALL InsUpStdCustomerSp (NULL,'Darby','Shanahan',NULL,'67395 Barton Gateway',NULL,NULL,NULL,'Lake Zackery','OH','42391','USA','3068473357');
CALL InsUpStdCustomerSp (NULL,'Kip','Koelpin',NULL,'54806 Ayla Mill',NULL,NULL,NULL,'Strackeburgh','TE','62366','USA','4211361675');
CALL InsUpStdCustomerSp (NULL,'Izabella','Weissnat',NULL,'054 Swaniawski Shoal',NULL,NULL,NULL,'Deshawnfort','LO','11239','USA','9089121340');
CALL InsUpStdCustomerSp (NULL,'Mariana','Schulist',NULL,'6664 Dare Plaza',NULL,NULL,NULL,'Erikashire','MA','52070','USA','0468080560');
CALL InsUpStdCustomerSp (NULL,'Arely','Krajcik',NULL,'770 Schamberger Wall',NULL,NULL,NULL,'West Daishabury','DE','54371','USA','1533346246');
CALL InsUpStdCustomerSp (NULL,'Kenny','Ward',NULL,'9476 Jamel Way',NULL,NULL,NULL,'Lehnerfurt','CO','35305','USA','0051585812');
CALL InsUpStdCustomerSp (NULL,'Nicolette','Ankunding',NULL,'979 Tavares River',NULL,NULL,NULL,'East Unaville','IL','54653','USA','5930999916');
CALL InsUpStdCustomerSp (NULL,'Dax','West',NULL,'84744 Huel Cliffs',NULL,NULL,NULL,'Lefflerside','WI','28163','USA','8191143500');
CALL InsUpStdCustomerSp (NULL,'Myles','Blanda',NULL,'5182 Veum Freeway',NULL,NULL,NULL,'Kuvalistown','WI','20012','USA','5566025631');
CALL InsUpStdCustomerSp (NULL,'Ellie','Pfeffer',NULL,'483 Douglas Radial',NULL,NULL,NULL,'Port Eliezer','PE','92610','USA','6979639788');
CALL InsUpStdCustomerSp (NULL,'Shad','Schroeder',NULL,'38751 Fatima Pike',NULL,NULL,NULL,'Lake Jerrelltown','CA','24496','USA','1559339429');
CALL InsUpStdCustomerSp (NULL,'Adam','Abshire',NULL,'970 Lulu Ways',NULL,NULL,NULL,'South Alvismouth','MI','60341','USA','0863777489');
CALL InsUpStdCustomerSp (NULL,'Orlo','Morar',NULL,'5618 Koss Mountain',NULL,NULL,NULL,'New Julius','NE','82104','USA','9627199204');
CALL InsUpStdCustomerSp (NULL,'Alysha','Altenwerth',NULL,'0859 Buckridge Orchard',NULL,NULL,NULL,'Elfriedatown','NE','02553','USA','3992117451');
CALL InsUpStdCustomerSp (NULL,'Mia','Collins',NULL,'23070 Timothy Rapids',NULL,NULL,NULL,'North Dorian','KE','18609','USA','1414997533');
CALL InsUpStdCustomerSp (NULL,'Kenyatta','OKon',NULL,'796 DuBuque Tunnel',NULL,NULL,NULL,'South Oceane','AR','54209','USA','7545164344');
CALL InsUpStdCustomerSp (NULL,'Bennie','Sauer',NULL,'4930 Paucek Way',NULL,NULL,NULL,'Aronhaven','VI','69660','USA','9791666519');
CALL InsUpStdCustomerSp (NULL,'Christine','Klein',NULL,'428 Christian Islands',NULL,NULL,NULL,'West Isaiasfurt','KE','84286','USA','4479679312');
CALL InsUpStdCustomerSp (NULL,'Cecilia','Sauer',NULL,'96998 Leuschke Shores',NULL,NULL,NULL,'Briannefort','WA','11909','USA','1196490544');
CALL InsUpStdCustomerSp (NULL,'Ezequiel','Runolfsson',NULL,'989 Sylvester Landing',NULL,NULL,NULL,'Huntermouth','FL','43543','USA','1353830429');
CALL InsUpStdCustomerSp (NULL,'Ethyl','Bashirian',NULL,'7466 Kessler Park',NULL,NULL,NULL,'South Mayeview','NE','08646','USA','1295168613');
CALL InsUpStdCustomerSp (NULL,'Asha','Dickinson',NULL,'83900 Daisy Knoll',NULL,NULL,NULL,'East Christown','AR','78167','USA','1383682672');
CALL InsUpStdCustomerSp (NULL,'Kenna','Miller',NULL,'923 Leonie Mall',NULL,NULL,NULL,'Port Paoloshire','NE','39469','USA','5658191275');
CALL InsUpStdCustomerSp (NULL,'Dudley','Gutkowski',NULL,'318 Block Canyon',NULL,NULL,NULL,'Port Nicholasville','MA','30301','USA','4193678561');
CALL InsUpStdCustomerSp (NULL,'Kelvin','Franecki',NULL,'8207 Cremin Dale',NULL,NULL,NULL,'Adamsshire','TE','71311','USA','2119185524');
CALL InsUpStdCustomerSp (NULL,'Davon','Kuvalis',NULL,'2736 Marquardt Plains',NULL,NULL,NULL,'Port Cartermouth','CO','20817','USA','2339194893');
CALL InsUpStdCustomerSp (NULL,'Eda','Wilderman',NULL,'3075 Bauch River',NULL,NULL,NULL,'Predovicmouth','MA','70525','USA','1770819131');
CALL InsUpStdCustomerSp (NULL,'Oliver','Stanton',NULL,'36413 Joanny Oval',NULL,NULL,NULL,'North Larryburgh','NE','86384','USA','1341752320');
CALL InsUpStdCustomerSp (NULL,'Laron','Moen',NULL,'796 Benjamin Extensions',NULL,NULL,NULL,'Reeceland','WA','69882','USA','6399050294');
CALL InsUpStdCustomerSp (NULL,'Rodger','Cronin',NULL,'919 Stroman Cliff',NULL,NULL,NULL,'Torphyport','LO','18737','USA','6099717201');
CALL InsUpStdCustomerSp (NULL,'Alva','Murphy',NULL,'7184 Purdy Walks',NULL,NULL,NULL,'Mayerbury','GE','87434','USA','1338429653');
CALL InsUpStdCustomerSp (NULL,'Kylee','Labadie',NULL,'761 Veum Islands',NULL,NULL,NULL,'Elsiemouth','WA','79740','USA','1434494345');
CALL InsUpStdCustomerSp (NULL,'Dominic','Orn',NULL,'483 Skiles Walk',NULL,NULL,NULL,'Juniuschester','DE','61210','USA','1478602487');
CALL InsUpStdCustomerSp (NULL,'Genevieve','Brown',NULL,'96127 Flo Corner',NULL,NULL,NULL,'Lake Clemmieside','WY','19204','USA','4022394127');
CALL InsUpStdCustomerSp (NULL,'Rex','Luettgen',NULL,'1997 Thea Cove',NULL,NULL,NULL,'New Morton','CA','13154','USA','2999354596');
CALL InsUpStdCustomerSp (NULL,'Bettye','Rogahn',NULL,'970 Kling Ville',NULL,NULL,NULL,'Schuylerside','NE','30097','USA','0659251725');
CALL InsUpStdCustomerSp (NULL,'Beau','OReilly',NULL,'2150 Angus Isle',NULL,NULL,NULL,'Lake Seth','DE','66034','USA','7167704512');
CALL InsUpStdCustomerSp (NULL,'Summer','Hirthe',NULL,'526 Adrienne Ports',NULL,NULL,NULL,'West Zaria','CO','72367','USA','1027423789');
CALL InsUpStdCustomerSp (NULL,'Alexandria','Mante',NULL,'2000 Caleigh Park',NULL,NULL,NULL,'Lake Garrickside','MA','65753','USA','5441331814');
CALL InsUpStdCustomerSp (NULL,'Hope','Roob',NULL,'430 Ebert Mission',NULL,NULL,NULL,'West Hanschester','OH','70101','USA','2429317008');
CALL InsUpStdCustomerSp (NULL,'Aniya','Kertzmann',NULL,'59013 Wilbert Lock',NULL,NULL,NULL,'Novellaberg','MI','81969','USA','1236195892');
CALL InsUpStdCustomerSp (NULL,'Moshe','Ratke',NULL,'31235 Glover Stravenue',NULL,NULL,NULL,'New Reubenmouth','AR','12750','USA','9343095082');
CALL InsUpStdCustomerSp (NULL,'Miles','Mueller',NULL,'370 Hoeger Crest',NULL,NULL,NULL,'Port Jaden','MA','68339','USA','5053755599');
CALL InsUpStdCustomerSp (NULL,'Hilbert','Willms',NULL,'140 Jacobs Glens',NULL,NULL,NULL,'Medhurstland','WE','25999','USA','5105236654');
CALL InsUpStdCustomerSp (NULL,'Leopold','Gorczany',NULL,'6645 Forest Glens',NULL,NULL,NULL,'Cristianfurt','LO','71735','USA','2414760968');
CALL InsUpStdCustomerSp (NULL,'Joelle','Rau',NULL,'36033 Twila Summit',NULL,NULL,NULL,'Hesselport','DE','30865','USA','1930580438');
CALL InsUpStdCustomerSp (NULL,'Mckayla','Altenwerth',NULL,'999 Lorena Springs',NULL,NULL,NULL,'Leannonburgh','NO','14479','USA','2156311985');
CALL InsUpStdCustomerSp (NULL,'Justina','Armstrong',NULL,'921 Alvah Shores',NULL,NULL,NULL,'Careytown','AR','66927','USA','1662688550');
CALL InsUpStdCustomerSp (NULL,'Clinton','Johns',NULL,'1471 Altenwerth Ridge',NULL,NULL,NULL,'Emilianoside','AR','76931','USA','5343752742');
CALL InsUpStdCustomerSp (NULL,'Megane','Klein',NULL,'54873 Barrows Spurs',NULL,NULL,NULL,'Lake Princess','UT','62711','USA','9705740101');
CALL InsUpStdCustomerSp (NULL,'Vincenzo','Sauer',NULL,'62474 Jennyfer Burg',NULL,NULL,NULL,'Sanfordport','CO','65701','USA','3920323857');
CALL InsUpStdCustomerSp (NULL,'Yazmin','Zieme',NULL,'50099 Leffler Alley',NULL,NULL,NULL,'Macejkovicberg','GE','2311','USA','3369715576');
CALL InsUpStdCustomerSp (NULL,'Lonzo','Guªann',NULL,'7959 Crooks Estates',NULL,NULL,NULL,'East Ignaciomouth','IN','76726','USA','7947139624');
CALL InsUpStdCustomerSp (NULL,'Kimberly','Lubowitz',NULL,'5179 Kuhn Field',NULL,NULL,NULL,'Crooksville','AL','54633','USA','3022765159');
CALL InsUpStdCustomerSp (NULL,'Stephen','Kautzer',NULL,'341 Carlee Islands',NULL,NULL,NULL,'Rayfurt','GE','96745','USA','8346559746');
CALL InsUpStdCustomerSp (NULL,'Royal','Veum',NULL,'740 Schultz Radial',NULL,NULL,NULL,'Ritchiehaven','WY','36447','USA','3747888703');
CALL InsUpStdCustomerSp (NULL,'Juanita','Olson',NULL,'702 OConner Spring',NULL,NULL,NULL,'Port Claireview','LO','81933','USA','1534577899');
CALL InsUpStdCustomerSp (NULL,'Moshe','Cummings',NULL,'8075 Tillman Stream',NULL,NULL,NULL,'Lindseyland','PE','14157','USA','9690735984');
CALL InsUpStdCustomerSp (NULL,'Ona','Terry',NULL,'064 Dejah Dam',NULL,NULL,NULL,'East Cale','PE','93692','USA','4454554771');
CALL InsUpStdCustomerSp (NULL,'Marc','OConnell',NULL,'176 Kiehn Unions',NULL,NULL,NULL,'Rosemariechester','UT','85577','USA','1109524334');
CALL InsUpStdCustomerSp (NULL,'Vita','Beatty',NULL,'678 Spinka Court',NULL,NULL,NULL,'Rodgerland','NE','17351','USA','3695627777');
CALL InsUpStdCustomerSp (NULL,'Jay','Turner',NULL,'14326 Gunnar Ferry',NULL,NULL,NULL,'East Augustusberg','ID','31197','USA','4027716462');
CALL InsUpStdCustomerSp (NULL,'Mafalda','Hessel',NULL,'056 Towne Court',NULL,NULL,NULL,'North Geovannyburgh','ID','74090','USA','1296969932');
CALL InsUpStdCustomerSp (NULL,'Douglas','Legros',NULL,'084 Jonathon Prairie',NULL,NULL,NULL,'Armaniburgh','KE','25582','USA','1353138581');
CALL InsUpStdCustomerSp (NULL,'Ricardo','Stroman',NULL,'9889 Schuster Plain',NULL,NULL,NULL,'Darrinborough','NE','56720','USA','2335509038');
CALL InsUpStdCustomerSp (NULL,'Columbus','Streich',NULL,'26595 Kohler Plaza',NULL,NULL,NULL,'North Drake','AL','53548','USA','1991387556');
CALL InsUpStdCustomerSp (NULL,'Raphaelle','Paucek',NULL,'14915 DuBuque Locks',NULL,NULL,NULL,'New Oralville','OK','83496','USA','6167683007');
CALL InsUpStdCustomerSp (NULL,'Ella','Mosciski',NULL,'96271 Nichole Light',NULL,NULL,NULL,'North Ollietown','TE','10045','USA','9571928817');
CALL InsUpStdCustomerSp (NULL,'Arjun','Murazik',NULL,'000 Efren Island',NULL,NULL,NULL,'North Cynthia','CO','00403','USA','1263792906');
CALL InsUpStdCustomerSp (NULL,'Kasey','Tremblay',NULL,'37885 Waelchi Crescent',NULL,NULL,NULL,'Colebury','WY','33130','USA','8665970072');
CALL InsUpStdCustomerSp (NULL,'Daphne','McDermott',NULL,'66197 Lazaro Circles',NULL,NULL,NULL,'Breitenbergfurt','KE','56356','USA','1437688996');
CALL InsUpStdCustomerSp (NULL,'Katlyn','Schaden',NULL,'56929 McKenzie Wall',NULL,NULL,NULL,'New Mayberg','NE','82347','USA','1396922519');
CALL InsUpStdCustomerSp (NULL,'Kiley','Schoen',NULL,'072 Kuhlman Place',NULL,NULL,NULL,'New Wilfordbury','NE','59541','USA','9203069676');
CALL InsUpStdCustomerSp (NULL,'Cortez','Pfannerstill',NULL,'54834 Becker Terrace',NULL,NULL,NULL,'East Roryton','OK','68401','USA','1833777158');
CALL InsUpStdCustomerSp (NULL,'Keven','Bruen',NULL,'7733 Mann Terrace',NULL,NULL,NULL,'Port Elmo','WE','34230','USA','7432914579');
CALL InsUpStdCustomerSp (NULL,'Guillermo','Marvin',NULL,'95893 Mills Course',NULL,NULL,NULL,'South Albertamouth','MI','88071','USA','1824603229');
CALL InsUpStdCustomerSp (NULL,'Kelton','Kuhn',NULL,'212 Nico Villages',NULL,NULL,NULL,'Cristview','NE','28697','USA','7495437911');
CALL InsUpStdCustomerSp (NULL,'Nat','Adams',NULL,'9446 Rath Parkways',NULL,NULL,NULL,'Maddisonton','OR','37713','USA','9856884939');
CALL InsUpStdCustomerSp (NULL,'Colton','Torphy',NULL,'295 Gregorio Turnpike',NULL,NULL,NULL,'East Christian','MA','17257','USA','3971543139');
CALL InsUpStdCustomerSp (NULL,'Baby','Donnelly',NULL,'083 Emil Light',NULL,NULL,NULL,'North Nickolas','NE','38756','USA','8774442582');
CALL InsUpStdCustomerSp (NULL,'Madeline','OConner',NULL,'978 Shanahan Extension',NULL,NULL,NULL,'West Jesushaven','IN','86427','USA','0814909126');
CALL InsUpStdCustomerSp (NULL,'Eloise','Kilback',NULL,'25500 Dibbert Knoll',NULL,NULL,NULL,'South Andre','AL','59796','USA','5428627362');
CALL InsUpStdCustomerSp (NULL,'Woodrow','Howell',NULL,'9192 Stoltenberg Hills',NULL,NULL,NULL,'Jorditon','OK','09640','USA','9911815260');
CALL InsUpStdCustomerSp (NULL,'Christina','Bailey',NULL,'811 Bayer Point',NULL,NULL,NULL,'Lake Shanna','MA','18296','USA','1887370942');
CALL InsUpStdCustomerSp (NULL,'Anissa','Runte',NULL,'483 Wunsch Key',NULL,NULL,NULL,'OConnerport','SO','90230','USA','3163762379');
CALL InsUpStdCustomerSp (NULL,'Lexi','Weimann',NULL,'454 Luciano Corners',NULL,NULL,NULL,'Vaughnville','AL','44516','USA','1402124578');
CALL InsUpStdCustomerSp (NULL,'Declan','Yost',NULL,'66283 Murray Forest',NULL,NULL,NULL,'East Paulinebury','LO','46218','USA','3602853189');
CALL InsUpStdCustomerSp (NULL,'Meghan','Gorczany',NULL,'14165 Hegmann Cove',NULL,NULL,NULL,'Wisokyfurt','PE','41994','USA','4880465507');
CALL InsUpStdCustomerSp (NULL,'Martin','Mertz',NULL,'765 Wolff Curve',NULL,NULL,NULL,'Wisokystad','WY','73212','USA','1809813379');
CALL InsUpStdCustomerSp (NULL,'Joany','Renner',NULL,'0130 Noemie Ridge',NULL,NULL,NULL,'Edmondburgh','NE','00479','USA','3766389030');
CALL InsUpStdCustomerSp (NULL,'Antonietta','Wiza',NULL,'411 Carolanne Oval',NULL,NULL,NULL,'West Brooklynville','WE','25328','USA','1768510431');
CALL InsUpStdCustomerSp (NULL,'Tabitha','Klocko',NULL,'23382 Delilah Station',NULL,NULL,NULL,'North Johan','SO','48046','USA','7119092171');
CALL InsUpStdCustomerSp (NULL,'Alexandrea','Huel',NULL,'6696 Salvatore Shoal',NULL,NULL,NULL,'Edisonberg','OK','5454','USA','0757572042');
CALL InsUpStdCustomerSp (NULL,'Cloyd','Crist',NULL,'004 Graciela Turnpike',NULL,NULL,NULL,'Svenhaven','AL','6417','USA','4921102427');
CALL InsUpStdCustomerSp (NULL,'Orval','Deckow',NULL,'430 Crona Shore',NULL,NULL,NULL,'Lake Ashley','MO','28094','USA','1933819614');
CALL InsUpStdCustomerSp (NULL,'Gretchen','Jenkins',NULL,'56463 Rollin Field',NULL,NULL,NULL,'New Earlene','CA','25788','USA','1864240226');
CALL InsUpStdCustomerSp (NULL,'Jacinthe','Grimes',NULL,'843 Bernhard Squares',NULL,NULL,NULL,'North Malvinastad','MA','44369','USA','4419910282');
CALL InsUpStdCustomerSp (NULL,'Rigoberto','Hills',NULL,'35707 Tremblay Wall',NULL,NULL,NULL,'Reynoldsville','NE','80019','USA','0060056335');
CALL InsUpStdCustomerSp (NULL,'Wilhelmine','Gerlach',NULL,'93187 Kiehn Passage',NULL,NULL,NULL,'New Aubreeville','IL','46539','USA','8879012188');
CALL InsUpStdCustomerSp (NULL,'Mollie','Von',NULL,'269 Mallie Inlet',NULL,NULL,NULL,'New Morton','NE','50776','USA','0734294284');
CALL InsUpStdCustomerSp (NULL,'Naomi','Torphy',NULL,'617 Gorczany Port',NULL,NULL,NULL,'Duncanland','KA','48578','USA','2436858922');
CALL InsUpStdCustomerSp (NULL,'Berry','Kshlerin',NULL,'383 Earl Ville',NULL,NULL,NULL,'East Ernie','KE','78252','USA','1841402188');
CALL InsUpStdCustomerSp (NULL,'Melyna','Sporer',NULL,'347 Mark Row',NULL,NULL,NULL,'Dorotheafurt','CA','04749','USA','4101421752');
CALL InsUpStdCustomerSp (NULL,'Santiago','Koss',NULL,'094 Bayer Plain',NULL,NULL,NULL,'East Jessetown','NE','67282','USA','4295404920');
CALL InsUpStdCustomerSp (NULL,'Rafael','Bailey',NULL,'132 Schroeder Mill',NULL,NULL,NULL,'Johannville','LO','15351','USA','5394653851');
CALL InsUpStdCustomerSp (NULL,'Giovanni','Swaniawski',NULL,'80850 Donnelly Alley',NULL,NULL,NULL,'Parkerburgh','MA','37908','USA','2193551829');
CALL InsUpStdCustomerSp (NULL,'Ceasar','Powlowski',NULL,'9468 Haag Views',NULL,NULL,NULL,'East Nolanbury','IL','1511','USA','2389261862');
CALL InsUpStdCustomerSp (NULL,'Violet','Jakubowski',NULL,'7997 Anna Estates',NULL,NULL,NULL,'Caryport','CA','38282','USA','8717695694');
CALL InsUpStdCustomerSp (NULL,'Lulu','Marquardt',NULL,'6811 Funk Spurs',NULL,NULL,NULL,'Danniemouth','GE','15056','USA','5913252340');
CALL InsUpStdCustomerSp (NULL,'Kadin','Zemlak',NULL,'4353 Anderson Streets',NULL,NULL,NULL,'New Shyanne','KE','33121','USA','8610484059');
CALL InsUpStdCustomerSp (NULL,'Kailee','Yundt',NULL,'16571 Greenholt Center',NULL,NULL,NULL,'Kieranbury','DE','75551','USA','2617531426');
CALL InsUpStdCustomerSp (NULL,'Trinity','Bogan',NULL,'154 Cummerata Roads',NULL,NULL,NULL,'South Demario','NE','60019','USA','7697511661');
CALL InsUpStdCustomerSp (NULL,'Columbus','Stoltenberg',NULL,'41097 Kub Tunnel',NULL,NULL,NULL,'Jonatanchester','NE','51139','USA','3273522230');
CALL InsUpStdCustomerSp (NULL,'Creola','Macejkovic',NULL,'3347 Abbott Highway',NULL,NULL,NULL,'Alizeshire','MI','81215','USA','3096677398');
CALL InsUpStdCustomerSp (NULL,'Queenie','Ritchie',NULL,'81227 Veum Street',NULL,NULL,NULL,'Port Lelandshire','SO','57611','USA','1446670800');
CALL InsUpStdCustomerSp (NULL,'Jasmin','Von',NULL,'5932 Lang Heights',NULL,NULL,NULL,'Moenview','AL','56024','USA','1653098449');
CALL InsUpStdCustomerSp (NULL,'Ryder','Robel',NULL,'2293 Lonie Rapids',NULL,NULL,NULL,'West Sonya','OR','96248','USA','1973156676');
CALL InsUpStdCustomerSp (NULL,'Dashawn','Murazik',NULL,'9691 Grimes Fall',NULL,NULL,NULL,'West Khalil','CO','15570','USA','1023800654');
CALL InsUpStdCustomerSp (NULL,'Therese','Heidenreich',NULL,'597 Emelie Coves',NULL,NULL,NULL,'Fosterfurt','NE','63501','USA','1047474129');
CALL InsUpStdCustomerSp (NULL,'Henry','Brown',NULL,'3072 Wiegand Pike',NULL,NULL,NULL,'North Alexanneburgh','MA','71962','USA','1056681947');
CALL InsUpStdCustomerSp (NULL,'Lew','Carter',NULL,'354 Barton Crest',NULL,NULL,NULL,'Lake Johanna','UT','80937','USA','1456913941');
CALL InsUpStdCustomerSp (NULL,'Tanner','Eichmann',NULL,'7827 Prohaska Parkways',NULL,NULL,NULL,'Predovicburgh','MA','92873','USA','8113693520');
CALL InsUpStdCustomerSp (NULL,'Delfina','Grady',NULL,'3927 Benton Spring',NULL,NULL,NULL,'Theoburgh','MI','59665','USA','1904614304');
CALL InsUpStdCustomerSp (NULL,'Della','Stracke',NULL,'6103 Gisselle Street',NULL,NULL,NULL,'Port Wilhelm','ID','88135','USA','0589168972');
CALL InsUpStdCustomerSp (NULL,'Howard','Bode',NULL,'32937 Reynolds Union',NULL,NULL,NULL,'Lake Quintonfurt','HA','80562','USA','9967243665');
CALL InsUpStdCustomerSp (NULL,'Taya','Pfeffer',NULL,'446 Jennings Harbor',NULL,NULL,NULL,'New Augustinetown','RH','13450','USA','1158616056');
CALL InsUpStdCustomerSp (NULL,'Cordell','OKeefe',NULL,'475 Kuvalis Underpass',NULL,NULL,NULL,'Willview','PE','91429','USA','8344154761');
CALL InsUpStdCustomerSp (NULL,'Thaddeus','Farrell',NULL,'3793 Brisa Village',NULL,NULL,NULL,'Lakinton','UT','30088','USA','5987865951');
CALL InsUpStdCustomerSp (NULL,'Sasha','Morar',NULL,'302 Wisozk Mountain',NULL,NULL,NULL,'Elenorstad','WI','98401','USA','0518951050');
CALL InsUpStdCustomerSp (NULL,'Wendell','Paucek',NULL,'4036 Rafael Cliffs',NULL,NULL,NULL,'Aidashire','NO','80021','USA','1936881242');
CALL InsUpStdCustomerSp (NULL,'Dane','Kertzmann',NULL,'8237 Stehr Fall',NULL,NULL,NULL,'Lake Allene','IN','78385','USA','8672377629');
CALL InsUpStdCustomerSp (NULL,'Omer','McGlynn',NULL,'2879 Lang Street',NULL,NULL,NULL,'North Fausto','SO','73658','USA','1843855386');
CALL InsUpStdCustomerSp (NULL,'Mitchel','Bogan',NULL,'7667 Haylee Knolls',NULL,NULL,NULL,'New Yadiraburgh','IN','08006','USA','1661042514');
CALL InsUpStdCustomerSp (NULL,'Kiley','Brown',NULL,'34813 Kutch Cliff',NULL,NULL,NULL,'Kleinville','MI','29883','USA','1794486620');
CALL InsUpStdCustomerSp (NULL,'Sharon','Towne',NULL,'82755 Jenkins Branch',NULL,NULL,NULL,'East Denis','WY','60602','USA','0972089632');
CALL InsUpStdCustomerSp (NULL,'Durward','Koch',NULL,'6401 Cheyanne Crossroad',NULL,NULL,NULL,'Port Jaunita','WY','91539','USA','5502612228');
CALL InsUpStdCustomerSp (NULL,'Lilyan','Schumm',NULL,'7879 Cummings Meadows',NULL,NULL,NULL,'Port Pricebury','WI','86801','USA','4589331276');
CALL InsUpStdCustomerSp (NULL,'Vilma','Reynolds',NULL,'9558 Kirlin Wall',NULL,NULL,NULL,'North Tracymouth','ID','10617','USA','3078617724');
CALL InsUpStdCustomerSp (NULL,'Terrell','Howell',NULL,'2538 Trenton Landing',NULL,NULL,NULL,'Weberport','VI','92218','USA','1361057832');
CALL InsUpStdCustomerSp (NULL,'Chaz','Sanford',NULL,'926 Myriam Highway',NULL,NULL,NULL,'Jamarcuschester','SO','10157','USA','1571950596');
CALL InsUpStdCustomerSp (NULL,'Loma','Lueilwitz',NULL,'14544 Johanna Crossing',NULL,NULL,NULL,'Jaydonburgh','PE','58927','USA','2471590871');
CALL InsUpStdCustomerSp (NULL,'Garrick','Kuhlman',NULL,'75272 Durgan Meadows',NULL,NULL,NULL,'Lake Jovanny','VE','12240','USA','7207487461');
CALL InsUpStdCustomerSp (NULL,'Margarita','Abernathy',NULL,'018 Bogan Flat',NULL,NULL,NULL,'New Chelsie','NO','98258','USA','0070818934');
CALL InsUpStdCustomerSp (NULL,'Landen','Ruecker',NULL,'3805 Wolf Turnpike',NULL,NULL,NULL,'Goyettefurt','OK','72314','USA','3495625383');
CALL InsUpStdCustomerSp (NULL,'Nelle','Bailey',NULL,'1666 Korbin Falls',NULL,NULL,NULL,'New Kenny','WY','36355','USA','6285988502');
CALL InsUpStdCustomerSp (NULL,'Tressa','Hermann',NULL,'2329 Federico Brooks',NULL,NULL,NULL,'North Opal','NE','77482','USA','4273250028');
CALL InsUpStdCustomerSp (NULL,'Wilbert','Bednar',NULL,'81898 Lesch Lodge',NULL,NULL,NULL,'North Griffin','SO','96289','USA','4867269400');
CALL InsUpStdCustomerSp (NULL,'Jaclyn','Beer',NULL,'902 Koepp Spur',NULL,NULL,NULL,'Blockland','MI','46022','USA','1432219039');
CALL InsUpStdCustomerSp (NULL,'Neva','Reichert',NULL,'70281 Godfrey Villages',NULL,NULL,NULL,'Port Katrinestad','VE','52927','USA','8761614469');
CALL InsUpStdCustomerSp (NULL,'Mara','Jewess',NULL,'502 Hane Forks',NULL,NULL,NULL,'Grayceborough','RH','67215','USA','1394113356');
CALL InsUpStdCustomerSp (NULL,'Carey','Bernhard',NULL,'6571 Webster Fork',NULL,NULL,NULL,'Lake Irvington','IO','81571','USA','3735716377');
CALL InsUpStdCustomerSp (NULL,'Yvette','Botsford',NULL,'298 Bradtke Harbor',NULL,NULL,NULL,'North Marcelle','AR','78742','USA','1629358065');
CALL InsUpStdCustomerSp (NULL,'Leda','Kemmer',NULL,'09791 Orval Run',NULL,NULL,NULL,'Lake Reymundo','OH','30599','USA','7833669569');
CALL InsUpStdCustomerSp (NULL,'Gladys','Zieme',NULL,'07287 Kulas Bypass',NULL,NULL,NULL,'North Ernatown','IN','27221','USA','1796450685');
CALL InsUpStdCustomerSp (NULL,'Fausto','Kertzmann',NULL,'2009 Larson Mission',NULL,NULL,NULL,'Mantetown','MA','39536','USA','0991848052');
CALL InsUpStdCustomerSp (NULL,'Heaven','Reichert',NULL,'1476 Cordelia Field',NULL,NULL,NULL,'Lake Dion','MA','79389','USA','0109993439');
CALL InsUpStdCustomerSp (NULL,'Zoey','Blick',NULL,'7505 German Pines',NULL,NULL,NULL,'Lindgrenville','SO','52048','USA','8346480307');
CALL InsUpStdCustomerSp (NULL,'Hilton','Aufderhar',NULL,'5746 Jovani Underpass',NULL,NULL,NULL,'Josefinachester','MA','20809','USA','4633520713');
CALL InsUpStdCustomerSp (NULL,'Adrain','OConner',NULL,'299 Elsa Underpass',NULL,NULL,NULL,'Layneside','MI','18942','USA','1322234954');
CALL InsUpStdCustomerSp (NULL,'Neal','Lesch',NULL,'169 Aida Lake',NULL,NULL,NULL,'Gerlachtown','NE','47825','USA','6145389836');
CALL InsUpStdCustomerSp (NULL,'Donnie','Ledner',NULL,'170 Mariane Spring',NULL,NULL,NULL,'Port Jerel','VE','40782','USA','1174974624');
CALL InsUpStdCustomerSp (NULL,'Jaden','Bradtke',NULL,'900 Mazie Haven',NULL,NULL,NULL,'Amayatown','NE','23755','USA','5050529284');
CALL InsUpStdCustomerSp (NULL,'Matt','Walker',NULL,'9995 Wilhelm Ports',NULL,NULL,NULL,'Schmittmouth','NE','34237','USA','1080620305');
CALL InsUpStdCustomerSp (NULL,'Eleazar','Fahey',NULL,'7524 Isabell Skyway',NULL,NULL,NULL,'New Palmaside','NE','69090','USA','2876157832');
CALL InsUpStdCustomerSp (NULL,'Lavon','Hintz',NULL,'129 Coleman Turnpike',NULL,NULL,NULL,'New Brandthaven','ID','43704','USA','3297328185');
CALL InsUpStdCustomerSp (NULL,'Fern','Sipes',NULL,'9407 Abernathy Lodge',NULL,NULL,NULL,'North Mervin','NE','14490','USA','1840856845');
CALL InsUpStdCustomerSp (NULL,'Isaias','Ferry',NULL,'9245 Oran Manors',NULL,NULL,NULL,'Lexusstad','SO','67320','USA','7202692015');
CALL InsUpStdCustomerSp (NULL,'Nathaniel','Stracke',NULL,'6652 Bogisich Lock',NULL,NULL,NULL,'Lake Clairburgh','HA','29061','USA','1792873661');
CALL InsUpStdCustomerSp (NULL,'Ambrose','Kunze',NULL,'9655 Wuckert Crossroad',NULL,NULL,NULL,'North Cathystad','NE','53456','USA','2274410732');
CALL InsUpStdCustomerSp (NULL,'Hermann','Schinner',NULL,'91689 Marie Place',NULL,NULL,NULL,'Grahammouth','LO','11746','USA','9938101098');
CALL InsUpStdCustomerSp (NULL,'Pamela','Lebsack',NULL,'61868 Haley Inlet',NULL,NULL,NULL,'North Lisandro','MI','53565','USA','7204852294');
CALL InsUpStdCustomerSp (NULL,'Christop','Wiza',NULL,'74652 Gleason Place',NULL,NULL,NULL,'Denesikview','OH','11793','USA','3449035544');
CALL InsUpStdCustomerSp (NULL,'Camryn','Leuschke',NULL,'078 Zulauf Spring',NULL,NULL,NULL,'East Dorthy','TE','67334','USA','2043696918');
CALL InsUpStdCustomerSp (NULL,'Robb','OKeefe',NULL,'07494 Klein Plaza',NULL,NULL,NULL,'Port Darreltown','DE','37778','USA','8673287198');
CALL InsUpStdCustomerSp (NULL,'Alysha','Romaguera',NULL,'061 White Mount',NULL,NULL,NULL,'New Chet','MA','5483','USA','1589143019');
CALL InsUpStdCustomerSp (NULL,'Haylee','Beatty',NULL,'0531 Barrows Isle',NULL,NULL,NULL,'North Neha','SO','11951','USA','1438400586');
CALL InsUpStdCustomerSp (NULL,'Lucie','Nikolaus',NULL,'28345 Spencer Port',NULL,NULL,NULL,'Sigmundmouth','VI','98669','USA','1182403053');
CALL InsUpStdCustomerSp (NULL,'Ken','Zemlak',NULL,'4378 Hickle View',NULL,NULL,NULL,'Port Santiagohaven','MA','47499','USA','1758275501');
CALL InsUpStdCustomerSp (NULL,'Sheridan','Sipes',NULL,'1934 Ora Squares',NULL,NULL,NULL,'Devynborough','DE','36274','USA','2210682183');
CALL InsUpStdCustomerSp (NULL,'Lulu','Muller',NULL,'198 Halvorson Plain',NULL,NULL,NULL,'Kossfurt','UT','92666','USA','9440840112');
CALL InsUpStdCustomerSp (NULL,'Marlin','Yundt',NULL,'9699 Santiago Alley',NULL,NULL,NULL,'South Dina','AR','01321','USA','2400330856');
CALL InsUpStdCustomerSp (NULL,'Jaquan','Parisian',NULL,'095 Mertie Mills',NULL,NULL,NULL,'Rutherfordmouth','MA','64619','USA','5714787014');
CALL InsUpStdCustomerSp (NULL,'Libbie','Mann',NULL,'96532 Lindgren Rest',NULL,NULL,NULL,'Eichmannbury','AR','13499','USA','5597820528');
CALL InsUpStdCustomerSp (NULL,'Claire','Hagenes',NULL,'7807 Willms Points',NULL,NULL,NULL,'Lake Rolando','WA','42473','USA','2700086338');
CALL InsUpStdCustomerSp (NULL,'Garnet','Schmitt',NULL,'50863 Ullrich Summit',NULL,NULL,NULL,'Prohaskaland','MA','9738','USA','6974889492');
CALL InsUpStdCustomerSp (NULL,'Giuseppe','Monahan',NULL,'690 Nolan Branch',NULL,NULL,NULL,'Aricland','WI','76131','USA','9270160677');
CALL InsUpStdCustomerSp (NULL,'Pearline','Barrows',NULL,'7290 Lacey Island',NULL,NULL,NULL,'Lake Jamaal','CO','41803','USA','1279172074');
CALL InsUpStdCustomerSp (NULL,'Lonie','Goldner',NULL,'116 Milton Port',NULL,NULL,NULL,'East Narciso','MO','77365','USA','9944936845');
CALL InsUpStdCustomerSp (NULL,'Alice','Stamm',NULL,'0094 Lorenza Spring',NULL,NULL,NULL,'Lake Narciso','CO','71582','USA','2965792690');
CALL InsUpStdCustomerSp (NULL,'Darby','Ziemann',NULL,'921 Queen Inlet',NULL,NULL,NULL,'Lindsayland','AL','77463','USA','7232015667');
CALL InsUpStdCustomerSp (NULL,'Fausto','Parisian',NULL,'979 Lura Glen',NULL,NULL,NULL,'Port Darrenborough','MO','413','USA','4162802486');
CALL InsUpStdCustomerSp (NULL,'Mack','Kunde',NULL,'95062 Marquardt Cape',NULL,NULL,NULL,'Hilperttown','NE','93150','USA','1962902076');
CALL InsUpStdCustomerSp (NULL,'Mariela','Parker',NULL,'831 Ankunding Locks',NULL,NULL,NULL,'West Dale','OR','94752','USA','6855939255');
CALL InsUpStdCustomerSp (NULL,'Kaitlin','Bednar',NULL,'252 Mayert Point',NULL,NULL,NULL,'Port Carymouth','WA','15137','USA','5331623112');
CALL InsUpStdCustomerSp (NULL,'Betsy','Mertz',NULL,'8613 Leuschke Point',NULL,NULL,NULL,'New Nataliabury','CO','46366','USA','3895952684');
CALL InsUpStdCustomerSp (NULL,'Velma','Bogan',NULL,'4476 Weber Springs',NULL,NULL,NULL,'South Kirk','CO','89960','USA','1049589348');
CALL InsUpStdCustomerSp (NULL,'Austyn','Macejkovic',NULL,'11181 Denis Burg',NULL,NULL,NULL,'Lake Payton','WE','54262','USA','3400609105');
CALL InsUpStdCustomerSp (NULL,'Davon','Thompson',NULL,'7089 Lilliana Hills',NULL,NULL,NULL,'East Lera','WA','39984','USA','1259689365');
CALL InsUpStdCustomerSp (NULL,'Tod','Murray',NULL,'550 Jerome Springs',NULL,NULL,NULL,'Kunzeview','GE','9882','USA','1908188855');
CALL InsUpStdCustomerSp (NULL,'Oral','Grady',NULL,'3431 Sherwood Path',NULL,NULL,NULL,'Rodriguezside','MI','28726','USA','9614568896');
CALL InsUpStdCustomerSp (NULL,'Alize','Wilderman',NULL,'8035 Ebert Light',NULL,NULL,NULL,'New Sonia','AR','21211','USA','8496256793');
CALL InsUpStdCustomerSp (NULL,'Fidel','Roberts',NULL,'633 Valentine Lodge',NULL,NULL,NULL,'West Claudeburgh','NE','40295','USA','9324316799');
CALL InsUpStdCustomerSp (NULL,'Leon','DuBuque',NULL,'1358 Fritsch Overpass',NULL,NULL,NULL,'West Gretachester','NO','10892','USA','1274088839');
CALL InsUpStdCustomerSp (NULL,'Lawrence','Effertz',NULL,'272 Queenie Viaduct',NULL,NULL,NULL,'Lake Bertramland','VI','54830','USA','8119476609');
CALL InsUpStdCustomerSp (NULL,'Dixie','Dooley',NULL,'8660 Rogahn Club',NULL,NULL,NULL,'Port Dexter','MI','87737','USA','4376552244');
CALL InsUpStdCustomerSp (NULL,'Ottis','Feil',NULL,'50401 Clair Street',NULL,NULL,NULL,'North Greg','WE','43913','USA','7121121110');
CALL InsUpStdCustomerSp (NULL,'Ernestina','Heathcote',NULL,'63112 Lind Hill',NULL,NULL,NULL,'Arnulfobury','MA','83144','USA','9071071033');
CALL InsUpStdCustomerSp (NULL,'Gregorio','Parker',NULL,'59314 Parisian Crest',NULL,NULL,NULL,'Lake Cathrine','IO','70782','USA','1404505375');
CALL InsUpStdCustomerSp (NULL,'Leopold','Dickinson',NULL,'6423 Rowe Plains',NULL,NULL,NULL,'Hintzshire','MI','47029','USA','5071290816');
CALL InsUpStdCustomerSp (NULL,'Rick','Runte',NULL,'445 Abbott Cove',NULL,NULL,NULL,'Port Devinland','SO','84119','USA','1231978946');
CALL InsUpStdCustomerSp (NULL,'Edmond','Pacocha',NULL,'3644 Hauck Way',NULL,NULL,NULL,'Schroederfurt','AR','48682','USA','9916544494');
CALL InsUpStdCustomerSp (NULL,'Sienna','Armstrong',NULL,'171 Christiansen Shoal',NULL,NULL,NULL,'South Jamelfort','TE','63279','USA','7938004294');
CALL InsUpStdCustomerSp (NULL,'Dawson','Hintz',NULL,'05449 Von Via',NULL,NULL,NULL,'Maximilliaberg','MI','68087','USA','1998117368');
CALL InsUpStdCustomerSp (NULL,'Katlyn','Nitzsche',NULL,'64732 Davis Island',NULL,NULL,NULL,'Johnstonside','IN','61177','USA','3827784660');
CALL InsUpStdCustomerSp (NULL,'Charley','Flatley',NULL,'160 Anderson Route',NULL,NULL,NULL,'Andersontown','MA','98903','USA','1012813268');
CALL InsUpStdCustomerSp (NULL,'Lenna','Monahan',NULL,'79350 Abernathy Wells',NULL,NULL,NULL,'Cassinview','DE','04178','USA','0389880517');
CALL InsUpStdCustomerSp (NULL,'Elisa','Gulgowski',NULL,'7436 Gerlach Tunnel',NULL,NULL,NULL,'Rosenbaumside','NO','17352','USA','9447981598');
CALL InsUpStdCustomerSp (NULL,'Adrien','Daniel',NULL,'50814 Hallie Groves',NULL,NULL,NULL,'Merlechester','TE','97246','USA','1124108229');
CALL InsUpStdCustomerSp (NULL,'Friedrich','Jacobi',NULL,'2186 Dooley Trail',NULL,NULL,NULL,'Christelleburgh','MI','5259','USA','2480156492');
CALL InsUpStdCustomerSp (NULL,'Precious','Feil',NULL,'0886 Hoppe Ports',NULL,NULL,NULL,'Adamshaven','NE','11957','USA','3089704051');
CALL InsUpStdCustomerSp (NULL,'Gavin','Hudson',NULL,'747 Amy Drives',NULL,NULL,NULL,'Port Serenity','NE','47026','USA','0974015394');
CALL InsUpStdCustomerSp (NULL,'Karli','Crooks',NULL,'7722 Hudson Curve',NULL,NULL,NULL,'Ebertstad','VE','97136','USA','4772006670');
CALL InsUpStdCustomerSp (NULL,'Myrl','Hudson',NULL,'921 Rogahn Bypass',NULL,NULL,NULL,'Lake Sageton','NE','90751','USA','1699654337');
CALL InsUpStdCustomerSp (NULL,'Shania','OConner',NULL,'3301 Verdie Springs',NULL,NULL,NULL,'New Jadonbury','NO','52887','USA','1035550133');
CALL InsUpStdCustomerSp (NULL,'Liam','Koss',NULL,'31865 Beer Underpass',NULL,NULL,NULL,'Kyleighborough','NO','89747','USA','9270021714');
CALL InsUpStdCustomerSp (NULL,'Jillian','Becker',NULL,'0865 Wolff Villages',NULL,NULL,NULL,'Swaniawskifort','SO','68242','USA','9118089951');
CALL InsUpStdCustomerSp (NULL,'Giovani','McLaughlin',NULL,'3299 Schneider Fort',NULL,NULL,NULL,'East Ladarius','DE','38151','USA','1738646476');
CALL InsUpStdCustomerSp (NULL,'Roslyn','Hickle',NULL,'970 Jettie Grove',NULL,NULL,NULL,'Clarabellechester','LO','51734','USA','1414648444');
CALL InsUpStdCustomerSp (NULL,'Ollie','Green',NULL,'183 Hammes Land',NULL,NULL,NULL,'New Brooklyn','WE','11272','USA','1248789187');
CALL InsUpStdCustomerSp (NULL,'Bethany','Cole',NULL,'8817 Emmet Mills',NULL,NULL,NULL,'Weimannside','NO','69032','USA','1032515861');
CALL InsUpStdCustomerSp (NULL,'Deonte','Hansen',NULL,'676 Lorenzo Forks',NULL,NULL,NULL,'Lake Rogersstad','IL','03349','USA','4132872215');
CALL InsUpStdCustomerSp (NULL,'Verda','Lehner',NULL,'2383 Mallory Estates',NULL,NULL,NULL,'South Minervashire','NE','09874','USA','1358356936');
CALL InsUpStdCustomerSp (NULL,'Lee','Bruen',NULL,'2605 Sawayn Avenue',NULL,NULL,NULL,'Nikobury','NE','66900','USA','5489873627');
CALL InsUpStdCustomerSp (NULL,'Abigale','Howell',NULL,'567 Denesik Port',NULL,NULL,NULL,'Theodoraland','RH','90970','USA','5827858729');
CALL InsUpStdCustomerSp (NULL,'Roberta','Kuhlman',NULL,'00662 Vern Stravenue',NULL,NULL,NULL,'New Mckayla','PE','16139','USA','1665089453');
CALL InsUpStdCustomerSp (NULL,'Lydia','Wintheiser',NULL,'9765 Hodkiewicz Canyon',NULL,NULL,NULL,'Nienowshire','MA','21061','USA','1368711059');
CALL InsUpStdCustomerSp (NULL,'Shad','Klocko',NULL,'4174 Shawn Village',NULL,NULL,NULL,'East Ninamouth','IO','33511','USA','1884670352');
CALL InsUpStdCustomerSp (NULL,'Bertha','Collier',NULL,'5836 Reynolds Courts',NULL,NULL,NULL,'West Erikfurt','AR','77264','USA','5776691884');
CALL InsUpStdCustomerSp (NULL,'Tyshawn','Hand',NULL,'75501 Lehner Cove',NULL,NULL,NULL,'East Hilbertport','OR','31766','USA','9442375098');
CALL InsUpStdCustomerSp (NULL,'Candelario','Hudson',NULL,'0864 Bosco Shoals',NULL,NULL,NULL,'Jaskolskiborough','NE','96350','USA','9527321227');
CALL InsUpStdCustomerSp (NULL,'Zoey','Reichert',NULL,'44012 Braun Bypass',NULL,NULL,NULL,'South Alexandriamouth','IN','37487','USA','9633794511');
CALL InsUpStdCustomerSp (NULL,'Anika','Ratke',NULL,'266 Sister Ports',NULL,NULL,NULL,'Dibbertmouth','FL','72725','USA','2908134858');
CALL InsUpStdCustomerSp (NULL,'Elsa','Gottlieb',NULL,'7085 Sebastian Brooks',NULL,NULL,NULL,'Lake Lionel','WA','95079','USA','6352063513');
CALL InsUpStdCustomerSp (NULL,'Tyra','Larkin',NULL,'80705 Russel Plaza',NULL,NULL,NULL,'Millsbury','AR','83640','USA','8082021858');
CALL InsUpStdCustomerSp (NULL,'Sophie','Guªann',NULL,'72284 Bednar Rapids',NULL,NULL,NULL,'Zulaufborough','UT','75032','USA','8066350313');
CALL InsUpStdCustomerSp (NULL,'Aracely','Torp',NULL,'8005 Eichmann Crossroad',NULL,NULL,NULL,'West Anastaciofort','FL','57427','USA','1774853797');
CALL InsUpStdCustomerSp (NULL,'Jacinto','Little',NULL,'724 Evan Divide',NULL,NULL,NULL,'West Darrionberg','MI','48383','USA','1496820789');
CALL InsUpStdCustomerSp (NULL,'Chester','Thiel',NULL,'49866 Fahey Shoals',NULL,NULL,NULL,'West Roselyn','LO','94723','USA','8412347964');
CALL InsUpStdCustomerSp (NULL,'Avis','Torphy',NULL,'969 Andreane Estates',NULL,NULL,NULL,'Abbottfurt','SO','61447','USA','5204467730');
CALL InsUpStdCustomerSp (NULL,'Caleigh','Will',NULL,'0984 Hubert Courts',NULL,NULL,NULL,'Leonardomouth','ID','14423','USA','2150989392');
CALL InsUpStdCustomerSp (NULL,'Margot','Graham',NULL,'33154 Aiyana Spur',NULL,NULL,NULL,'Murraychester','NE','95586','USA','1707947969');
CALL InsUpStdCustomerSp (NULL,'Zachariah','Lebsack',NULL,'46002 Gulgowski Throughway',NULL,NULL,NULL,'Gageshire','MI','71184','USA','1678409773');
CALL InsUpStdCustomerSp (NULL,'Dee','Tremblay',NULL,'450 Cristina Trail',NULL,NULL,NULL,'New Karlitown','SO','76387','USA','1287276775');
CALL InsUpStdCustomerSp (NULL,'Diego','Gaylord',NULL,'24566 Joseph Island',NULL,NULL,NULL,'Schowalterview','TE','33018','USA','7226692616');
CALL InsUpStdCustomerSp (NULL,'Edwina','Kulas',NULL,'81886 Alford Route',NULL,NULL,NULL,'Destinborough','MA','16356','USA','3571108995');
CALL InsUpStdCustomerSp (NULL,'Jermey','Williamson',NULL,'3061 Grant Plaza',NULL,NULL,NULL,'Baronburgh','KE','22225','USA','1741785221');
CALL InsUpStdCustomerSp (NULL,'Idell','Terry',NULL,'63105 Stoltenberg Mews',NULL,NULL,NULL,'Lake Miguel','NO','44346','USA','1774636410');
CALL InsUpStdCustomerSp (NULL,'Richard','OKeefe',NULL,'4417 Crawford Unions',NULL,NULL,NULL,'North Theafurt','GE','78491','USA','6659963363');
CALL InsUpStdCustomerSp (NULL,'Monty','Monahan',NULL,'6504 Blick Rest',NULL,NULL,NULL,'North Jackfort','OR','27340','USA','0387098414');
CALL InsUpStdCustomerSp (NULL,'Peggie','Rau',NULL,'43986 Von Falls',NULL,NULL,NULL,'Mariahtown','RH','81289','USA','6592478733');
CALL InsUpStdCustomerSp (NULL,'Liam','Johns',NULL,'478 Sister Lock',NULL,NULL,NULL,'Madelynburgh','MI','25958','USA','1757116807');
CALL InsUpStdCustomerSp (NULL,'Garry','Mayer',NULL,'675 Kiehn Square',NULL,NULL,NULL,'South Anahi','HA','84342','USA','7043261833');
CALL InsUpStdCustomerSp (NULL,'Arlo','Mayert',NULL,'561 Elinor Hills',NULL,NULL,NULL,'Joeymouth','MI','72205','USA','6918766770');
CALL InsUpStdCustomerSp (NULL,'Jed','Parisian',NULL,'00961 Ferry Ports',NULL,NULL,NULL,'Ziemehaven','VE','34051','USA','5086836293');
CALL InsUpStdCustomerSp (NULL,'Madonna','Senger',NULL,'60252 Dulce Isle',NULL,NULL,NULL,'North Felicita','FL','74290','USA','2085933657');
CALL InsUpStdCustomerSp (NULL,'Sydni','Harvey',NULL,'965 Eldon Ramp',NULL,NULL,NULL,'Franeckibury','UT','24908','USA','6795785147');
CALL InsUpStdCustomerSp (NULL,'Keshaun','Kassulke',NULL,'998 Katherine Port',NULL,NULL,NULL,'Kuhlmanhaven','TE','81575','USA','1940061641');
CALL InsUpStdCustomerSp (NULL,'Daniela','Mayer',NULL,'07887 Donato Pass',NULL,NULL,NULL,'Rheamouth','NE','86611','USA','8691876538');
CALL InsUpStdCustomerSp (NULL,'Mireya','OKon',NULL,'71774 Dalton Tunnel',NULL,NULL,NULL,'Alyciamouth','CO','00170','USA','0455631981');
CALL InsUpStdCustomerSp (NULL,'Dawson','Bradtke',NULL,'7817 Sporer Street',NULL,NULL,NULL,'Mosciskichester','KA','82550','USA','2820164046');
CALL InsUpStdCustomerSp (NULL,'Shana','Schmeler',NULL,'82373 Stroman Forest',NULL,NULL,NULL,'New Josiah','TE','50201','USA','8290240764');
CALL InsUpStdCustomerSp (NULL,'Freeman','Wilkinson',NULL,'7245 Alexane Shore',NULL,NULL,NULL,'Robertsstad','DE','96863','USA','1059762892');
CALL InsUpStdCustomerSp (NULL,'Delphine','Rice',NULL,'5673 Rohan Mission',NULL,NULL,NULL,'Lake Arihaven','NE','50865','USA','7820284452');
CALL InsUpStdCustomerSp (NULL,'Ashtyn','Gaylord',NULL,'70574 Nader Streets',NULL,NULL,NULL,'Port Kaitlin','MI','42136','USA','1715533843');
CALL InsUpStdCustomerSp (NULL,'Destini','Bauch',NULL,'23719 Stiedemann Lock',NULL,NULL,NULL,'Tarastad','ID','23378','USA','3672928295');
CALL InsUpStdCustomerSp (NULL,'Laura','Roberts',NULL,'581 Anderson Burgs',NULL,NULL,NULL,'Claudieland','MA','79923','USA','6544430481');
CALL InsUpStdCustomerSp (NULL,'Waylon','Ruecker',NULL,'81160 Juliana Pine',NULL,NULL,NULL,'Caylafurt','SO','48410','USA','1934149288');
CALL InsUpStdCustomerSp (NULL,'Elta','Berge',NULL,'433 Shields Parkway',NULL,NULL,NULL,'Rodriguezbury','NE','33077','USA','1472573261');
CALL InsUpStdCustomerSp (NULL,'Boyd','Bogan',NULL,'2155 Briana Extension',NULL,NULL,NULL,'West Carlee','WY','67298','USA','4618488391');
CALL InsUpStdCustomerSp (NULL,'Desmond','Quigley',NULL,'449 Aufderhar Overpass',NULL,NULL,NULL,'Wendyside','NE','6680','USA','4704468619');
CALL InsUpStdCustomerSp (NULL,'Keanu','Wyman',NULL,'2762 Mosciski Wall',NULL,NULL,NULL,'North Jade','OH','95440','USA','6374029536');
CALL InsUpStdCustomerSp (NULL,'Kamille','Cummerata',NULL,'061 Belle Spur',NULL,NULL,NULL,'Henrietteside','MI','94812','USA','3878424791');
CALL InsUpStdCustomerSp (NULL,'Virginia','Jast',NULL,'981 Ariane Circles',NULL,NULL,NULL,'Lottieview','AL','76904','USA','9043863115');
CALL InsUpStdCustomerSp (NULL,'Kailyn','Heller',NULL,'8689 Jones Freeway',NULL,NULL,NULL,'Carytown','UT','48798','USA','6754293890');
CALL InsUpStdCustomerSp (NULL,'Ena','Hettinger',NULL,'3547 Hegmann Spurs',NULL,NULL,NULL,'Brandynton','MA','83698','USA','1614838322');
CALL InsUpStdCustomerSp (NULL,'Levi','Dickinson',NULL,'41463 Eleanore Villages',NULL,NULL,NULL,'New Barneyport','CO','92921','USA','1839106695');
CALL InsUpStdCustomerSp (NULL,'Dale','Baumbach',NULL,'9154 Sanford Forest',NULL,NULL,NULL,'West Alice','RH','49198','USA','3913383115');
CALL InsUpStdCustomerSp (NULL,'Margarete','Kreiger',NULL,'5424 Will Route',NULL,NULL,NULL,'East Abigailville','VI','32297','USA','4675770938');
CALL InsUpStdCustomerSp (NULL,'Alexa','McClure',NULL,'433 Eulalia Overpass',NULL,NULL,NULL,'Lednerfurt','NE','81826','USA','1902940572');
CALL InsUpStdCustomerSp (NULL,'Oswald','Yost',NULL,'994 Mayert Inlet',NULL,NULL,NULL,'Inesport','NO','8970','USA','2421381445');
CALL InsUpStdCustomerSp (NULL,'Malika','Kassulke',NULL,'308 Morissette Via',NULL,NULL,NULL,'Hellerview','WA','35678','USA','4201170948');
CALL InsUpStdCustomerSp (NULL,'Wade','Wehner',NULL,'1181 Considine Fork',NULL,NULL,NULL,'New Karolannshire','VE','37199','USA','1643811498');
CALL InsUpStdCustomerSp (NULL,'Leila','Okuneva',NULL,'78000 Lolita Hills',NULL,NULL,NULL,'Port Ayla','LO','30277','USA','6815256366');
CALL InsUpStdCustomerSp (NULL,'Winfield','Nikolaus',NULL,'0417 Annamarie Village',NULL,NULL,NULL,'Cummingsborough','MA','64818','USA','6099673113');
CALL InsUpStdCustomerSp (NULL,'Adele','Waters',NULL,'01795 Kuhlman Village',NULL,NULL,NULL,'North Katelin','IN','30998','USA','3475234857');
CALL InsUpStdCustomerSp (NULL,'Cassie','Hane',NULL,'588 Treutel Village',NULL,NULL,NULL,'North Elainastad','MO','95419','USA','2020689642');
CALL InsUpStdCustomerSp (NULL,'Bernadine','Russel',NULL,'174 Diamond Point',NULL,NULL,NULL,'Pricestad','RH','77485','USA','8660406302');
CALL InsUpStdCustomerSp (NULL,'Leann','Shanahan',NULL,'674 Thelma Port',NULL,NULL,NULL,'Weimannville','NE','47283','USA','1823039589');
CALL InsUpStdCustomerSp (NULL,'Rosalinda','Beier',NULL,'8642 Sporer Center',NULL,NULL,NULL,'South Tremaynemouth','VE','81348','USA','3257387110');
CALL InsUpStdCustomerSp (NULL,'Lori','King',NULL,'83873 Aufderhar Roads',NULL,NULL,NULL,'Faheyshire','UT','7916','USA','3039233181');
CALL InsUpStdCustomerSp (NULL,'Krystel','Waters',NULL,'910 Zulauf Causeway',NULL,NULL,NULL,'New Patrick','DE','22524','USA','1960203837');
CALL InsUpStdCustomerSp (NULL,'Jed','Abernathy',NULL,'1419 Violet Rue',NULL,NULL,NULL,'Creminview','GE','98012','USA','1080677414');
CALL InsUpStdCustomerSp (NULL,'Laurianne','Pagac',NULL,'152 Kub Shoal',NULL,NULL,NULL,'Laurenceshire','AR','53042','USA','1093427796');
CALL InsUpStdCustomerSp (NULL,'Estell','Ferry',NULL,'41658 Connelly Streets',NULL,NULL,NULL,'North Damonshire','MO','82763','USA','6572378138');
CALL InsUpStdCustomerSp (NULL,'Bradley','Stanton',NULL,'27945 Madisyn Shoals',NULL,NULL,NULL,'Rosaliahaven','WA','59305','USA','8201525597');
CALL InsUpStdCustomerSp (NULL,'Keara','Glover',NULL,'39173 Diego Brook',NULL,NULL,NULL,'Pagachaven','CO','44599','USA','2190415974');
CALL InsUpStdCustomerSp (NULL,'Elias','Donnelly',NULL,'39186 Jameson Ports',NULL,NULL,NULL,'New Sylvester','KE','38865','USA','8674077991');
CALL InsUpStdCustomerSp (NULL,'Chyna','Lynch',NULL,'476 Bogisich Light',NULL,NULL,NULL,'Port Maggie','SO','96025','USA','2225481479');
CALL InsUpStdCustomerSp (NULL,'Melany','OHara',NULL,'26510 Karine Street',NULL,NULL,NULL,'Braunmouth','VI','34304','USA','1322628477');
CALL InsUpStdCustomerSp (NULL,'Gregory','King',NULL,'484 OConner Islands',NULL,NULL,NULL,'South Kirstin','OR','62760','USA','9682920635');
CALL InsUpStdCustomerSp (NULL,'Bret','Simonis',NULL,'79117 Lea Ridge',NULL,NULL,NULL,'Dickiton','SO','58172','USA','2159232262');
CALL InsUpStdCustomerSp (NULL,'Aileen','Reinger',NULL,'8616 Wuckert Brooks',NULL,NULL,NULL,'West Sadiemouth','GE','07589','USA','4902123587');
CALL InsUpStdCustomerSp (NULL,'Jon','Upton',NULL,'3341 Shanahan Knolls',NULL,NULL,NULL,'New Dixieland','OR','63513','USA','8393777087');
CALL InsUpStdCustomerSp (NULL,'Guillermo','Cartwright',NULL,'56237 Thiel Common',NULL,NULL,NULL,'South Cordeliaside','LO','41342','USA','3623482632');
CALL InsUpStdCustomerSp (NULL,'Devan','Reilly',NULL,'308 Mafalda Locks',NULL,NULL,NULL,'Elmiraville','NO','19324','USA','1822127067');
CALL InsUpStdCustomerSp (NULL,'Nicholas','Durgan',NULL,'143 Wyman Spur',NULL,NULL,NULL,'Lake Monroeburgh','OR','40877','USA','7560071105');
CALL InsUpStdCustomerSp (NULL,'Keon','Stroman',NULL,'952 Savannah Station',NULL,NULL,NULL,'Zboncakshire','AL','40240','USA','4179062990');
CALL InsUpStdCustomerSp (NULL,'Sharon','Hackett',NULL,'7985 Jillian Mountains',NULL,NULL,NULL,'New Evelynmouth','CA','67311','USA','7852544801');
CALL InsUpStdCustomerSp (NULL,'Stefan','Hahn',NULL,'62126 Lea Via',NULL,NULL,NULL,'North Twila','NE','28423','USA','3373238916');
CALL InsUpStdCustomerSp (NULL,'Lesley','Breitenberg',NULL,'2253 Abbott Station',NULL,NULL,NULL,'Serenityview','GE','17653','USA','9894071367');
CALL InsUpStdCustomerSp (NULL,'Julien','Quitzon',NULL,'3843 Olin Well',NULL,NULL,NULL,'Powlowskimouth','NO','33542','USA','5052656655');
CALL InsUpStdCustomerSp (NULL,'Otho','Stokes',NULL,'71809 Reta Harbors',NULL,NULL,NULL,'Kaelaville','RH','77184','USA','5102837434');
CALL InsUpStdCustomerSp (NULL,'Keanu','Carroll',NULL,'270 Aufderhar Extension',NULL,NULL,NULL,'West Jadon','GE','29114','USA','6155331377');
CALL InsUpStdCustomerSp (NULL,'Moshe','Becker',NULL,'8744 Mikayla Ramp',NULL,NULL,NULL,'Wolfftown','KA','66727','USA','0685358092');
CALL InsUpStdCustomerSp (NULL,'Geovanni','Zulauf',NULL,'12959 Nolan Squares',NULL,NULL,NULL,'West Jordanport','AR','09982','USA','1053922446');
CALL InsUpStdCustomerSp (NULL,'Jamel','Herman',NULL,'48355 Stacy Curve',NULL,NULL,NULL,'McClureview','TE','38600','USA','0220316190');
CALL InsUpStdCustomerSp (NULL,'Kiarra','Schmitt',NULL,'71193 McKenzie Mountains',NULL,NULL,NULL,'North Dejon','OH','46891','USA','7324121947');
CALL InsUpStdCustomerSp (NULL,'Ashlynn','Legros',NULL,'3768 Jakubowski Groves',NULL,NULL,NULL,'Lake Triston','MI','43978','USA','2404403421');
CALL InsUpStdCustomerSp (NULL,'Gerhard','Nienow',NULL,'99294 Mariam Meadows',NULL,NULL,NULL,'Port Cordie','MA','78276','USA','6326785177');
CALL InsUpStdCustomerSp (NULL,'Ocie','Deckow',NULL,'76151 Bogan Roads',NULL,NULL,NULL,'Lake Edwina','WE','07557','USA','6838368148');
CALL InsUpStdCustomerSp (NULL,'Beverly','Larkin',NULL,'8561 Dagmar Street',NULL,NULL,NULL,'Dickifort','CO','86640','USA','3792113743');
CALL InsUpStdCustomerSp (NULL,'Don','Becker',NULL,'599 Harªann Route',NULL,NULL,NULL,'Port Stanley','MA','29232','USA','0938437739');
CALL InsUpStdCustomerSp (NULL,'Jacklyn','Rolfson',NULL,'676 Grant Fords',NULL,NULL,NULL,'Jerelburgh','MA','41668','USA','4437056877');
CALL InsUpStdCustomerSp (NULL,'Jeramy','Littel',NULL,'8777 Schroeder Island',NULL,NULL,NULL,'Jacobsonmouth','DE','31398','USA','1255671491');
CALL InsUpStdCustomerSp (NULL,'Jamie','Keebler',NULL,'11777 Jacobs Crescent',NULL,NULL,NULL,'Lake Blair','WA','34706','USA','9423545611');
CALL InsUpStdCustomerSp (NULL,'Dominique','Gorczany',NULL,'2798 Hirthe Islands',NULL,NULL,NULL,'New Justen','VE','55031','USA','7359093209');
CALL InsUpStdCustomerSp (NULL,'Camryn','Rodriguez',NULL,'51873 Addison Trail',NULL,NULL,NULL,'Lake Daija','MA','87579','USA','1604062811');
CALL InsUpStdCustomerSp (NULL,'Reece','Braun',NULL,'083 Hamill Parks',NULL,NULL,NULL,'Judgemouth','WY','61368','USA','2857821807');
CALL InsUpStdCustomerSp (NULL,'Lizeth','Fay',NULL,'299 Lincoln Coves',NULL,NULL,NULL,'Lenoraburgh','RH','94748','USA','7106445820');
CALL InsUpStdCustomerSp (NULL,'Lucio','Mertz',NULL,'7401 Moen Ways',NULL,NULL,NULL,'North Lura','NE','72871','USA','0760568031');
CALL InsUpStdCustomerSp (NULL,'Guillermo','Feil',NULL,'06749 Grady Mission',NULL,NULL,NULL,'New Kyla','IO','75530','USA','1872775110');
CALL InsUpStdCustomerSp (NULL,'Piper','Greenfelder',NULL,'12639 Tressa Heights',NULL,NULL,NULL,'North Breanaview','WA','25079','USA','3611850843');
CALL InsUpStdCustomerSp (NULL,'Meaghan','Lindgren',NULL,'5048 Adela Terrace',NULL,NULL,NULL,'East Bradleyland','WE','97621','USA','7855737865');
CALL InsUpStdCustomerSp (NULL,'Name','Corkery',NULL,'556 Pfannerstill Place',NULL,NULL,NULL,'Port Nora','FL','30532','USA','1425958344');
CALL InsUpStdCustomerSp (NULL,'Burley','Kunde',NULL,'107 Gabriella Turnpike',NULL,NULL,NULL,'East Kathrynechester','HA','42373','USA','7206330779');
CALL InsUpStdCustomerSp (NULL,'Kiley','Jast',NULL,'58732 Shanahan Hills',NULL,NULL,NULL,'Wisokyborough','OH','71799','USA','2292962203');
CALL InsUpStdCustomerSp (NULL,'Marguerite','Ortiz',NULL,'4697 Herzog Haven',NULL,NULL,NULL,'Hudsonbury','DE','40873','USA','1946677192');
CALL InsUpStdCustomerSp (NULL,'Alexanne','Adams',NULL,'8954 Carlo Glens',NULL,NULL,NULL,'Wyattbury','MI','29588','USA','3283317454');
CALL InsUpStdCustomerSp (NULL,'Pablo','Cartwright',NULL,'12619 Parisian Common',NULL,NULL,NULL,'Kathleenmouth','VE','17000','USA','3270650777');
CALL InsUpStdCustomerSp (NULL,'Elisa','OKon',NULL,'32465 Maya Rue',NULL,NULL,NULL,'New Clifford','NE','55131','USA','7179091110');
CALL InsUpStdCustomerSp (NULL,'Catherine','Connelly',NULL,'930 Claude Fords',NULL,NULL,NULL,'Lake Mackshire','NE','19849','USA','9905414228');
CALL InsUpStdCustomerSp (NULL,'Teagan','White',NULL,'2291 Kory Crossing',NULL,NULL,NULL,'Watersburgh','CO','79031','USA','1063578647');
CALL InsUpStdCustomerSp (NULL,'Leopold','Armstrong',NULL,'1850 Block Trail',NULL,NULL,NULL,'East Margaretshire','NE','59299','USA','3207607362');
CALL InsUpStdCustomerSp (NULL,'Domingo','Stehr',NULL,'7707 Gottlieb Falls',NULL,NULL,NULL,'Hickleburgh','WY','82500','USA','0426504821');
CALL InsUpStdCustomerSp (NULL,'Hershel','Homenick',NULL,'6961 Berge Mission',NULL,NULL,NULL,'West Flavioview','LO','81297','USA','9431034047');
CALL InsUpStdCustomerSp (NULL,'Lois','Wintheiser',NULL,'2475 Coralie Falls',NULL,NULL,NULL,'North Brock','OK','76067','USA','1935814718');
CALL InsUpStdCustomerSp (NULL,'Stan','Keeling',NULL,'866 Kitty Coves',NULL,NULL,NULL,'Osinskiton','MA','14386','USA','9628546722');
CALL InsUpStdCustomerSp (NULL,'Jayne','Beier',NULL,'911 Kade Village',NULL,NULL,NULL,'New Ahmed','LO','47019','USA','8499981093');
CALL InsUpStdCustomerSp (NULL,'Jennifer','Morar',NULL,'903 Lavern Path',NULL,NULL,NULL,'Lake Gage','CO','32885','USA','5679343959');
CALL InsUpStdCustomerSp (NULL,'Rex','Sauer',NULL,'6167 Fay Keys',NULL,NULL,NULL,'Kadinborough','KE','83616','USA','2536442258');
CALL InsUpStdCustomerSp (NULL,'Fern','Kovacek',NULL,'9449 Caleb Motorway',NULL,NULL,NULL,'North Fosterton','AL','59206','USA','9092607028');
CALL InsUpStdCustomerSp (NULL,'Vladimir','Klocko',NULL,'21989 Durgan Plain',NULL,NULL,NULL,'Kaitlynville','MI','43827','USA','1310397453');
CALL InsUpStdCustomerSp (NULL,'Keven','Kassulke',NULL,'78646 Lavonne Island',NULL,NULL,NULL,'Hardyville','GE','97485','USA','1802739933');
CALL InsUpStdCustomerSp (NULL,'Freda','Feest',NULL,'317 Easton ',NULL,NULL,NULL,'Lowefort','MI','25556','USA','1613780711');
CALL InsUpStdCustomerSp (NULL,'Selina','Bergnaum',NULL,'56539 Casper Corners',NULL,NULL,NULL,'Reingerborough','WE','34170','USA','7632615411');
CALL InsUpStdCustomerSp (NULL,'Alfred','Kunze',NULL,'93600 Reichel Club',NULL,NULL,NULL,'New Nickolas','AR','81332','USA','7187087173');
CALL InsUpStdCustomerSp (NULL,'Daisha','Miller',NULL,'160 Spencer Shoal',NULL,NULL,NULL,'Port Clinthaven','MA','89384','USA','5553000316');
CALL InsUpStdCustomerSp (NULL,'Imani','Upton',NULL,'833 Muriel Tunnel',NULL,NULL,NULL,'Lake Palma','WI','75713','USA','7926041701');
CALL InsUpStdCustomerSp (NULL,'Kelli','Shields',NULL,'03319 Ray Camp',NULL,NULL,NULL,'New Skylarshire','NE','82574','USA','8158549379');
CALL InsUpStdCustomerSp (NULL,'Adelia','Green',NULL,'1454 May Square',NULL,NULL,NULL,'Tommiehaven','MA','69207','USA','1399556532');
CALL InsUpStdCustomerSp (NULL,'Karli','Jewess',NULL,'38814 Ashtyn Plains',NULL,NULL,NULL,'New Samanthashire','FL','70639','USA','5733589899');
CALL InsUpStdCustomerSp (NULL,'Lois','Witting',NULL,'6513 Schowalter Pike',NULL,NULL,NULL,'Bahringerhaven','TE','15462','USA','0998222438');
CALL InsUpStdCustomerSp (NULL,'Tyson','Gottlieb',NULL,'19795 Dach Mill',NULL,NULL,NULL,'Fisherfurt','WE','90362','USA','5950396099');
CALL InsUpStdCustomerSp (NULL,'Justine','Dooley',NULL,'1509 Toney Haven',NULL,NULL,NULL,'South Lorine','PE','24394','USA','0793652479');
CALL InsUpStdCustomerSp (NULL,'Alvina','Morar',NULL,'87094 Maybelle Hill',NULL,NULL,NULL,'Kubshire','NE','1397','USA','1980762487');
CALL InsUpStdCustomerSp (NULL,'Jenifer','Shields',NULL,'162 Theo Mall',NULL,NULL,NULL,'New Susanaside','IO','19717','USA','0765225917');
CALL InsUpStdCustomerSp (NULL,'Isaac','OHara',NULL,'09167 Rau Hill',NULL,NULL,NULL,'Dietrichshire','NE','36545','USA','5210714847');
CALL InsUpStdCustomerSp (NULL,'Marcelina','Moore',NULL,'7001 Vandervort Ranch',NULL,NULL,NULL,'Aliyahborough','MI','26714','USA','1273935492');
CALL InsUpStdCustomerSp (NULL,'Hyman','Roberts',NULL,'10536 Feest Trafficway',NULL,NULL,NULL,'East Elvis','FL','2619','USA','1425475391');
CALL InsUpStdCustomerSp (NULL,'Jacques','Dach',NULL,'0630 Frederique Hills',NULL,NULL,NULL,'New Domenic','MI','41717','USA','1669846623');
CALL InsUpStdCustomerSp (NULL,'Lonnie','Treutel',NULL,'3743 Jamar Lock',NULL,NULL,NULL,'Celialand','MI','69309','USA','5266483827');
CALL InsUpStdCustomerSp (NULL,'Harvey','Hayes',NULL,'97978 Bert Springs',NULL,NULL,NULL,'Beattyton','IO','5045','USA','8053765331');
CALL InsUpStdCustomerSp (NULL,'Lilian','Smitham',NULL,'5207 Brakus Isle',NULL,NULL,NULL,'West Edmund','WI','86459','USA','1790526772');
CALL InsUpStdCustomerSp (NULL,'Aracely','Johnson',NULL,'46720 Andres Valley',NULL,NULL,NULL,'West Brisaberg','TE','52447','USA','1540611507');
CALL InsUpStdCustomerSp (NULL,'Emory','Mills',NULL,'95420 Bernhard Courts',NULL,NULL,NULL,'East Lindsay','CA','42305','USA','0099315388');
CALL InsUpStdCustomerSp (NULL,'Yasmine','Jast',NULL,'1878 Jerde Centers',NULL,NULL,NULL,'Schambergerberg','FL','18938','USA','2779274284');
CALL InsUpStdCustomerSp (NULL,'Mollie','Rohan',NULL,'53683 Weimann Isle',NULL,NULL,NULL,'Daughertyberg','VI','90463','USA','9588474211');
CALL InsUpStdCustomerSp (NULL,'Brody','West',NULL,'3148 Felicita Knoll',NULL,NULL,NULL,'Lake Alyce','NE','23099','USA','5384243719');
CALL InsUpStdCustomerSp (NULL,'Justice','Kling',NULL,'7743 Rowe Gateway',NULL,NULL,NULL,'Sipesberg','FL','72707','USA','5738564355');
CALL InsUpStdCustomerSp (NULL,'Josiah','Pagac',NULL,'18425 Kory Junctions',NULL,NULL,NULL,'Ervinberg','SO','55937','USA','2517972129');
CALL InsUpStdCustomerSp (NULL,'Claire','Stracke',NULL,'800 Legros Branch',NULL,NULL,NULL,'New Stephaniaborough','IN','47501','USA','1655506155');
CALL InsUpStdCustomerSp (NULL,'Tevin','Bashirian',NULL,'8645 Danial Turnpike',NULL,NULL,NULL,'East Wilburn','UT','12807','USA','1545327322');
CALL InsUpStdCustomerSp (NULL,'Delilah','Hansen',NULL,'863 West Fort',NULL,NULL,NULL,'Lake Melba','VE','59454','USA','3956174381');
CALL InsUpStdCustomerSp (NULL,'Sharon','Paucek',NULL,'5857 Harvey Fort',NULL,NULL,NULL,'East Laron','CO','14525','USA','8830392448');
CALL InsUpStdCustomerSp (NULL,'Raoul','McCullough',NULL,'3218 Smith Views',NULL,NULL,NULL,'Codyport','NO','81606','USA','1101442705');
CALL InsUpStdCustomerSp (NULL,'Freida','Cummings',NULL,'378 Altenwerth Highway',NULL,NULL,NULL,'South Mariana','NO','85413','USA','5048783460');
CALL InsUpStdCustomerSp (NULL,'Cole','Fahey',NULL,'018 Mariah Run',NULL,NULL,NULL,'North Rylee','CA','00135','USA','2641524312');
CALL InsUpStdCustomerSp (NULL,'Gloria','Hoppe',NULL,'8807 Reichel Path',NULL,NULL,NULL,'Connellymouth','KE','86688','USA','1169270261');
CALL InsUpStdCustomerSp (NULL,'Johnson','Shanahan',NULL,'89145 Joey Throughway',NULL,NULL,NULL,'Ericabury','VI','21266','USA','9573679144');
CALL InsUpStdCustomerSp (NULL,'Austin','Torphy',NULL,'629 Marcelino Knoll',NULL,NULL,NULL,'North Hillardfort','LO','33178','USA','4587030309');
CALL InsUpStdCustomerSp (NULL,'Kavon','Huels',NULL,'8199 Mertz Mission',NULL,NULL,NULL,'Hollytown','IN','6232','USA','1918057167');
CALL InsUpStdCustomerSp (NULL,'Sunny','Homenick',NULL,'08637 Skiles Junctions',NULL,NULL,NULL,'McCulloughborough','VE','48694','USA','5494837845');
CALL InsUpStdCustomerSp (NULL,'Lonzo','Deckow',NULL,'1443 Lexus Points',NULL,NULL,NULL,'Rosalindafort','MI','48235','USA','1035353514');
CALL InsUpStdCustomerSp (NULL,'Tre','Roberts',NULL,'529 Karen View',NULL,NULL,NULL,'South Keshawn','MA','11730','USA','0009878450');
CALL InsUpStdCustomerSp (NULL,'Maximilian','Kuhlman',NULL,'5694 Lubowitz Shoals',NULL,NULL,NULL,'Port Gertrude','OK','83788','USA','9272652495');
CALL InsUpStdCustomerSp (NULL,'Deon','Parisian',NULL,'0866 Goodwin Streets',NULL,NULL,NULL,'Kshlerinstad','TE','96567','USA','6666175567');
CALL InsUpStdCustomerSp (NULL,'Adaline','Considine',NULL,'07018 Schiller Spurs',NULL,NULL,NULL,'Daremouth','MI','18370','USA','9020130617');
CALL InsUpStdCustomerSp (NULL,'Alexanne','Ruecker',NULL,'4940 Olson Flat',NULL,NULL,NULL,'Port Ronaldo','AL','31386','USA','3101420711');
CALL InsUpStdCustomerSp (NULL,'Mavis','Zemlak',NULL,'24199 Farrell Ridges',NULL,NULL,NULL,'Felicitashire','MO','22889','USA','8340703859');
CALL InsUpStdCustomerSp (NULL,'Jules','Stroman',NULL,'0164 Kyla Lock',NULL,NULL,NULL,'East Cyrus','SO','68104','USA','2586933367');
CALL InsUpStdCustomerSp (NULL,'Heber','Murphy',NULL,'81522 Tyrell Ridge',NULL,NULL,NULL,'Lake Keiramouth','LO','67536','USA','1060805875');
CALL InsUpStdCustomerSp (NULL,'Golda','Larkin',NULL,'2566 Colleen Land',NULL,NULL,NULL,'Metzland','CO','86895','USA','1561018134');
CALL InsUpStdCustomerSp (NULL,'Estevan','Donnelly',NULL,'2408 Raynor Shore',NULL,NULL,NULL,'Lake Nameview','OH','57515','USA','2117131807');
CALL InsUpStdCustomerSp (NULL,'Hudson','Heaney',NULL,'32130 Rosina Common',NULL,NULL,NULL,'Johnston','IN','31874','USA','3350209431');
CALL InsUpStdCustomerSp (NULL,'Lorna','Hyatt',NULL,'39800 Luettgen Walks',NULL,NULL,NULL,'Halvorsonside','NE','57886','USA','4834220829');
CALL InsUpStdCustomerSp (NULL,'Erick','Wilkinson',NULL,'399 Alisa Roads',NULL,NULL,NULL,'East Kaden','MA','22531','USA','6032611072');
CALL InsUpStdCustomerSp (NULL,'Walton','Kilback',NULL,'55977 Pearlie Ridge',NULL,NULL,NULL,'Lake Lillychester','OR','27199','USA','1615775794');
CALL InsUpStdCustomerSp (NULL,'Eulalia','Maggio',NULL,'784 Lehner Spur',NULL,NULL,NULL,'Lake Aglaeville','IO','37451','USA','6871898666');
CALL InsUpStdCustomerSp (NULL,'Delores','Mueller',NULL,'464 Nannie Village',NULL,NULL,NULL,'Wendyshire','WI','99827','USA','1250627962');
CALL InsUpStdCustomerSp (NULL,'Meda','Feeney',NULL,'6383 Aurore Forks',NULL,NULL,NULL,'New Will','TE','88730','USA','0810523019');
CALL InsUpStdCustomerSp (NULL,'Wendy','Boyer',NULL,'5041 Eriberto Cove',NULL,NULL,NULL,'Mosciskiberg','CA','11592','USA','8240094332');
CALL InsUpStdCustomerSp (NULL,'Bertha','Kertzmann',NULL,'2550 Ericka Springs',NULL,NULL,NULL,'Svenmouth','NE','39604','USA','4384521564');
CALL InsUpStdCustomerSp (NULL,'Chester','Schinner',NULL,'5081 Kassulke Lock',NULL,NULL,NULL,'North Kristinabury','WY','42377','USA','2803815338');
CALL InsUpStdCustomerSp (NULL,'Garnet','OHara',NULL,'7812 Schneider Manors',NULL,NULL,NULL,'North Emeliachester','WI','11098','USA','2997267877');
CALL InsUpStdCustomerSp (NULL,'Kris','Bins',NULL,'73175 Macejkovic Groves',NULL,NULL,NULL,'Heidenreichchester','VI','45271','USA','0177512785');
CALL InsUpStdCustomerSp (NULL,'Reagan','Hudson',NULL,'97716 Dach Ferry',NULL,NULL,NULL,'Keenanbury','SO','88509','USA','8746000523');
CALL InsUpStdCustomerSp (NULL,'Marcel','Cartwright',NULL,'4404 Mafalda Walks',NULL,NULL,NULL,'West Keenan','WE','97737','USA','9466038688');
CALL InsUpStdCustomerSp (NULL,'Earl','Turcotte',NULL,'6433 Schimmel Divide',NULL,NULL,NULL,'East Sebastian','MI','54396','USA','7083112567');
CALL InsUpStdCustomerSp (NULL,'Wanda','Roberts',NULL,'97094 Larissa Ferry',NULL,NULL,NULL,'Adrienfurt','NE','57725','USA','2568097995');
CALL InsUpStdCustomerSp (NULL,'Hal','Padberg',NULL,'250 Reuben Mission',NULL,NULL,NULL,'East Sarinafort','OK','21099','USA','0787051834');
CALL InsUpStdCustomerSp (NULL,'Devante','Muller',NULL,'71183 Felicia Mountains',NULL,NULL,NULL,'South Nicohaven','VE','4682','USA','2007503858');
CALL InsUpStdCustomerSp (NULL,'Ray','Dare',NULL,'7604 Reid Union',NULL,NULL,NULL,'South Ricochester','CA','70457','USA','1602321034');
CALL InsUpStdCustomerSp (NULL,'Beverly','Zemlak',NULL,'556 Hyatt Viaduct',NULL,NULL,NULL,'Turnerfort','WY','64857','USA','7000822761');
CALL InsUpStdCustomerSp (NULL,'Antonietta','OHara',NULL,'45944 Augustine Bridge',NULL,NULL,NULL,'Legrosburgh','ID','47824','USA','1231203425');
CALL InsUpStdCustomerSp (NULL,'Kolby','Adams',NULL,'98085 Alejandra Key',NULL,NULL,NULL,'Port Antonetteside','MA','88979','USA','1008614760');
CALL InsUpStdCustomerSp (NULL,'Elda','Feeney',NULL,'70442 Kailey Meadow',NULL,NULL,NULL,'Cletafurt','MA','57164','USA','7121860755');
CALL InsUpStdCustomerSp (NULL,'Ernestina','Schumm',NULL,'956 McKenzie Center',NULL,NULL,NULL,'South Arielleview','MA','08754','USA','9990881369');
CALL InsUpStdCustomerSp (NULL,'Effie','Larson',NULL,'4566 Jasmin Forges',NULL,NULL,NULL,'South Kristinfurt','AR','87670','USA','7274377602');
CALL InsUpStdCustomerSp (NULL,'Oral','Osinski',NULL,'2071 Heaven Freeway',NULL,NULL,NULL,'Friesenmouth','IN','49648','USA','7536711327');
CALL InsUpStdCustomerSp (NULL,'Curt','Jacobs',NULL,'998 Davion Streets',NULL,NULL,NULL,'Lebsackbury','CA','03400','USA','2040687492');
CALL InsUpStdCustomerSp (NULL,'Leilani','Mosciski',NULL,'3156 Ora Avenue',NULL,NULL,NULL,'Lake Waldo','OH','28287','USA','4134760177');
CALL InsUpStdCustomerSp (NULL,'Leslie','Mraz',NULL,'1041 Braun Path',NULL,NULL,NULL,'Runolfssontown','WI','13645','USA','1494916600');
CALL InsUpStdCustomerSp (NULL,'Gust','Predovic',NULL,'9320 Hamill Bypass',NULL,NULL,NULL,'Lavonneburgh','CO','47200','USA','7236296608');
CALL InsUpStdCustomerSp (NULL,'Angeline','Howe',NULL,'4005 Langworth Lights',NULL,NULL,NULL,'East Arafort','LO','39042','USA','7233469333');
CALL InsUpStdCustomerSp (NULL,'Jaron','Labadie',NULL,'960 Janae Islands',NULL,NULL,NULL,'North Joana','FL','78381','USA','4237329066');
CALL InsUpStdCustomerSp (NULL,'Ofelia','Kuhlman',NULL,'7854 Schinner Pines',NULL,NULL,NULL,'Lake Lilly','NE','34940','USA','5698308996');
CALL InsUpStdCustomerSp (NULL,'Emilia','Maggio',NULL,'0022 Walton Ports',NULL,NULL,NULL,'Ornborough','TE','36409','USA','7668128202');
CALL InsUpStdCustomerSp (NULL,'Catharine','Jewess',NULL,'5315 Wyman Squares',NULL,NULL,NULL,'New Steviefurt','MA','30381','USA','0108675776');
CALL InsUpStdCustomerSp (NULL,'Alanis','Becker',NULL,'51737 Huels Mews',NULL,NULL,NULL,'North Lonnieview','IN','30047','USA','8301788924');
CALL InsUpStdCustomerSp (NULL,'Adolph','Gusikowski',NULL,'99377 Greenfelder Brooks',NULL,NULL,NULL,'Colbyville','WA','38781','USA','1339251212');
CALL InsUpStdCustomerSp (NULL,'Angelina','Schuster',NULL,'246 Nitzsche Fall',NULL,NULL,NULL,'Chaddshire','NE','05259','USA','6673668794');
CALL InsUpStdCustomerSp (NULL,'Dortha','Kessler',NULL,'01868 Veum Unions',NULL,NULL,NULL,'Jackmouth','TE','51137','USA','8260660917');
CALL InsUpStdCustomerSp (NULL,'Weston','Oberbrunner',NULL,'34898 Yasmeen Locks',NULL,NULL,NULL,'Raynorhaven','NE','86817','USA','3527074569');
CALL InsUpStdCustomerSp (NULL,'Jaclyn','Strosin',NULL,'59812 Johnny Row',NULL,NULL,NULL,'Morarside','SO','51052','USA','0819072791');
CALL InsUpStdCustomerSp (NULL,'Alta','Feeney',NULL,'701 Gloria Via',NULL,NULL,NULL,'Merleton','HA','83098','USA','1121009006');
CALL InsUpStdCustomerSp (NULL,'Sonia','Boyer',NULL,'24682 Thompson Square',NULL,NULL,NULL,'West Bradford','NE','43747','USA','1817511438');
CALL InsUpStdCustomerSp (NULL,'Ervin','Spinka',NULL,'996 Bartell Shores',NULL,NULL,NULL,'Wizaberg','OR','27072','USA','1565274887');
CALL InsUpStdCustomerSp (NULL,'Kaitlin','Rogahn',NULL,'07231 Cronin Mount',NULL,NULL,NULL,'Fredericview','FL','73019','USA','1949848994');
CALL InsUpStdCustomerSp (NULL,'Elda','Roberts',NULL,'9989 Leanne Circle',NULL,NULL,NULL,'Hudsonside','GE','8295','USA','8760543404');
CALL InsUpStdCustomerSp (NULL,'Jaylen','Stokes',NULL,'84705 Metz Tunnel',NULL,NULL,NULL,'Port Nicklaus','FL','39492','USA','3966418952');
CALL InsUpStdCustomerSp (NULL,'Amber','Shanahan',NULL,'31867 Beer Ridges',NULL,NULL,NULL,'Port Axel','MI','30442','USA','1703447643');
CALL InsUpStdCustomerSp (NULL,'Maybell','Hayes',NULL,'08700 Kihn Ferry',NULL,NULL,NULL,'Port Lance','IN','16126','USA','8102842115');
CALL InsUpStdCustomerSp (NULL,'Hans','Reichert',NULL,'2108 OHara Square',NULL,NULL,NULL,'Wintheiserberg','NE','66891','USA','8026542481');
CALL InsUpStdCustomerSp (NULL,'Laurianne','Parker',NULL,'6646 Agnes Coves',NULL,NULL,NULL,'North Roma','HA','95847','USA','9898422359');
CALL InsUpStdCustomerSp (NULL,'Kaylin','Hoeger',NULL,'5869 Russel Drive',NULL,NULL,NULL,'Tillmanmouth','WY','68211','USA','8734454259');
CALL InsUpStdCustomerSp (NULL,'Korbin','Bruen',NULL,'2968 Yadira Meadow',NULL,NULL,NULL,'Lake Omariburgh','OH','44433','USA','7033304658');
CALL InsUpStdCustomerSp (NULL,'Leilani','Morar',NULL,'1760 Friesen Inlet',NULL,NULL,NULL,'South Eloisemouth','MA','43492','USA','1378596018');
CALL InsUpStdCustomerSp (NULL,'Vergie','Walsh',NULL,'111 Brendan Mill',NULL,NULL,NULL,'Barrowsberg','GE','96446','USA','2435989573');
CALL InsUpStdCustomerSp (NULL,'Jaycee','Ernser',NULL,'6464 Hoeger Wall',NULL,NULL,NULL,'East Deontaefort','PE','56258','USA','1700142187');
CALL InsUpStdCustomerSp (NULL,'Linwood','Lang',NULL,'65042 Lilla Pass',NULL,NULL,NULL,'East Haydenburgh','MA','47335','USA','4281452227');
CALL InsUpStdCustomerSp (NULL,'Karianne','Hermiston',NULL,'4217 Schinner Isle',NULL,NULL,NULL,'Port Marjorieport','WY','97720','USA','0124803934');
CALL InsUpStdCustomerSp (NULL,'Rosemarie','Hilll',NULL,'4330 Prudence Extension',NULL,NULL,NULL,'Watersmouth','AR','09918','USA','5518151521');
CALL InsUpStdCustomerSp (NULL,'Lenny','Kshlerin',NULL,'592 Schmitt Centers',NULL,NULL,NULL,'Randaltown','ID','33879','USA','1683024272');
CALL InsUpStdCustomerSp (NULL,'Destini','Emard',NULL,'3536 Nienow Plaza',NULL,NULL,NULL,'Dachborough','MA','04309','USA','6792085481');
CALL InsUpStdCustomerSp (NULL,'Desiree','Cruickshank',NULL,'11250 Landen Mill',NULL,NULL,NULL,'Lake Bret','TE','50585','USA','1103814344');
CALL InsUpStdCustomerSp (NULL,'Major','Miller',NULL,'52024 Evalyn Vista',NULL,NULL,NULL,'Nolanport','SO','27211','USA','1464983360');
CALL InsUpStdCustomerSp (NULL,'Rod','Block',NULL,'8301 Littel Road',NULL,NULL,NULL,'Shaniahaven','AL','02195','USA','1042283909');
CALL InsUpStdCustomerSp (NULL,'Jonathan','Kutch',NULL,'164 Dickens Island',NULL,NULL,NULL,'Port Carmel','NO','22048','USA','1248379030');
CALL InsUpStdCustomerSp (NULL,'Cary','Hessel',NULL,'861 Nikolaus Turnpike',NULL,NULL,NULL,'Andersonshire','MI','01730','USA','9880166461');
CALL InsUpStdCustomerSp (NULL,'Filomena','Zulauf',NULL,'385 Noe Corners',NULL,NULL,NULL,'New Alexshire','KA','51197','USA','3670270028');
CALL InsUpStdCustomerSp (NULL,'Gladyce','Schumm',NULL,'2911 Walter Parkways',NULL,NULL,NULL,'New Brianamouth','DE','36199','USA','1009671658');
CALL InsUpStdCustomerSp (NULL,'Althea','Hettinger',NULL,'26404 Koby Fall',NULL,NULL,NULL,'South Tomasa','NE','59977','USA','0770026555');
CALL InsUpStdCustomerSp (NULL,'Sallie','OHara',NULL,'742 Pete Squares',NULL,NULL,NULL,'Brianaville','KA','12260','USA','6157571238');
CALL InsUpStdCustomerSp (NULL,'Elenora','Flatley',NULL,'0302 Denesik Vista',NULL,NULL,NULL,'New Pedromouth','WE','77879','USA','1112395666');
CALL InsUpStdCustomerSp (NULL,'Derick','Smitham',NULL,'746 Wolf Drives',NULL,NULL,NULL,'Nathentown','MA','81147','USA','1305022870');
CALL InsUpStdCustomerSp (NULL,'Elenor','Herzog',NULL,'932 Orval Village',NULL,NULL,NULL,'South Diego','OR','58597','USA','1359115298');
CALL InsUpStdCustomerSp (NULL,'Jonathon','Bode',NULL,'492 DAmore Islands',NULL,NULL,NULL,'Dellmouth','MI','69478','USA','1883677780');
CALL InsUpStdCustomerSp (NULL,'Trent','McDermott',NULL,'523 Eleazar Square',NULL,NULL,NULL,'Port Judyfurt','IN','49894','USA','4014472904');
CALL InsUpStdCustomerSp (NULL,'Axel','Ward',NULL,'92465 OConnell Village',NULL,NULL,NULL,'Ritaview','MA','77478','USA','1899982894');
CALL InsUpStdCustomerSp (NULL,'Freida','Rolfson',NULL,'8642 Hilton Locks',NULL,NULL,NULL,'New Wilmer','LO','82719','USA','7676608946');
CALL InsUpStdCustomerSp (NULL,'Zoie','Hickle',NULL,'462 Chandler Valleys',NULL,NULL,NULL,'Terryland','AR','81317','USA','6620521104');
CALL InsUpStdCustomerSp (NULL,'Frederique','Quigley',NULL,'91545 Pacocha Forges',NULL,NULL,NULL,'Nicholasview','NE','90474','USA','1877851611');
CALL InsUpStdCustomerSp (NULL,'Rodrick','Bartoletti',NULL,'988 Cummings Pines',NULL,NULL,NULL,'East Bethanyside','NE','30037','USA','1962571175');
CALL InsUpStdCustomerSp (NULL,'Layne','Kunde',NULL,'2495 Vito Glens',NULL,NULL,NULL,'West Viva','WY','55074','USA','9225207336');
CALL InsUpStdCustomerSp (NULL,'Rosalyn','Muller',NULL,'757 Leola Ports',NULL,NULL,NULL,'Lake Camilabury','MA','42893','USA','1693126554');
CALL InsUpStdCustomerSp (NULL,'Giovanny','Rogahn',NULL,'06181 Wyatt Island',NULL,NULL,NULL,'Avisland','WE','82128','USA','9098335919');
CALL InsUpStdCustomerSp (NULL,'Ivy','Okuneva',NULL,'681 Hayes Neck',NULL,NULL,NULL,'Harrisonville','NO','69746','USA','2758446600');
CALL InsUpStdCustomerSp (NULL,'Cedrick','Davis',NULL,'331 OKon Summit',NULL,NULL,NULL,'New Lacyhaven','HA','76126','USA','6360787966');
CALL InsUpStdCustomerSp (NULL,'Gail','Kautzer',NULL,'299 Dolores Roads',NULL,NULL,NULL,'Port Kenna','NE','69718','USA','3979138002');
CALL InsUpStdCustomerSp (NULL,'Antonietta','Schuster',NULL,'2923 Schmeler Freeway',NULL,NULL,NULL,'East Chaseborough','CA','42147','USA','1024958662');
CALL InsUpStdCustomerSp (NULL,'Jorge','Klein',NULL,'5590 Albert Key',NULL,NULL,NULL,'North Valerie','NO','54701','USA','3449613262');
CALL InsUpStdCustomerSp (NULL,'Macy','Reinger',NULL,'718 Chester Pines',NULL,NULL,NULL,'Berniefurt','IL','13290','USA','1572093348');
CALL InsUpStdCustomerSp (NULL,'Alec','Walker',NULL,'3763 Nyasia Route',NULL,NULL,NULL,'Hanschester','HA','52405','USA','1505214908');
CALL InsUpStdCustomerSp (NULL,'Alysha','Turcotte',NULL,'425 Adolphus Dam',NULL,NULL,NULL,'Reaganland','IL','71629','USA','9971705047');
CALL InsUpStdCustomerSp (NULL,'Mertie','Pollich',NULL,'72373 Ulises Port',NULL,NULL,NULL,'Port Steviefurt','VE','32022','USA','2755734291');
CALL InsUpStdCustomerSp (NULL,'Aiyana','Hintz',NULL,'1927 Waters Mountains',NULL,NULL,NULL,'South Marina','MA','73691','USA','9317553705');
CALL InsUpStdCustomerSp (NULL,'Mya','Boyle',NULL,'61945 Braun Prairie',NULL,NULL,NULL,'East Brandyberg','SO','05494','USA','9195003324');
CALL InsUpStdCustomerSp (NULL,'Bradford','Harris',NULL,'62035 Burdette Curve',NULL,NULL,NULL,'Lake Luz','WA','12124','USA','6389357174');
CALL InsUpStdCustomerSp (NULL,'Tyrique','DAmore',NULL,'830 Alysa Skyway',NULL,NULL,NULL,'North Nannieland','MA','69209','USA','5991543024');
CALL InsUpStdCustomerSp (NULL,'Lorine','Konopelski',NULL,'2457 Vandervort Center',NULL,NULL,NULL,'Port Rubenland','AR','41819','USA','3653626006');
CALL InsUpStdCustomerSp (NULL,'Javier','Buckridge',NULL,'42394 Ariel Unions',NULL,NULL,NULL,'Lake Barney','VI','81978','USA','4790171899');
CALL InsUpStdCustomerSp (NULL,'Randy','Marquardt',NULL,'89181 Thea Stravenue',NULL,NULL,NULL,'Kiehnhaven','FL','41800','USA','3236483651');
CALL InsUpStdCustomerSp (NULL,'Lesly','Anderson',NULL,'05162 Jackson Locks',NULL,NULL,NULL,'Beverlystad','MA','34289','USA','1747503584');
CALL InsUpStdCustomerSp (NULL,'Ella','Reichel',NULL,'45215 Skiles Squares',NULL,NULL,NULL,'South Kieranland','MI','88256','USA','1777221915');
CALL InsUpStdCustomerSp (NULL,'Nedra','Steuber',NULL,'24131 Hyatt Stream',NULL,NULL,NULL,'Merlemouth','OH','64227','USA','0168185362');
CALL InsUpStdCustomerSp (NULL,'Marilou','Hansen',NULL,'9208 Kilback Coves',NULL,NULL,NULL,'Tremblayburgh','WE','55974','USA','4024396271');
CALL InsUpStdCustomerSp (NULL,'Karianne','Franecki',NULL,'8142 Aimee Curve',NULL,NULL,NULL,'East Samirshire','TE','52980','USA','1139334914');
CALL InsUpStdCustomerSp (NULL,'Viola','Guªann',NULL,'6623 Murazik Port',NULL,NULL,NULL,'Lake Sibyl','NE','63623','USA','4019447958');
CALL InsUpStdCustomerSp (NULL,'Cody','Nader',NULL,'72830 Marvin Lane',NULL,NULL,NULL,'Torpfurt','MA','81934','USA','1887771209');
CALL InsUpStdCustomerSp (NULL,'Willis','Funk',NULL,'841 Ova Trail',NULL,NULL,NULL,'Torpside','NE','33393','USA','1703433904');
CALL InsUpStdCustomerSp (NULL,'Westley','Boyle',NULL,'939 Billy Shoals',NULL,NULL,NULL,'Hoppefurt','AL','46344','USA','7242725404');
CALL InsUpStdCustomerSp (NULL,'Mara','Willms',NULL,'7389 Heloise Spur',NULL,NULL,NULL,'Tristianton','RH','72483','USA','0561557062');
CALL InsUpStdCustomerSp (NULL,'Caden','Hansen',NULL,'669 OKon Trail',NULL,NULL,NULL,'Lake Milan','AR','61260','USA','1385572886');
CALL InsUpStdCustomerSp (NULL,'Claudia','Gibson',NULL,'544 Assunta Park',NULL,NULL,NULL,'Gaylordhaven','CO','57821','USA','1269017930');
CALL InsUpStdCustomerSp (NULL,'Freddie','Altenwerth',NULL,'841 Annabel Skyway',NULL,NULL,NULL,'Burnicemouth','KA','01193','USA','1029751840');
CALL InsUpStdCustomerSp (NULL,'Elisa','Fritsch',NULL,'55165 Eleanore Turnpike',NULL,NULL,NULL,'Anabelleport','MA','20215','USA','5519370991');
CALL InsUpStdCustomerSp (NULL,'Lizzie','Lind',NULL,'694 Weissnat Tunnel',NULL,NULL,NULL,'Teresatown','MA','71627','USA','1464027408');
CALL InsUpStdCustomerSp (NULL,'Charity','Barton',NULL,'58573 Elfrieda Unions',NULL,NULL,NULL,'Jenkinsside','HA','23071','USA','6958511011');
CALL InsUpStdCustomerSp (NULL,'Lauriane','Marks',NULL,'615 Ernser Station',NULL,NULL,NULL,'Pamelahaven','NE','30057','USA','9884343222');
CALL InsUpStdCustomerSp (NULL,'Brennon','Bogisich',NULL,'899 Patsy Course',NULL,NULL,NULL,'East Orinberg','FL','76628','USA','8696607854');
CALL InsUpStdCustomerSp (NULL,'Flavie','Dietrich',NULL,'0740 Toy Forges',NULL,NULL,NULL,'Port Hesterfurt','NO','13143','USA','2337306970');
CALL InsUpStdCustomerSp (NULL,'Lesley','Macejkovic',NULL,'3821 Fahey Extensions',NULL,NULL,NULL,'Zulauffort','WE','38014','USA','0565795613');
CALL InsUpStdCustomerSp (NULL,'Jacky','Cartwright',NULL,'239 Rempel Islands',NULL,NULL,NULL,'Kreigerburgh','AR','23304','USA','3339112774');
CALL InsUpStdCustomerSp (NULL,'Lloyd','Weber',NULL,'721 Brayan Grove',NULL,NULL,NULL,'Kesslerview','WY','30642','USA','1052481980');
CALL InsUpStdCustomerSp (NULL,'Obie','Swift',NULL,'934 Zackary Fork',NULL,NULL,NULL,'New Ernamouth','TE','85297','USA','2875231831');
CALL InsUpStdCustomerSp (NULL,'Avis','Graham',NULL,'0314 Robb Fort',NULL,NULL,NULL,'Ferryland','MI','11421','USA','1096280340');
CALL InsUpStdCustomerSp (NULL,'Peter','Larson',NULL,'8938 Spinka Lock',NULL,NULL,NULL,'Port Finn','RH','59361','USA','1448366043');
CALL InsUpStdCustomerSp (NULL,'Adam','Wisoky',NULL,'256 Padberg Throughway',NULL,NULL,NULL,'East Addieburgh','MI','68902','USA','0422742261');
CALL InsUpStdCustomerSp (NULL,'Bettye','Kemmer',NULL,'541 Rippin Oval',NULL,NULL,NULL,'Schambergermouth','OR','70673','USA','7044808583');
CALL InsUpStdCustomerSp (NULL,'Jaylan','McGlynn',NULL,'24570 Carol Estate',NULL,NULL,NULL,'Marquesfort','HA','18067','USA','1042964886');
CALL InsUpStdCustomerSp (NULL,'Thaddeus','Reichel',NULL,'602 Bogisich Alley',NULL,NULL,NULL,'West Kyle','NE','07296','USA','1114570765');
CALL InsUpStdCustomerSp (NULL,'Annie','Rolfson',NULL,'695 Emie Rue',NULL,NULL,NULL,'North Kirstin','MA','64443','USA','5606173246');
CALL InsUpStdCustomerSp (NULL,'Maxwell','Koepp',NULL,'76759 Hettinger Forest',NULL,NULL,NULL,'South Andyshire','MA','55040','USA','4147698606');
CALL InsUpStdCustomerSp (NULL,'Charles','Harber',NULL,'32502 Jamey Pines',NULL,NULL,NULL,'East Carole','IO','68452','USA','8222547782');
CALL InsUpStdCustomerSp (NULL,'Emely','Olson',NULL,'76133 Ramon Road',NULL,NULL,NULL,'Port Kelvinshire','NO','81120','USA','3176918407');
CALL InsUpStdCustomerSp (NULL,'Tate','Swaniawski',NULL,'98680 Lindsay View',NULL,NULL,NULL,'Lake Kennethport','IN','79255','USA','1214823006');
CALL InsUpStdCustomerSp (NULL,'Judge','Stamm',NULL,'803 Ricky Ranch',NULL,NULL,NULL,'West Geovannystad','IL','70089','USA','6577833313');
CALL InsUpStdCustomerSp (NULL,'Dale','Breitenberg',NULL,'2073 Hailie Bridge',NULL,NULL,NULL,'Feeneyton','MI','79548','USA','1719955393');
CALL InsUpStdCustomerSp (NULL,'Braxton','Haag',NULL,'245 Feest Islands',NULL,NULL,NULL,'Bogisichburgh','AR','99794','USA','3201670024');
CALL InsUpStdCustomerSp (NULL,'Yessenia','Heaney',NULL,'72540 Neal Trail',NULL,NULL,NULL,'Babystad','TE','31313','USA','7738766469');
CALL InsUpStdCustomerSp (NULL,'Raquel','Littel',NULL,'105 Schaden Key',NULL,NULL,NULL,'South Henrifort','FL','27613','USA','5101336749');
CALL InsUpStdCustomerSp (NULL,'Elsa','Lakin',NULL,'4952 Nikolaus Burgs',NULL,NULL,NULL,'Samsonfurt','HA','15560','USA','1173825703');
CALL InsUpStdCustomerSp (NULL,'Glen','Deckow',NULL,'928 Dixie Way',NULL,NULL,NULL,'Hollyfurt','IO','74062','USA','1980572041');
CALL InsUpStdCustomerSp (NULL,'Edwina','Steuber',NULL,'032 Krajcik Village',NULL,NULL,NULL,'New Randallfurt','TE','49872','USA','4464167228');
CALL InsUpStdCustomerSp (NULL,'Demond','Heidenreich',NULL,'67509 Augustus Ranch',NULL,NULL,NULL,'Harveyville','RH','36840','USA','1522891976');
CALL InsUpStdCustomerSp (NULL,'Kiarra','Raynor',NULL,'963 Johnston Haven',NULL,NULL,NULL,'Milanbury','OH','25742','USA','0979803314');
CALL InsUpStdCustomerSp (NULL,'Carlos','Beer',NULL,'521 Lavinia Pike',NULL,NULL,NULL,'North Allisonview','GE','44814','USA','6686618710');
CALL InsUpStdCustomerSp (NULL,'Prudence','Moen',NULL,'5749 Okuneva Oval',NULL,NULL,NULL,'West Dorcas','LO','78735','USA','1791623024');
CALL InsUpStdCustomerSp (NULL,'Wilson','OConner',NULL,'860 Bergstrom Union',NULL,NULL,NULL,'Lake Hadleyhaven','OR','46579','USA','1958248710');
CALL InsUpStdCustomerSp (NULL,'Jackson','Treutel',NULL,'319 Elda Manors',NULL,NULL,NULL,'Strosinmouth','IL','37113','USA','6609536882');
CALL InsUpStdCustomerSp (NULL,'Cornell','Mosciski',NULL,'24415 Pollich Lock',NULL,NULL,NULL,'Vivaport','AL','49268','USA','0595755270');
CALL InsUpStdCustomerSp (NULL,'Pat','Marks',NULL,'245 Shields Neck',NULL,NULL,NULL,'East Murl','AR','98809','USA','1050252714');
CALL InsUpStdCustomerSp (NULL,'Emmalee','Hoeger',NULL,'41758 Briana Prairie',NULL,NULL,NULL,'New Phoebeville','MI','01807','USA','0767838943');
CALL InsUpStdCustomerSp (NULL,'Makenna','Wuckert',NULL,'960 Rico Vista',NULL,NULL,NULL,'Gorczanyberg','WI','2703','USA','1235238462');
CALL InsUpStdCustomerSp (NULL,'Jarrett','Bednar',NULL,'367 Crist Flats',NULL,NULL,NULL,'Carolhaven','LO','55153','USA','1175657342');
CALL InsUpStdCustomerSp (NULL,'Gretchen','Morar',NULL,'498 Dooley Throughway',NULL,NULL,NULL,'Kohlertown','SO','72220','USA','6234483531');
CALL InsUpStdCustomerSp (NULL,'Brycen','Pfeffer',NULL,'2282 Hunter Cove',NULL,NULL,NULL,'Leolachester','KE','93447','USA','1490160232');
CALL InsUpStdCustomerSp (NULL,'Giovanni','Hessel',NULL,'75562 Jedediah Crossroad',NULL,NULL,NULL,'Lake Fanny','MI','14302','USA','1714122401');
CALL InsUpStdCustomerSp (NULL,'Sophie','Graham',NULL,'757 Gisselle Forges',NULL,NULL,NULL,'New Logan','TE','57613','USA','6172654496');
CALL InsUpStdCustomerSp (NULL,'Rogelio','Wyman',NULL,'2822 Jones Mews',NULL,NULL,NULL,'South Haileestad','SO','19828','USA','1010567698');
CALL InsUpStdCustomerSp (NULL,'Ramona','Lynch',NULL,'04427 Feeney Ways',NULL,NULL,NULL,'Schummchester','NO','15332','USA','8965321184');
CALL InsUpStdCustomerSp (NULL,'Nikki','Christiansen',NULL,'99417 Stracke Orchard',NULL,NULL,NULL,'West Lawrence','TE','29500','USA','9118971126');
CALL InsUpStdCustomerSp (NULL,'Mckenna','Reynolds',NULL,'668 Gina Courts',NULL,NULL,NULL,'Shadchester','TE','53735','USA','1049469444');
CALL InsUpStdCustomerSp (NULL,'Julie','Schaefer',NULL,'336 OKeefe Fall',NULL,NULL,NULL,'Lake Elaina','KA','68731','USA','1594520698');
CALL InsUpStdCustomerSp (NULL,'Tara','Rogahn',NULL,'176 Carmen Creek',NULL,NULL,NULL,'Barrowsville','TE','14330','USA','8468183903');
CALL InsUpStdCustomerSp (NULL,'Alexane','Champlin',NULL,'401 Rempel Gateway',NULL,NULL,NULL,'Walshville','WE','49285','USA','1619280096');
CALL InsUpStdCustomerSp (NULL,'Consuelo','Pfannerstill',NULL,'1653 Kessler Turnpike',NULL,NULL,NULL,'Willardshire','AL','35205','USA','8862122514');
CALL InsUpStdCustomerSp (NULL,'Amani','Jones',NULL,'143 Harªann Corners',NULL,NULL,NULL,'New Deangelofurt','HA','28637','USA','7848121738');
CALL InsUpStdCustomerSp (NULL,'Dorothea','Prosacco',NULL,'496 Tremblay Turnpike',NULL,NULL,NULL,'Port Mae','NO','40247','USA','6017215594');
CALL InsUpStdCustomerSp (NULL,'Bertrand','Muller',NULL,'0413 Reynolds Square',NULL,NULL,NULL,'Lake Amir','OR','95747','USA','1270245073');
CALL InsUpStdCustomerSp (NULL,'Ellsworth','OKon',NULL,'42046 Murray Dale',NULL,NULL,NULL,'Bernierbury','VI','82142','USA','0982162827');
CALL InsUpStdCustomerSp (NULL,'Clark','Schumm',NULL,'0586 Botsford Square',NULL,NULL,NULL,'Lake Phoebemouth','IL','77953','USA','1279351958');
CALL InsUpStdCustomerSp (NULL,'Cleveland','Carter',NULL,'86090 Rossie Islands',NULL,NULL,NULL,'Kuhicton','NE','65712','USA','1730001316');
CALL InsUpStdCustomerSp (NULL,'Royal','Lebsack',NULL,'288 Muller Ways',NULL,NULL,NULL,'Jacobsonville','MI','69819','USA','5936089429');
CALL InsUpStdCustomerSp (NULL,'Shanelle','King',NULL,'5725 Gleichner Springs',NULL,NULL,NULL,'Bessiestad','MA','67221','USA','6538572621');
CALL InsUpStdCustomerSp (NULL,'Evangeline','Runte',NULL,'19193 Emard Stravenue',NULL,NULL,NULL,'East Vitoton','UT','49801','USA','8537276376');
CALL InsUpStdCustomerSp (NULL,'Brandon','Stark',NULL,'435 Jaunita Lake',NULL,NULL,NULL,'Terrancechester','SO','86825','USA','1501376811');
CALL InsUpStdCustomerSp (NULL,'Bertram','Wisoky',NULL,'621 Damien Path',NULL,NULL,NULL,'West Jewel','ID','19949','USA','1419470556');
CALL InsUpStdCustomerSp (NULL,'Kaley','Mills',NULL,'042 Osinski Burg',NULL,NULL,NULL,'East Mckenzie','RH','18078','USA','1610859294');
CALL InsUpStdCustomerSp (NULL,'Lonnie','Graham',NULL,'4821 Elyssa Burg',NULL,NULL,NULL,'Rahulberg','NO','20448','USA','8705343776');
CALL InsUpStdCustomerSp (NULL,'Karelle','Gottlieb',NULL,'994 Jenkins Skyway',NULL,NULL,NULL,'New Concepcionville','DE','10831','USA','9881459839');
CALL InsUpStdCustomerSp (NULL,'Beryl','Schaefer',NULL,'9772 Cronin Valleys',NULL,NULL,NULL,'Lake Londonstad','VE','83685','USA','0583024139');
CALL InsUpStdCustomerSp (NULL,'Dasia','Schuster',NULL,'6136 Karli Plains',NULL,NULL,NULL,'South Elouise','MI','58903','USA','1382347993');
CALL InsUpStdCustomerSp (NULL,'Esmeralda','Ferry',NULL,'572 Alaina Tunnel',NULL,NULL,NULL,'Bednarberg','IN','75546','USA','0891699665');
CALL InsUpStdCustomerSp (NULL,'Dallas','Weber',NULL,'74769 Schroeder Streets',NULL,NULL,NULL,'Diamondchester','WA','67861','USA','5363364934');
CALL InsUpStdCustomerSp (NULL,'Hadley','Hane',NULL,'08033 Fisher Alley',NULL,NULL,NULL,'Bruenhaven','CO','05186','USA','3908450343');
CALL InsUpStdCustomerSp (NULL,'Timothy','Nolan',NULL,'5116 Aaliyah River',NULL,NULL,NULL,'North Kaden','SO','28261','USA','1272829453');
CALL InsUpStdCustomerSp (NULL,'Jacklyn','Greenfelder',NULL,'94233 Marcus Run',NULL,NULL,NULL,'North Camylle','HA','48340','USA','1321662476');
CALL InsUpStdCustomerSp (NULL,'America','Reichert',NULL,'82766 Mante Extensions',NULL,NULL,NULL,'Lake Alejandra','MA','80808','USA','5445113473');
CALL InsUpStdCustomerSp (NULL,'Brandon','Durgan',NULL,'3497 Rollin Road',NULL,NULL,NULL,'South Justina','MI','47256','USA','1821380102');
CALL InsUpStdCustomerSp (NULL,'Trinity','Upton',NULL,'132 Stehr Walks',NULL,NULL,NULL,'Lilafurt','CO','33915','USA','9961489269');
CALL InsUpStdCustomerSp (NULL,'Vance','Cummerata',NULL,'62694 Kerluke Manor',NULL,NULL,NULL,'Port Vitabury','LO','52018','USA','1710302154');
CALL InsUpStdCustomerSp (NULL,'Jessie','Yundt',NULL,'57649 Corwin Island',NULL,NULL,NULL,'Lake Geovanny','MI','43209','USA','1211271393');
CALL InsUpStdCustomerSp (NULL,'Meta','Swaniawski',NULL,'2871 Domenick Street',NULL,NULL,NULL,'Port Randall','WY','60024','USA','7460746472');
CALL InsUpStdCustomerSp (NULL,'Lexie','Schowalter',NULL,'4619 Schmidt Light',NULL,NULL,NULL,'Sanfordberg','UT','41566','USA','7295438625');
CALL InsUpStdCustomerSp (NULL,'Lauriane','Wilderman',NULL,'219 Emard Glens',NULL,NULL,NULL,'Kareemmouth','IL','24058','USA','7299578417');


#add reservations

DROP TABLE IF EXISTS tmp_numbers;
create temporary table if not exists tmp_numbers (CustomerID int, StartDate int, Enddate int);
insert into tmp_numbers (SELECT CEILING(RAND()*100), CEILING(RAND()*100) , CEILING(RAND()*10)FROM CUSTOMER);
insert into tmp_numbers (SELECT CEILING(RAND()*1000), CEILING(RAND()*100) , CEILING(RAND()*10) FROM CUSTOMER);
insert into tmp_numbers (SELECT CEILING(RAND()*10), CEILING(RAND()*100) , CEILING(RAND()*10)FROM CUSTOMER);

INSERT INTO RESERVATION (BillToId, GuestID, EventID, RoomType, StartDate, EndDate, Rate, Deposit,RoomID, Smoking)
SELECT 
 c.CustomerID
, case (t.StartDate+t.EndDate)%17
	when 0 then FLOOR(c.CustomerID/2)+5
    when 1 then FLOOR(c.CustomerID/2)-5
    else Null end as GuestID
, Null as EventID
, (SELECT TypeNameID from Type_Name Where UsageID='RoomType' and Name = 'Sleeping') as RoomType
, ADDDATE(CURDATE(),t.StartDate) as STARTDATE
, ADDDATE(CURDATE(),t.StartDate+t.EndDate) as Enddate
, CASE t.EndDate%5
		when 0 then 115  #double
        when 1 then 140  #queen
        when 2 then 170  #king
        when 3 then 200  #queen extra space
        when 4 then 230  #king extra space
        end as rate
, 0 AS DEPOSIT
, NULL AS ROOMID  #need to prefill a few of these
, (c.CustomerId%13)%2 AS SMOKING
from Customer c  join tmp_numbers t on t.CustomerID=c.Customerid;

update reservation set guestid = null where guestid <1;

insert into RES_FEATURES
(select reservationid
, num
,case 
	when Rate in (140,200) then (SELECT TypeNameID from Type_Name where UsageID='bedtype' and name = 'Queen Bed')
    when Rate in (170, 230) then (SELECT TypeNameID from Type_Name where UsageID='bedtype' and name = 'King Bed')
    else (SELECT TypeNameID  from Type_Name where UsageID='bedtype' and name = 'Double Bed')

end as BEDTYPE
, 0 AS ProximityID
from reservation, tmp_numlist t where num<3
);

INSERT INTO RES_FEATURES
SELECT R.ReservationID,3, tn.TypeNameID, p.TypeNameID
FROM RESERVATION R
join TYPE_NAME  tn on DAY(R.STARTDATE)=TN.TypeNameID and tn.UsageID = 'FeatureID'
join TYPE_NAME P on R.RESERVATIONID%3=P.UsageRank and P.UsageID = 'ProximityID';

INSERT INTO RES_FEATURES
SELECT R.ReservationID,4, tn.TypeNameID, p.TypeNameID
FROM RESERVATION R
join TYPE_NAME  tn on DAY(R.ENDDATE)=TN.TypeNameID and tn.UsageID = 'FeatureID'
join TYPE_NAME P on R.RESERVATIONID%3=P.UsageRank and P.UsageID = 'ProximityID';


DROP TABLE if exists tmp_numlist;
COMMIT;