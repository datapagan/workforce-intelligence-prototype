USE DATABASE WORKFORCE_PLANNING;
USE SCHEMA CURATED;

CREATE OR REPLACE VIEW VW_WORKFORCE_SUMMARY AS
SELECT
    snapshot_date,
    business_unit,
    plan_type,
    SUM(actual_headcount) AS total_actual_headcount,
    SUM(planned_headcount) AS total_planned_headcount,
    SUM(hiring_needed) AS total_hiring_needed,
    SUM(attrition_expected) AS total_attrition_expected,
    SUM(headcount_gap) AS total_headcount_gap,
    ROUND(
        SUM(actual_headcount) / NULLIF(SUM(planned_headcount),0),
        4
    ) AS capacity_ratio
FROM FACT_WORKFORCE_VARIANCE
GROUP BY
    snapshot_date,
    business_unit,
    plan_type;