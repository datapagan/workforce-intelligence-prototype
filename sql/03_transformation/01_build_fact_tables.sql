USE DATABASE WORKFORCE_PLANNING;
USE SCHEMA CURATED;

-- Workforce Plan Fact
CREATE OR REPLACE TABLE FACT_WORKFORCE_PLAN AS
SELECT
    hc.snapshot_date,
    hc.business_unit,
    hc.department,
    hc.location_city,
    hc.location_state,
    hc.job_role,
    hc.plan_type,
    hc.planned_headcount,
    hp.hiring_needed,
    ap.attrition_expected
FROM WORKFORCE_PLANNING.RAW.HEADCOUNT_PLAN_RAW hc
LEFT JOIN WORKFORCE_PLANNING.RAW.HIRING_PLAN_RAW hp
    ON hc.snapshot_date = hp.snapshot_date
   AND hc.business_unit = hp.business_unit
   AND hc.department = hp.department
   AND hc.location_city = hp.location_city
   AND hc.location_state = hp.location_state
   AND hc.job_role = hp.job_role
   AND hc.plan_type = hp.plan_type
LEFT JOIN WORKFORCE_PLANNING.RAW.ATTRITION_PLAN_RAW ap
    ON hc.snapshot_date = ap.snapshot_date
   AND hc.business_unit = ap.business_unit
   AND hc.department = ap.department
   AND hc.location_city = ap.location_city
   AND hc.location_state = ap.location_state
   AND hc.job_role = ap.job_role
   AND hc.plan_type = ap.plan_type;

-- Actual Headcount
CREATE OR REPLACE TABLE ACTUAL_HEADCOUNT AS
SELECT
    snapshot_date,
    business_unit,
    department,
    location_city,
    location_state,
    job_role,
    SUM(EMPLOYEE_ID) AS actual_headcount
FROM WORKFORCE_PLANNING.RAW.EMPLOYEE_ACTUALS_RAW
GROUP BY
    snapshot_date,
    business_unit,
    department,
    location_city,
    location_state,
    job_role;

-- Variance Table
CREATE OR REPLACE TABLE FACT_WORKFORCE_VARIANCE AS
SELECT
    f.SNAPSHOT_DATE,
    f.BUSINESS_UNIT,
    f.DEPARTMENT,
    f.LOCATION_CITY,
    f.LOCATION_STATE,
    f.JOB_ROLE,
    f.PLAN_TYPE,
    f.PLANNED_HEADCOUNT,
    f.HIRING_NEEDED,
    f.ATTRITION_EXPECTED,
    COALESCE(a.ACTUAL_HEADCOUNT, 0) AS ACTUAL_HEADCOUNT,
    f.PLANNED_HEADCOUNT - COALESCE(a.ACTUAL_HEADCOUNT, 0) AS HEADCOUNT_GAP
FROM FACT_WORKFORCE_PLAN f
LEFT JOIN ACTUAL_HEADCOUNT a
    ON f.SNAPSHOT_DATE = a.SNAPSHOT_DATE
   AND f.BUSINESS_UNIT = a.BUSINESS_UNIT
   AND f.DEPARTMENT = a.DEPARTMENT
   AND f.LOCATION_CITY = a.LOCATION_CITY
   AND f.LOCATION_STATE = a.LOCATION_STATE
   AND f.JOB_ROLE = a.JOB_ROLE;