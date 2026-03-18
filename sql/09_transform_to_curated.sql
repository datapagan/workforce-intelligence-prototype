USE DATABASE WORKFORCE_INTELLIGENCE;

INSERT INTO STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG
SELECT * FROM RAW_WORKFORCE.EMPLOYEE_ACTUALS_RAW;

INSERT INTO STAGE_WORKFORCE.HEADCOUNT_PLAN_STG
SELECT * FROM RAW_WORKFORCE.HEADCOUNT_PLAN_RAW;

INSERT INTO STAGE_WORKFORCE.HIRING_PLAN_STG
SELECT * FROM RAW_WORKFORCE.HIRING_PLAN_RAW;

INSERT INTO STAGE_WORKFORCE.ATTRITION_PLAN_STG
SELECT * FROM RAW_WORKFORCE.ATTRITION_PLAN_RAW;

INSERT INTO STAGE_WORKFORCE.ORG_DIMENSION_STG
SELECT * FROM RAW_WORKFORCE.ORG_DIMENSION_RAW;

INSERT INTO STAGE_WORKFORCE.LOCATION_DIMENSION_STG
SELECT * FROM RAW_WORKFORCE.LOCATION_DIMENSION_RAW;

INSERT INTO CURATED_WORKFORCE.FACT_WORKFORCE_MONTHLY (
    month,
    business_unit,
    department,
    location,
    state,
    region,
    cost_center,
    manager_name,
    job_family,
    scenario_name,
    actual_headcount,
    planned_headcount,
    actual_hires,
    planned_hires,
    actual_attrition,
    planned_attrition,
    net_headcount_change,
    headcount_variance_to_plan,
    hiring_variance_to_plan,
    attrition_variance_to_plan
)
SELECT
    hp.month,
    hp.business_unit,
    hp.department,
    hp.location,
    hp.state,
    ld.region,
    od.cost_center,
    od.manager_name,
    hp.job_family,
    hp.scenario_name,
    ea.actual_headcount,
    hp.planned_headcount,
    ea.actual_hires,
    hpl.planned_hires,
    ea.actual_attrition,
    ap.planned_attrition,
    ea.actual_hires - ea.actual_attrition AS net_headcount_change,
    ea.actual_headcount - hp.planned_headcount AS headcount_variance_to_plan,
    ea.actual_hires - hpl.planned_hires AS hiring_variance_to_plan,
    ea.actual_attrition - ap.planned_attrition AS attrition_variance_to_plan
FROM STAGE_WORKFORCE.HEADCOUNT_PLAN_STG hp
LEFT JOIN STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG ea
    ON hp.month = ea.month
    AND hp.business_unit = ea.business_unit
    AND hp.department = ea.department
    AND hp.location = ea.location
    AND hp.state = ea.state
    AND hp.job_family = ea.job_family
LEFT JOIN STAGE_WORKFORCE.HIRING_PLAN_STG hpl
    ON hp.month = hpl.month
    AND hp.business_unit = hpl.business_unit
    AND hp.department = hpl.department
    AND hp.location = hpl.location
    AND hp.state = hpl.state
    AND hp.job_family = hpl.job_family
    AND hp.scenario_name = hpl.scenario_name
LEFT JOIN STAGE_WORKFORCE.ATTRITION_PLAN_STG ap
    ON hp.month = ap.month
    AND hp.business_unit = ap.business_unit
    AND hp.department = ap.department
    AND hp.location = ap.location
    AND hp.state = ap.state
    AND hp.job_family = ap.job_family
    AND hp.scenario_name = ap.scenario_name
LEFT JOIN STAGE_WORKFORCE.ORG_DIMENSION_STG od
    ON hp.business_unit = od.business_unit
    AND hp.department = od.department
LEFT JOIN STAGE_WORKFORCE.LOCATION_DIMENSION_STG ld
    ON hp.location = ld.location
    AND hp.state = ld.state;