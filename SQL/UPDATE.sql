delimiter $$

DROP VIEW IF EXISTS ResFeaturesVw $$

CREATE VIEW ResFeaturesVw AS
select ReservationID, BedFeatureID as Bed_FeatureID, ProximityID, count(ReservationID) as Qty from res_features group by ReservationID, BedFeatureID, ProximityID
Union
select 
r.RoomID, bwf.FeatureID as Bed_FeatureID, bwf.ProximityID, 1 as Qty
from room r
join BUILDING_WING_FEATURES bwf on bwf.BuildingID=r.BuildingID and bwf.WingID=r.WingID ;

$$

delimiter ;