describe employee;

#7.19
#Insert into EMPLOYEE(FirstName, LastName, Department, Email) (Select FirstName, LastName, Department, Email from NEW_EMPLOYEE);

#7.20
SELECT * FROM EMPLOYEE;
UPDATE EMPLOYEE SET Phone = '360-287-8810' WHERE EmployeeNumber = 11;
SELECT * FROM EMPLOYEE;


#7.21
SELECT * FROM EMPLOYEE;
UPDATE EMPLOYEE SET Department = 'Finance' WHERE EmployeeNumber = 5;
SELECT * FROM EMPLOYEE;

#7.22
SELECT * FROM EMPLOYEE;
UPDATE EMPLOYEE SET Phone = '360-287-8420' WHERE EmployeeNumber = 5;
SELECT * FROM EMPLOYEE;

#7.23
UPDATE EMPLOYEE 
SET   Department = 'Finance'
	, Phone = '360-287-8420'
WHERE EmployeeNumber = 5;
SELECT * FROM EMPLOYEE;

#7.24
UPDATE ASSIGNMENT SET HoursWorked = 60 where EmployeeNumber = 10;
SELECT * From ASSIGNMENT;

#7.25
/*
UPDATE EMPLOYEE e
INNER JOIN NEW_EMAIL ne on e.EmployeeNumber=ne.EmployeeNumber
SET Email = ne.NewEmail;
*/

#7.26
/*DELETE FROM PROJECT WHERE `NAME` = '2013 Q3 Product Plan';
select * from project;
SELECT * FROM ASSIGNMENT;*/

#7.27
/*
DELETE FROM EMPLOYEE WHERE LastName = 'Smith';
SELECT * FROM EMPLOYEE;
The records in assignment will be orphaned
*/

#7.28
/*
A Sql view is basically a stored query.  It allows the database developer to pull data from different table into a single virtual table
which helps to hid complexity
*/

#7.29
/*
Views cannot use the order by clause 
*/

#7.30
DROP VIEW IF EXISTS EmployeePhoneView;
CREATE VIEW EmployeePhoneView as
SELECT 
	  LastName as EmployeeLastname
    , FirstName as EmployeeFirstName
	, Phone as EmployeePhone
FROM EMPLOYEE;

SELECT * FROM EmployeePhoneView;


#7.31
DROP VIEW IF EXISTS FinanceEmployeePhoneView;
CREATE VIEW FinanceEmployeePhoneView as
SELECT 
	  LastName as EmployeeLastname
    , FirstName as EmployeeFirstName
	, Phone as EmployeePhone
FROM EMPLOYEE
WHERE Department = 'Finance';
SELECT * FROM FinanceEmployeePhoneView;



#7.32
DROP VIEW IF EXISTS CombinedNameEmployeePhoneView;
CREATE VIEW CombinedNameEmployeePhoneView as
SELECT 
	  CONCAT(`FirstName`,' ',`LastName`) as EmployeeName
    , Phone as EmployeePhone
FROM EMPLOYEE;
SELECT * FROM CombinedNameEmployeePhoneView;

#7.33
DROP VIEW IF EXISTS EmployeeProjectAssignmentView;
CREATE VIEW EmployeeProjectAssignmentView as
SELECT  
	  e.LastName as EmployeeLastName
	, e.FirstName as EmployeeFirstName
    , e.Phone as EmployeePhone
	, p.Name as ProjectName
FROM EMPLOYEE e
JOIN ASSIGNMENT a on e.EmployeeNumber = a.EmployeeNumber
JOIN PROJECT p on a.ProjectID =p.ProjectID;
SELECT * FROM EmployeeProjectAssignmentView;
