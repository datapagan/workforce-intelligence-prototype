USE DATABASE WORKFORCE_INTELLIGENCE;
USE SCHEMA GOVERNANCE_WORKFORCE;

CREATE OR REPLACE TABLE LOAD_AUDIT_LOG (
    audit_id NUMBER AUTOINCREMENT,
    file_name STRING,
    source_system STRING,
    load_timestamp TIMESTAMP_NTZ,
    rows_received NUMBER,
    rows_loaded NUMBER,
    load_status STRING,
    error_message STRING
);

CREATE OR REPLACE TABLE DQ_RULE_RESULTS (
    rule_id NUMBER AUTOINCREMENT,
    rule_name STRING,
    table_name STRING,
    check_timestamp TIMESTAMP_NTZ,
    records_checked NUMBER,
    failed_count NUMBER,
    status STRING
);

CREATE OR REPLACE TABLE DQ_FAILED_RECORDS (
    failed_record_id NUMBER AUTOINCREMENT,
    table_name STRING,
    rule_name STRING,
    file_name STRING,
    failure_reason STRING,
    record_snapshot STRING
);