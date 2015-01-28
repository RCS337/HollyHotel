CREATE TABLE PROJECT(
	  ProjectID			INT			NOT NULL 		AUTO_INCREMENT  /* can't specifiy the step value without affecting the entire db or using a trigger*/
	, Name				NVARCHAR(50)	NOT NULL
	, Department		NVARCHAR(35)	NOT NULL
	, MaxHours		DOUBLE				NOT NULL 		DEFAULT 100  /*DOUBLE*/
	, StartDate		DATE					NULL
	, EndDate			DATE					NULL

	, CONSTRAINT PROJECT_PK		PRIMARY KEY(ProjectID)

	, CONSTRAINT PROJECT_FKDEPT	FOREIGN KEY (Department)
							REFERENCES DEPARTMENT(DepartmentName)
							ON UPDATE CASCADE
							ON DELETE NO ACTION
);


ALTER TABLE PROJECT AUTO_INCREMENT = 1000;