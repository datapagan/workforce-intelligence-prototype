-- ============================================================
-- Data Quality Validation Checks
-- Repo: workforce-intelligence-prototype
-- Purpose: Apply the same validation discipline used in
-- production analytics — verify completeness, grain integrity,
-- and reconciliation between layers before publishing.
-- ============================================================

USE DATABASE WORKFORCE_PLANNING;

-- ------------------------------------------------------------
-- CHECK 1: Row-count reconciliation, RAW -> CURATED
-- FACT_WORKFORCE_PLAN integrates three plan tables at the same
-- grain; its row count should match the headcount plan driver.
-- Expectation: differences are explainable (or zero).
-- ------------------------------------------------------------
SELECT 'HEADCOUNT_PLAN_RAW'   AS layer, COUNT(*) AS row_count FROM RAW.HEADCOUNT_PLAN_RAW
UNION ALL
SELECT 'HIRING_PLAN_RAW',            COUNT(*) FROM RAW.HIRING_PLAN_RAW
UNION ALL
SELECT 'ATTRITION_PLAN_RAW',         COUNT(*) FROM RAW.ATTRITION_PLAN_RAW
UNION ALL
SELECT 'EMPLOYEE_ACTUALS_RAW',       COUNT(*) FROM RAW.EMPLOYEE_ACTUALS_RAW
UNION ALL
SELECT 'CURATED.FACT_WORKFORCE_PLAN',COUNT(*) FROM CURATED.FACT_WORKFORCE_PLAN
UNION ALL
SELECT 'CURATED.FACT_WORKFORCE_VARIANCE', COUNT(*) FROM CURATED.FACT_WORKFORCE_VARIANCE;

-- ------------------------------------------------------------
-- CHECK 2: No NULLs on grain columns (grain integrity)
-- A NULL in any grain column breaks joins and aggregation.
-- Expectation: every count = 0.
-- ------------------------------------------------------------
SELECT
    COUNT_IF(snapshot_date  IS NULL) AS null_snapshot_date,
    COUNT_IF(business_unit  IS NULL) AS null_business_unit,
    COUNT_IF(department     IS NULL) AS null_department,
    COUNT_IF(location_city  IS NULL) AS null_location_city,
    COUNT_IF(location_state IS NULL) AS null_location_state,
    COUNT_IF(job_role       IS NULL) AS null_job_role,
    COUNT_IF(plan_type      IS NULL) AS null_plan_type
FROM CURATED.FACT_WORKFORCE_PLAN;

-- ------------------------------------------------------------
-- CHECK 3: Duplicate grain detection
-- The model's grain is one row per snapshot_date / business_unit /
-- department / location / job_role / plan_type. Duplicates here
-- silently double-count every downstream metric.
-- Expectation: zero rows returned.
-- ------------------------------------------------------------
SELECT
    snapshot_date, business_unit, department,
    location_city, location_state, job_role, plan_type,
    COUNT(*) AS dup_count
FROM CURATED.FACT_WORKFORCE_PLAN
GROUP BY ALL
HAVING COUNT(*) > 1;

-- ------------------------------------------------------------
-- CHECK 4: Metric reconciliation, CURATED -> PUBLISHED
-- Totals in the executive view must equal totals in the fact.
-- Expectation: diff columns = 0.
-- ------------------------------------------------------------
WITH fact_totals AS (
    SELECT
        SUM(planned_headcount)  AS fact_planned,
        SUM(hiring_needed)      AS fact_hiring,
        SUM(attrition_expected) AS fact_attrition
    FROM CURATED.FACT_WORKFORCE_PLAN
),
view_totals AS (
    SELECT
        SUM(total_planned_headcount)  AS view_planned,
        SUM(total_hiring_needed)      AS view_hiring,
        SUM(total_attrition_expected) AS view_attrition
    FROM PUBLISHED.VW_WORKFORCE_SUMMARY
)
SELECT
    f.fact_planned  - v.view_planned   AS planned_diff,
    f.fact_hiring   - v.view_hiring    AS hiring_diff,
    f.fact_attrition - v.view_attrition AS attrition_diff
FROM fact_totals f CROSS JOIN view_totals v;

-- ------------------------------------------------------------
-- CHECK 5: Business-rule sanity checks
-- Negative headcount or capacity ratios outside a plausible
-- band indicate upstream data or logic errors.
-- Expectation: zero rows returned.
-- ------------------------------------------------------------
SELECT *
FROM PUBLISHED.VW_WORKFORCE_SUMMARY
WHERE total_actual_headcount < 0
   OR total_planned_headcount < 0
   OR capacity_ratio < 0
   OR capacity_ratio > 3;   -- adjust band to plausible range
