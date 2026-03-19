USE DATABASE WORKFORCE_PLANNING;
USE SCHEMA RAW;

-- Employee Actuals
CREATE OR REPLACE TABLE EMPLOYEE_ACTUALS_RAW (
    snapshot_date DATE,
    business_unit STRING,
    department STRING,
    location_city STRING,
    location_state STRING,
    job_role STRING,
    employee_id NUMBER,
    tenure_years NUMBER,
    age NUMBER
);

COPY INTO EMPLOYEE_ACTUALS_RAW
FROM @STG_WORKFORCE_FILES/employee_actuals.csv.gz
FILE_FORMAT = (FORMAT_NAME = FF_WORKFORCE_CSV);

-- Headcount Plan
CREATE OR REPLACE TABLE HEADCOUNT_PLAN_RAW (
    snapshot_date DATE,
    business_unit STRING,
    department STRING,
    location_city STRING,
    location_state STRING,
    job_role STRING,
    plan_type STRING,
    planned_headcount NUMBER
);

COPY INTO HEADCOUNT_PLAN_RAW
FROM @STG_WORKFORCE_FILES/headcount_plan.csv.gz
FILE_FORMAT = (FORMAT_NAME = FF_WORKFORCE_CSV);

-- Hiring Plan
CREATE OR REPLACE TABLE HIRING_PLAN_RAW (
    snapshot_date DATE,
    business_unit STRING,
    department STRING,
    location_city STRING,
    location_state STRING,
    job_role STRING,
    plan_type STRING,
    hiring_needed NUMBER
);

COPY INTO HIRING_PLAN_RAW
FROM @STG_WORKFORCE_FILES/hiring_plan.csv.gz
FILE_FORMAT = (FORMAT_NAME = FF_WORKFORCE_CSV);

-- Attrition Plan
CREATE OR REPLACE TABLE ATTRITION_PLAN_RAW (
    snapshot_date DATE,
    business_unit STRING,
    department STRING,
    location_city STRING,
    location_state STRING,
    job_role STRING,
    plan_type STRING,
    attrition_expected NUMBER
);

COPY INTO ATTRITION_PLAN_RAW
FROM @STG_WORKFORCE_FILES/attrition_plan.csv.gz
FILE_FORMAT = (FORMAT_NAME = FF_WORKFORCE_CSV);