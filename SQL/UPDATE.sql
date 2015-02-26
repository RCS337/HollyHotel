delimiter $$
DROP VIEW IF EXISTS `StayChargesVw` $$

CREATE VIEW `StayChargesVw` AS
select 
sc.StayID
, r.RoomID
, r.RoomNumber
, c.Firstname
, c.LastName
, c.BillToAddress1
, c.BillToAddress2
, c.BillToAddress3
, c.BillToAddress4
, c.BillToCity
, c.BillToState
, c.BillToZip
, c.BillToCountry
, c.BillToPhoneNum
, sc.ChargeType as ChargeCodeID
, ct.Name as ChargeCode
, sc.ChargeDescription
, sc.ChargeDate
, sc.DueDate
, sc.PaidDate
from stay_charges sc
join stay s on s.StayID=sc.StayID
join stdcustomerinfovw c on c.customerid=sc.ChargeTo
join room r on r.roomid=s.RoomID
join type_name ct on ct.TypeNameID=sc.ChargeType
WHERE IFNULL(s.Checkout,NOW()) >= DATE_ADD(NOW(), INTERVAL -14 DAY) 
#COMMENT 'USED TO SUMMARIZE CHARGES WITHOUT CREATING JOINS IN THE UI'
;$$

$$




delimiter ;

