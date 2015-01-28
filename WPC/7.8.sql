
/* I have to assume that this works as it does not show up when you script out the create statement*/

ALTER TABLE `project`
ADD CONSTRAINT STARTDATECHECK		CHECK
							(StartDate < EndDate);









