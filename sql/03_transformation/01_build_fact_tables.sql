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
    SUM(actual_headcount) AS actual_headcount
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
    f.snapshot_date,
    f.business_unit,
    f.department,
    f.location_city,
    f.location_state,
    f.job_role,
    f.plan_type,
    f.planned_headcount,
    f.hiring_needed,
    f.attrition_expected,
    a.actual_headcount,
    f.planned_headcount - a.actual_headcount AS headcount_gap
FROM FACT_WORKFORCE_PLAN f
LEFT JOIN ACTUAL_HEADCOUNT a
    ON f.snapshot_date = a.snapshot_date
   AND f.business_unit = a.business_unit
   AND f.department = a.department
   AND f.location_city = a.location_city
   AND f.location_state = a.location_state
   AND f.job_role = a.job_role;