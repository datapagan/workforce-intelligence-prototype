# Workforce Planning & Forecasting Prototype

## Overview
This project demonstrates an end-to-end workforce planning data model, from raw data ingestion to executive-level analytics.

It simulates how an organization can translate business demand into workforce requirements, hiring needs, and attrition planning. The prototype uses mock workforce data to represent a realistic planning environment across multiple business units, functions, and time periods.

---

## Business Objective
Organizations need to understand whether future workforce capacity will be sufficient to meet expected demand. This project models that planning process by connecting:

- current workforce actuals  
- future headcount requirements  
- hiring needs  
- attrition expectations  

The goal is to enable **proactive workforce planning** instead of reactive staffing decisions.

---

## Project Scope
This prototype includes mock datasets for:

- employee actuals  
- headcount plan  
- hiring plan  
- attrition plan  

The data simulates workforce planning across business units such as:

- Space Systems  
- Aviation  
- Digital Security  

---

## Datasets

### 1. Employee Actuals
Represents the current workforce baseline.

**Example fields:**
- employee_id  
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- snapshot_date  

Used to calculate **actual workforce supply**.

---

### 2. Headcount Plan
Represents forecasted workforce demand.

**Example fields:**
- business_unit  
- department  
- location  
- job_role  
- snapshot_date  
- planned_headcount  

Used to define **required workforce demand**.

---

### 3. Hiring Plan
Represents projected hiring needs.

**Example fields:**
- business_unit  
- department  
- job_role  
- snapshot_date  
- hiring_needed  

Used to support **staffing strategy and recruiting plans**.

---

### 4. Attrition Plan
Represents projected workforce losses.

**Example fields:**
- business_unit  
- department  
- job_role  
- snapshot_date  
- attrition_expected  

Used to model **workforce risk and turnover impact**.

---

## Planning Logic

The prototype is based on a simplified workforce planning framework:

- **Required Headcount** = business demand translated into workforce need  
- **Available Workforce** = current workforce capacity  
- **Projected Attrition** = expected workforce losses  
- **Hiring Need** = Required Headcount - Available Workforce + Attrition  

This approach allows organizations to estimate staffing needs before capacity constraints impact operations.

---

## Key Metrics Defined

- **Planned Headcount**: Target workforce required to meet business demand  
- **Actual Headcount**: Current workforce based on employee records  
- **Hiring Needed**: Number of hires required to meet planned headcount  
- **Attrition Expected**: Projected workforce loss over time  
- **Headcount Gap**: Difference between planned and actual workforce  
- **Capacity Ratio**: Actual headcount divided by planned headcount  

These metrics provide a standardized framework for workforce planning analysis.

---

## Example Use Case

A business unit expects increased demand requiring 120 employees.

- Current workforce: 110  
- Expected attrition: 6  

**Hiring Need = 120 - 110 + 6 = 16**

This provides a practical method to estimate future staffing requirements.

---

## Data Architecture

The solution follows a layered data architecture in Snowflake:

### 1. Raw Layer
Data is ingested from CSV files into raw tables:

- HEADCOUNT_PLAN_RAW  
- HIRING_PLAN_RAW  
- ATTRITION_PLAN_RAW  
- EMPLOYEE_ACTUALS_RAW  

These tables store source data as-is and represent the ingestion layer.

---

### 2. Curated Layer

#### FACT_WORKFORCE_PLAN
Combines headcount plan, hiring plan, and attrition plan into a unified dataset.

#### ACTUAL_HEADCOUNT
Aggregates employee-level data to calculate actual headcount at the required grain.

#### FACT_WORKFORCE_VARIANCE
Joins planned workforce with actual workforce and calculates:

- headcount_gap = planned_headcount - actual_headcount  

This is the core analytical dataset for workforce planning.

---

### 3. Analytics Layer

#### VW_WORKFORCE_SUMMARY
Provides an aggregated executive-level view by:

- snapshot_date  
- business_unit  
- plan_type  

**Key metrics include:**

- total actual headcount  
- total planned headcount  
- total hiring needed  
- total attrition expected  
- total headcount gap  
- capacity_ratio  

This view supports leadership-level workforce insights.

---

## Data Grain

The core workforce data is modeled at the following level of detail:

- snapshot_date  
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- plan_type  

This consistent grain ensures accurate aggregation, comparison, and analysis across all workforce metrics.

---

## Pipeline Execution

The project is executed in the following order:

1. Setup environment  
   - Create database and schemas  

2. Ingest raw data  
   - Load CSV files into RAW tables  

3. Transform data  
   - Build curated tables:
     - FACT_WORKFORCE_PLAN  
     - ACTUAL_HEADCOUNT  
     - FACT_WORKFORCE_VARIANCE  

4. Analytics layer  
   - Create VW_WORKFORCE_SUMMARY  

This layered approach separates ingestion, transformation, and analytics, making the solution scalable and maintainable.

---

## Project Structure

- sql/01_setup → environment setup  
- sql/02_ingestion → raw data loading  
- sql/03_transformation → curated tables  
- sql/04_analytics → reporting views  

The `archive` folder contains earlier development scripts and intermediate builds. These are retained for reference but are not part of the final execution pipeline.

---

## Technical Stack

- Python → mock data generation  
- Snowflake → data storage and transformation  
- SQL → workforce planning logic  
- Tableau / Power BI → (future) dashboard layer  

---

## Example Analytical Questions

This model enables analysis of key workforce planning questions such as:

- Where are the largest workforce gaps across business units?  
- Which roles have the highest hiring demand?  
- How does attrition impact future workforce capacity?  
- Which business units are under or over capacity?  
- How does capacity change over time?  

These insights support proactive decision-making and resource planning.

---

## Key Value

This project demonstrates how workforce data can be structured to support:

- headcount forecasting  
- hiring demand visibility  
- attrition impact analysis  
- workforce gap identification  
- executive decision support  

It highlights the ability to move from raw data to structured planning insights.

---

## Interview Relevance

This project supports positioning for roles in:

- workforce planning  
- workforce analytics  
- capacity planning  
- headcount forecasting  
- enterprise data and analytics  

It demonstrates the ability to:

- design data models aligned with business planning  
- integrate multiple workforce datasets  
- translate business questions into analytical structures  
- build scalable data solutions for decision-making  

---

## Next Steps

Future enhancements could include:

- building a Tableau or Power BI dashboard on top of VW_WORKFORCE_SUMMARY  
- adding forward-looking projected workforce calculations  
- implementing data quality validation checks  
- automating ingestion using orchestration tools (e.g., Airflow or Azure Data Factory)  
- enabling scenario planning for productivity and attrition changes  