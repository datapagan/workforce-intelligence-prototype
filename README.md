# Workforce Planning & Forecasting Prototype

## Table of Contents

- [Overview](#overview)
- [Business Objective](#business-objective)
- [Project Scope](#project-scope)
- [Datasets](#datasets)
  - [Employee Actuals](#employee-actuals)
  - [Headcount Plan](#headcount-plan)
  - [Hiring Plan](#hiring-plan)
  - [Attrition Plan](#attrition-plan)
- [Planning Logic](#planning-logic)
- [Key Metrics](#key-metrics)
- [Example Use Case](#example-use-case)
- [Data Architecture](#data-architecture)
  - [Raw Layer](#raw-layer)
  - [Transform Layer](#transform-layer)
  - [Curated Layer](#curated-layer)
- [Data Grain](#data-grain)
- [Pipeline Execution](#pipeline-execution)
- [Database Structure](#database-structure)
- [Project Structure](#project-structure)
- [Technical Stack](#technical-stack)
- [Example Analytical Questions](#example-analytical-questions)
- [Key Value](#key-value)
- [Next Steps](#next-steps)

---

## Overview
This project demonstrates an end-to-end workforce planning data model, from raw data ingestion to business-ready analytics in Snowflake.

It simulates how an organization translates business demand into workforce requirements, hiring needs, attrition expectations, and workforce gap analysis. The prototype uses mock workforce data to represent a realistic planning environment across multiple business units, functions, locations, and time periods.

---

## Business Objective
Organizations need to understand whether future workforce capacity will be sufficient to meet expected demand.

This project models that planning process by connecting:

- current workforce actuals  
- future headcount requirements  
- hiring needs  
- attrition expectations  

The goal is to enable **proactive workforce planning**, allowing decisions to be made before capacity constraints impact operations.

---

## Project Scope
This prototype includes mock datasets for:

- employee actuals  
- headcount plan  
- hiring plan  
- attrition plan  

The data simulates workforce planning across business units such as:

- Space Systems  
- Aviation Systems  
- Digital Security  

---

## Datasets

### Employee Actuals
Represents the current workforce baseline at the same planning grain as the headcount plan.

Each row reflects a workforce segment, including:

- snapshot_date  
- business_unit  
- department  
- location_city  
- location_state  
- job_role  

**Measures included:**
- actual_headcount  
- actual_hires  
- actual_attrition  

This dataset is used to calculate **actual workforce supply** and support variance analysis against planned headcount.

> **Note:**  
> The raw table retains legacy column names from an earlier employee-level design.  
> In the current implementation:
> - `EMPLOYEE_ID` represents `actual_headcount`
> - `TENURE_YEARS` represents `actual_hires`
> - `AGE` represents `actual_attrition`
>
> These fields are treated as aggregated workforce measures rather than individual employee attributes.

---

### Headcount Plan
Represents forecasted workforce demand.

**Example fields:**
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- snapshot_date  
- plan_type  
- planned_headcount  

Used to define **required workforce demand**.

---

### Hiring Plan
Represents projected hiring needs.

**Example fields:**
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- snapshot_date  
- plan_type  
- hiring_needed  

Supports **staffing strategy and recruiting planning**.

---

### Attrition Plan
Represents projected workforce losses.

**Example fields:**
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- snapshot_date  
- plan_type  
- attrition_expected  

Used to model **workforce risk and turnover impact**.

---

## Planning Logic

The model follows a simplified workforce planning framework:

- **Required Headcount** → workforce demand by role and business unit  
- **Available Workforce** → current workforce capacity  
- **Projected Attrition** → expected workforce losses  
- **Hiring Need** → Required Headcount - Available Workforce + Attrition  

This approach enables forward-looking workforce planning instead of reactive staffing adjustments.

---

## Key Metrics

- **Planned Headcount** → Target workforce required  
- **Actual Headcount** → Current workforce supply  
- **Hiring Needed** → Required hires to meet demand  
- **Attrition Expected** → Forecasted workforce loss  
- **Headcount Gap** → Planned - Actual  
- **Capacity Ratio** → Actual / Planned  

These metrics provide a consistent and scalable framework for workforce analysis.

---

## Example Use Case

A business unit expects increased demand requiring **120 employees**:

- Current workforce: 110  
- Expected attrition: 6  

**Hiring Need = 120 - 110 + 6 = 16**

This illustrates how the model supports workforce forecasting and hiring strategy.

---

## Data Architecture

The solution follows a layered Snowflake architecture:

### Raw Layer
Data is ingested from CSV files into raw source tables:

- `HEADCOUNT_PLAN_RAW`
- `HIRING_PLAN_RAW`
- `ATTRITION_PLAN_RAW`
- `EMPLOYEE_ACTUALS_RAW`

This layer stores source data **as-is** and represents the ingestion boundary.

---

### Transform Layer

This layer standardizes and integrates raw workforce datasets into reusable intermediate tables.

#### `ACTUAL_HEADCOUNT`
Aggregates current workforce data to compute actual workforce supply at the planning grain.

#### `FACT_WORKFORCE_PLAN`
Integrates headcount plan, hiring plan, and attrition plan into a unified planning dataset.

This table aligns all planning inputs at a consistent grain, enabling direct comparison of:

- planned headcount  
- hiring demand  
- expected attrition  

across business units, departments, locations, job roles, time periods, and planning scenarios.

The Transform layer is where integration and business logic begin before final analytical outputs are produced.

---

### Curated Layer

This layer contains final business-ready analytical outputs.

#### `FACT_WORKFORCE_VARIANCE`
Combines workforce planning data with actual workforce supply to quantify workforce gaps and capacity alignment.

This table joins `FACT_WORKFORCE_PLAN` with `ACTUAL_HEADCOUNT` to calculate:

- actual_headcount  
- headcount_gap = planned_headcount - actual_headcount  

It enables direct comparison between workforce demand and available capacity across:

- snapshot_date  
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- plan_type  

This is the core analytical dataset for identifying:

- workforce shortages and surpluses  
- hiring requirements  
- capacity risks  

#### `VW_WORKFORCE_SUMMARY`
Provides an aggregated, executive-level summary of workforce capacity, demand, and variance.

This view summarizes metrics by:

- snapshot_date  
- business_unit  
- plan_type  

**Key metrics include:**

- total_actual_headcount  
- total_planned_headcount  
- total_hiring_needed  
- total_attrition_expected  
- total_headcount_gap  
- capacity_ratio  

It is designed to support executive reporting, high-level decision-making, and trend analysis.

---

## Data Grain

The workforce planning model is standardized at the following level:

- snapshot_date  
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- plan_type  

This consistent grain ensures accurate joins, aggregation, and comparability across datasets.

---

## Pipeline Execution

The project follows this execution flow:

1. **Setup Environment**  
   - Create database and schemas (`RAW`, `TRANSFORM`, `CURATED`)

2. **Ingest Raw Data**  
   - Load CSV files into raw source tables

3. **Transform Data**  
   - Build intermediate transformation tables:
     - `ACTUAL_HEADCOUNT`
     - `FACT_WORKFORCE_PLAN`

4. **Curate Analytical Outputs**  
   - Build final analytical table:
     - `FACT_WORKFORCE_VARIANCE`

5. **Create Reporting View**  
   - Create executive summary view:
     - `VW_WORKFORCE_SUMMARY`

This layered design improves scalability, maintainability, and clarity by separating ingestion, transformation logic, and final analytical outputs.

---

## Database Structure

### Database: `WORKFORCE_PLANNING`

#### Schema: `RAW`
Source-loaded tables:
- `EMPLOYEE_ACTUALS_RAW`
- `HEADCOUNT_PLAN_RAW`
- `HIRING_PLAN_RAW`
- `ATTRITION_PLAN_RAW`

#### Schema: `TRANSFORM`
Intermediate transformation tables:
- `ACTUAL_HEADCOUNT`
- `FACT_WORKFORCE_PLAN`

#### Schema: `CURATED`
Business-ready analytical objects:
- `FACT_WORKFORCE_VARIANCE`
- `VW_WORKFORCE_SUMMARY`

---

## Project Structure

- **01_setup** → environment setup  
- **02_ingestion** → raw data loading  
- **03_transformation** → intermediate transformation logic  
- **04_analytics** → curated outputs and reporting views  
- **archive** → legacy scripts not used in the final implementation  

---

## Technical Stack

- **Python** → mock data generation  
- **Snowflake** → data storage and layered modeling  
- **SQL** → joins, transformations, and analytical logic  
- **Tableau / Power BI** → future dashboard layer  

---

## Example Analytical Questions

This model enables analysis such as:

- Where are the largest workforce gaps?  
- Which roles require the most hiring?  
- How does attrition impact capacity?  
- Which business units are under or over capacity?  
- How do Budget and Forecast scenarios compare?  
- How does workforce capacity evolve over time?  

---

## Key Value

This project demonstrates how to:

- translate business demand into workforce requirements  
- integrate multiple workforce datasets into a unified planning model  
- separate raw ingestion, transformation logic, and analytical outputs  
- produce decision-ready workforce insights for leadership  

It highlights the ability to move from **raw data → transformed model → curated analytics**.

---

## Next Steps

Potential enhancements include:

- building a Tableau or Power BI dashboard  
- adding workforce scenario modeling  
- implementing data quality validation checks  
- automating ingestion with Snowpipe, Airflow, or Azure Data Factory  
- expanding planning dimensions such as labor cost, skill type, or productivity assumptions  