delimiter $$

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

delimiter ;