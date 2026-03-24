USE DATABASE WORKFORCE_PLANNING;
USE SCHEMA CURATED;

-- =========================================================
-- CURATED LAYER: Workforce Planning Model
-- =========================================================
-- This script builds the curated workforce planning tables:
-- 1. FACT_WORKFORCE_PLAN
-- 2. ACTUAL_HEADCOUNT
-- 3. FACT_WORKFORCE_VARIANCE
--
-- Note:
-- EMPLOYEE_ACTUALS_RAW retains legacy column names from an
-- earlier employee-level design.
-- In the current implementation:
--   EMPLOYEE_ID   = actual_headcount
--   TENURE_YEARS = actual_hires
--   AGE          = actual_attrition
-- =========================================================

-- =========================================================
-- 1. FACT_WORKFORCE_PLAN
-- Integrates headcount plan, hiring plan, and attrition plan
-- at a consistent workforce planning grain.
-- =========================================================
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

-- =========================================================
-- 2. ACTUAL_HEADCOUNT
-- Aggregates workforce actuals to the same planning grain.
-- Legacy column EMPLOYEE_ID is used as actual_headcount.
-- =========================================================
CREATE OR REPLACE TABLE ACTUAL_HEADCOUNT AS
SELECT
    snapshot_date,
    business_unit,
    department,
    location_city,
    location_state,
    job_role,
    SUM(employee_id) AS actual_headcount
FROM WORKFORCE_PLANNING.RAW.EMPLOYEE_ACTUALS_RAW
GROUP BY
    snapshot_date,
    business_unit,
    department,
    location_city,
    location_state,
    job_role;

-- =========================================================
-- 3. FACT_WORKFORCE_VARIANCE
-- Combines workforce plan and actual workforce supply to
-- calculate workforce gap.
-- =========================================================
CREATE OR REPLACE TABLE FACT_WORKFORCE_VARIANCE AS
SELECT
    f.snapshot_date,
    f.business_unit,
    f.department,
    f.location_city,
    f.location_state,
    f.job_role,
    f.plan_type,
    COALESCE(a.actual_headcount, 0) AS actual_headcount,
    f.planned_headcount,
    f.hiring_needed,
    f.attrition_expected,
    f.planned_headcount - COALESCE(a.actual_headcount, 0) AS headcount_gap
FROM WORKFORCE_PLANNING.CURATED.FACT_WORKFORCE_PLAN f
LEFT JOIN WORKFORCE_PLANNING.CURATED.ACTUAL_HEADCOUNT a
    ON f.snapshot_date = a.snapshot_date
   AND f.business_unit = a.business_unit
   AND f.department = a.department
   AND f.location_city = a.location_city
   AND f.location_state = a.location_state
   AND f.job_role = a.job_role;