-- En primer lugar importamos la babses de datos al entorno
.mode csv
.import '/content/drive/MyDrive/Analitica 3/employee_survey_data.csv' employee_survey_data
.import '/content/drive/MyDrive/Analitica 3/manager_survey.csv' manager_survey_data
.import '/content/drive/MyDrive/Analitica 3/general_data.csv' general_data
.import '/content/drive/MyDrive/Analitica 3/retirement_info.csv' retirement_info
--  luego creamos las tablap para llamar los datos con EmployeeID como clave primaria

CREATE TABLE general_data_n (
    Age INTEGER,
    BusinessTravel TEXT,
    Department TEXT,
    DistanceFromHome INTEGER,
    Education INTEGER,
    EducationField TEXT,
    EmployeeCount INTEGER,
    EmployeeID INTEGER PRIMARY KEY,
    Gender TEXT,
    JobLevel INTEGER,
    JobRole TEXT,
    MaritalStatus TEXT,
    MonthlyIncome INTEGER,
    NumCompaniesWorked INTEGER,
    Over18 TEXT,
    PercentSalaryHike INTEGER,
    StandardHours INTEGER,
    StockOptionLevel INTEGER,
    TotalWorkingYears INTEGER,
    TrainingTimesLastYear INTEGER,
    YearsAtCompany INTEGER,
    YearsSinceLastPromotion INTEGER,
    YearsWithCurrManager INTEGER,
    InfoDate TEXT
);

--  Copia los datos de general_data a general_data_n
INSERT INTO general_data_n (
    Age, BusinessTravel, Department, DistanceFromHome, Education, EducationField,
    EmployeeCount, Gender, JobLevel, JobRole, MaritalStatus, MonthlyIncome,
    NumCompaniesWorked, Over18, PercentSalaryHike, StandardHours, StockOptionLevel,
    TotalWorkingYears, TrainingTimesLastYear, YearsAtCompany, YearsSinceLastPromotion,
    YearsWithCurrManager, InfoDate
)

SELECT 
    Age, BusinessTravel, Department, DistanceFromHome, Education, EducationField,
    EmployeeCount, Gender, JobLevel, JobRole, MaritalStatus, MonthlyIncome,
    NumCompaniesWorked, Over18, PercentSalaryHike, StandardHours, StockOptionLevel,
    TotalWorkingYears, TrainingTimesLastYear, YearsAtCompany, YearsSinceLastPromotion,
    YearsWithCurrManager, InfoDate
FROM general_data;

--  repetimos el proceso para crear la tabla de employee_survey_data_n con EmployeeID como clave primaria
CREATE TABLE employee_survey_data_n (
    EmployeeID INTEGER PRIMARY KEY,
    EnvironmentSatisfaction INTEGER,
    JobSatisfaction INTEGER,
    WorkLifeBalance INTEGER,
    DateSurvey TEXT
);

-- Cargamos los datos de la base importada 
INSERT INTO employee_survey_data_n (
    EnvironmentSatisfaction, JobSatisfaction, WorkLifeBalance, DateSurvey
)
SELECT 
    EnvironmentSatisfaction, JobSatisfaction, WorkLifeBalance, DateSurvey
FROM employee_survey_data;

--  repetimos el proceso nuevamente para crear la tabla de maganer_surveey 
-- con EmployeeID como clave primaria
CREATE TABLE manager_survey_n (
CREATE TABLE IF NOT EXISTS manager_survey (
    EmployeeID INTEGER PRIMARY KEY,
    JobInvolvement INTEGER,
    PerformanceRating INTEGER,
    SurveyDate TEXT
);

INSERT INTO manager_survey_n (
    JobInvolvement, PerformanceRating, SurveyDate
)
SELECT 
     JobInvolvement, PerformanceRating, SurveyDate
FROM manager_survey;



-- Ahora Conviertimos el formato de fecha en las tablas
UPDATE general_data SET InfoDate = strftime('%Y-%m-%d', InfoDate);
UPDATE employee_survey_data SET DateSurvey = strftime('%Y-%m-%d', DateSurvey);
UPDATE manager_survey_data SET SurveyDate = strftime('%Y-%m-%d', SurveyDate);

-- Separamos las bases de datos por años
CREATE TABLE general_data_2015 AS
SELECT * FROM general_data WHERE strftime('%Y', InfoDate) = '2015';

CREATE TABLE general_data_2016 AS
SELECT * FROM general_data WHERE strftime('%Y', InfoDate) = '2016';

CREATE TABLE employee_survey_data_2015 AS
SELECT * FROM employee_survey_data WHERE strftime('%Y', DateSurvey) = '2015';

CREATE TABLE employee_survey_data_2016 AS
SELECT * FROM employee_survey_data WHERE strftime('%Y', DateSurvey) = '2016';

CREATE TABLE manager_survey_data_2015 AS
SELECT * FROM manager_survey_data WHERE strftime('%Y', SurveyDate) = '2015';

CREATE TABLE manager_survey_data_2016 AS
SELECT * FROM manager_survey_data WHERE strftime('%Y', SurveyDate) = '2016';

-- Unimos las tablas del 2015
CREATE TABLE total_2015 AS
SELECT gd.*, esd.*, msd.*
FROM general_data_2015 gd
LEFT JOIN employee_survey_data_2015 esd ON gd.EmployeeID = esd.EmployeeID
LEFT JOIN manager_survey_data_2015 msd ON gd.EmployeeID = msd.EmployeeID;

-- Unimos las tablas del 2016
CREATE TABLE total_2016 AS
SELECT gd.*, esd.*, msd.*
FROM general_data_2016 gd
LEFT JOIN employee_survey_data_2016 esd ON gd.EmployeeID = esd.EmployeeID
LEFT JOIN manager_survey_data_2016 msd ON gd.EmployeeID = msd.EmployeeID;

-- Concatenar las tablas del 2015 y 2016 para dejar todo en una sola sin duplicados
CREATE TABLE merged_total AS
SELECT * FROM total_2015
UNION ALL
SELECT * FROM total_2016;

-- Agregamos la tabla de retiros
CREATE TABLE final_table AS
SELECT mt.*, ri.*
FROM merged_total mt
LEFT JOIN retirement_info ri ON mt.EmployeeID = ri.EmployeeID;

-- Eliminamos columnas sobrantes
CREATE TABLE final_table_cleaned AS
SELECT
    ft.EmployeeID,
    ft.InfoDate,
    ft.DateSurvey,
    ft.SurveyDate
FROM final_table ft;

-- Verificamos duplicados
SELECT COUNT(*) FROM final_table_cleaned WHERE EmployeeID IN (SELECT EmployeeID FROM final_table_cleaned GROUP BY EmployeeID HAVING COUNT(*) > 1);

-- Mostramos los primeros registros del DataFrame fusionado y verificamos que este bien
SELECT * FROM final_table_cleaned LIMIT 10;

