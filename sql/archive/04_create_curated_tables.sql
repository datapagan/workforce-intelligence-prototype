USE DATABASE WORKFORCE_INTELLIGENCE;
USE SCHEMA CURATED_WORKFORCE;

CREATE OR REPLACE TABLE FACT_WORKFORCE_MONTHLY (
    month DATE,
    business_unit STRING,
    department STRING,
    location STRING,
    state STRING,
    region STRING,
    cost_center STRING,
    manager_name STRING,
    job_family STRING,
    scenario_name STRING,
    actual_headcount NUMBER,
    planned_headcount NUMBER,
    actual_hires NUMBER,
    planned_hires NUMBER,
    actual_attrition NUMBER,
    planned_attrition NUMBER,
    net_headcount_change NUMBER,
    headcount_variance_to_plan NUMBER,
    hiring_variance_to_plan NUMBER,
    attrition_variance_to_plan NUMBER
);