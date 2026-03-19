USE DATABASE WORKFORCE_INTELLIGENCE;

-- Rule 1: Null month check
INSERT INTO GOVERNANCE_WORKFORCE.DQ_RULE_RESULTS
(rule_name, table_name, check_timestamp, records_checked, failed_count, status)
SELECT
    'NULL_MONTH_CHECK',
    'EMPLOYEE_ACTUALS_STG',
    CURRENT_TIMESTAMP(),
    COUNT(*),
    COUNT_IF(month IS NULL),
    CASE WHEN COUNT_IF(month IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG;

-- Rule 2: Null business unit check
INSERT INTO GOVERNANCE_WORKFORCE.DQ_RULE_RESULTS
(rule_name, table_name, check_timestamp, records_checked, failed_count, status)
SELECT
    'NULL_BUSINESS_UNIT_CHECK',
    'EMPLOYEE_ACTUALS_STG',
    CURRENT_TIMESTAMP(),
    COUNT(*),
    COUNT_IF(business_unit IS NULL),
    CASE WHEN COUNT_IF(business_unit IS NULL) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG;

-- Rule 3: Negative headcount check
INSERT INTO GOVERNANCE_WORKFORCE.DQ_RULE_RESULTS
(rule_name, table_name, check_timestamp, records_checked, failed_count, status)
SELECT
    'NEGATIVE_HEADCOUNT_CHECK',
    'EMPLOYEE_ACTUALS_STG',
    CURRENT_TIMESTAMP(),
    COUNT(*),
    COUNT_IF(actual_headcount < 0),
    CASE WHEN COUNT_IF(actual_headcount < 0) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG;

-- Rule 4: Attrition greater than headcount
INSERT INTO GOVERNANCE_WORKFORCE.DQ_RULE_RESULTS
(rule_name, table_name, check_timestamp, records_checked, failed_count, status)
SELECT
    'ATTRITION_GT_HEADCOUNT_CHECK',
    'EMPLOYEE_ACTUALS_STG',
    CURRENT_TIMESTAMP(),
    COUNT(*),
    COUNT_IF(actual_attrition > actual_headcount),
    CASE WHEN COUNT_IF(actual_attrition > actual_headcount) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG;

-- Rule 5: Invalid scenario values
INSERT INTO GOVERNANCE_WORKFORCE.DQ_RULE_RESULTS
(rule_name, table_name, check_timestamp, records_checked, failed_count, status)
SELECT
    'INVALID_SCENARIO_CHECK',
    'HEADCOUNT_PLAN_STG',
    CURRENT_TIMESTAMP(),
    COUNT(*),
    COUNT_IF(scenario_name NOT IN ('Budget', 'Forecast')),
    CASE WHEN COUNT_IF(scenario_name NOT IN ('Budget', 'Forecast')) = 0 THEN 'PASS' ELSE 'FAIL' END
FROM STAGE_WORKFORCE.HEADCOUNT_PLAN_STG;

-- Rule 6: Duplicate business key in actuals
INSERT INTO GOVERNANCE_WORKFORCE.DQ_RULE_RESULTS
(rule_name, table_name, check_timestamp, records_checked, failed_count, status)
SELECT
    'DUPLICATE_ACTUALS_BUSINESS_KEY_CHECK',
    'EMPLOYEE_ACTUALS_STG',
    CURRENT_TIMESTAMP(),
    COUNT(*),
    COUNT(*) - COUNT(DISTINCT CONCAT(month, '|', business_unit, '|', department, '|', location, '|', state, '|', job_family)),
    CASE
        WHEN COUNT(*) - COUNT(DISTINCT CONCAT(month, '|', business_unit, '|', department, '|', location, '|', state, '|', job_family)) = 0
        THEN 'PASS'
        ELSE 'FAIL'
    END
FROM STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG;

-- Optional failed-record capture example
INSERT INTO GOVERNANCE_WORKFORCE.DQ_FAILED_RECORDS
(table_name, rule_name, file_name, failure_reason, record_snapshot)
SELECT
    'EMPLOYEE_ACTUALS_STG',
    'ATTRITION_GT_HEADCOUNT_CHECK',
    'employee_actuals.csv',
    'actual_attrition is greater than actual_headcount',
    CONCAT(
        'month=', month,
        ', business_unit=', business_unit,
        ', department=', department,
        ', location=', location,
        ', state=', state,
        ', job_family=', job_family,
        ', actual_headcount=', actual_headcount,
        ', actual_attrition=', actual_attrition
    )
FROM STAGE_WORKFORCE.EMPLOYEE_ACTUALS_STG
WHERE actual_attrition > actual_headcount;