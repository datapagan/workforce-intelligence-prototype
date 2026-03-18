USE DATABASE WORKFORCE_INTELLIGENCE;
USE SCHEMA GOVERNANCE_WORKFORCE;

INSERT INTO LOAD_AUDIT_LOG
(file_name, source_system, load_timestamp, rows_received, rows_loaded, load_status, error_message)
VALUES
('employee_actuals.csv', 'Mock HR Export', CURRENT_TIMESTAMP(), 324, 324, 'LOADED', NULL),
('headcount_plan.csv', 'Mock EPM Export', CURRENT_TIMESTAMP(), 648, 648, 'LOADED', NULL),
('hiring_plan.csv', 'Mock EPM Export', CURRENT_TIMESTAMP(), 648, 648, 'LOADED', NULL),
('attrition_plan.csv', 'Mock EPM Export', CURRENT_TIMESTAMP(), 648, 648, 'LOADED', NULL),
('org_dimension.csv', 'Reference Data', CURRENT_TIMESTAMP(), 6, 6, 'LOADED', NULL),
('location_dimension.csv', 'Reference Data', CURRENT_TIMESTAMP(), 3, 3, 'LOADED', NULL);