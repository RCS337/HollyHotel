DELIMITER $$


DROP VIEW IF EXISTS RoomFeaturesVw $$

CREATE VIEW RoomFeaturesVw AS
select RoomID, BedType as Bed_FeatureID, 0 as ProximityID from Room_Beds
Union
select 
r.RoomID, bwf.FeatureID as Bed_FeatureID, bwf.ProximityID
from room r
join BUILDING_WING_FEATURES bwf on bwf.BuildingID=r.BuildingID and bwf.WingID=r.WingID

Order by RoomID;

$$


/*************************************************************************************************************************************************************/
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
END;  #if pFeatures <3
END IF;
    
   
	IF pRoomType = (Select TypeNameID from Type_Name where UsageID = 'RoomType' and Name = 'Sleeping') then
    BEGIN
		SELECT 
			sr.RoomID, sr.RoomNumber, sr.BuildingName, sr.WingName, sr.FloorNumber, sr.SmokingAllowed, sr.Beds, sr.BedTypes, sr.Features, sr.FeatureIDs
        FROM SleepRoomInfoVw sr
        where sr.RoomID not in (Select RoomID from RoomsBookedVw rb where pStartDate between rb.StartDate and rb.EndDate or pEndDate between rb.StartDate and rb.EndDate)
        and 	sr.RoomID not in (select RoomID from tmp_unmachedrooms)
        and pSmoking = sr.SmokingAllowed
        ;
    
    END;
    END IF;
	

END $$
DELIMITER ;