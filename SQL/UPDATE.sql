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

$$

delimiter ;

