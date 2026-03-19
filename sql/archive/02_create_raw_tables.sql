USE DATABASE WORKFORCE_INTELLIGENCE;
USE SCHEMA RAW_WORKFORCE;

CREATE OR REPLACE TABLE EMPLOYEE_ACTUALS_RAW (
    month DATE,
    business_unit STRING,
    department STRING,
    location STRING,
    state STRING,
    job_family STRING,
    actual_headcount NUMBER,
    actual_hires NUMBER,
    actual_attrition NUMBER
);

CREATE OR REPLACE TABLE HEADCOUNT_PLAN_RAW (
    month DATE,
    business_unit STRING,
    department STRING,
    location STRING,
    state STRING,
    job_family STRING,
    scenario_name STRING,
    planned_headcount NUMBER
);

CREATE OR REPLACE TABLE HIRING_PLAN_RAW (
    month DATE,
    business_unit STRING,
    department STRING,
    location STRING,
    state STRING,
    job_family STRING,
    scenario_name STRING,
    planned_hires NUMBER
);

CREATE OR REPLACE TABLE ATTRITION_PLAN_RAW (
    month DATE,
    business_unit STRING,
    department STRING,
    location STRING,
    state STRING,
    job_family STRING,
    scenario_name STRING,
    planned_attrition NUMBER
);

CREATE OR REPLACE TABLE ORG_DIMENSION_RAW (
    business_unit STRING,
    department STRING,
    cost_center STRING,
    manager_name STRING
);

CREATE OR REPLACE TABLE LOCATION_DIMENSION_RAW (
    location STRING,
    state STRING,
    country STRING,
    region STRING
);