# Data Ingestion – Snowflake Stage and COPY INTO

## Overview
This project simulates a realistic file-based ingestion process using an SFTP-style landing zone and Snowflake internal stage.

Workforce data files are generated locally and uploaded into Snowflake using SnowSQL commands. These files are then loaded into raw tables using COPY INTO.

---

## Step 1 – Upload Files to Snowflake Stage

Example commands:

```sql
PUT file://C:/Project/workforce-intelligence-protype/data/inbound_sftp/employee_actuals.csv 
@WORKFORCE_INTELLIGENCE.RAW_WORKFORCE.WORKFORCE_INBOUND_STAGE 
AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

PUT file://C:/Project/workforce-intelligence-protype/data/inbound_sftp/headcount_plan.csv 
@WORKFORCE_INTELLIGENCE.RAW_WORKFORCE.WORKFORCE_INBOUND_STAGE 
AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

PUT file://C:/Project/workforce-intelligence-protype/data/inbound_sftp/hiring_plan.csv 
@WORKFORCE_INTELLIGENCE.RAW_WORKFORCE.WORKFORCE_INBOUND_STAGE 
AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

PUT file://C:/Project/workforce-intelligence-protype/data/inbound_sftp/attrition_plan.csv 
@WORKFORCE_INTELLIGENCE.RAW_WORKFORCE.WORKFORCE_INBOUND_STAGE 
AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

PUT file://C:/Project/workforce-intelligence-protype/data/reference/org_dimension.csv 
@WORKFORCE_INTELLIGENCE.RAW_WORKFORCE.WORKFORCE_INBOUND_STAGE 
AUTO_COMPRESS=FALSE OVERWRITE=TRUE;

PUT file://C:/Project/workforce-intelligence-protype/data/reference/location_dimension.csv 
@WORKFORCE_INTELLIGENCE.RAW_WORKFORCE.WORKFORCE_INBOUND_STAGE 
AUTO_COMPRESS=FALSE OVERWRITE=TRUE;