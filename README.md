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
  - [Curated Layer](#curated-layer)
  - [Analytics Layer](#analytics-layer)
- [Data Grain](#data-grain)
- [Pipeline Execution](#pipeline-execution)
- [Project Structure](#project-structure)
- [Technical Stack](#technical-stack)
- [Example Analytical Questions](#example-analytical-questions)
- [Key Value](#key-value)
- [Next Steps](#next-steps)

---

## Overview
This project demonstrates an end-to-end workforce planning data model, from raw data ingestion to executive-level analytics.

It simulates how an organization translates business demand into workforce requirements, hiring needs, and attrition planning. The prototype uses mock workforce data to represent a realistic planning environment across multiple business units, functions, and time periods.

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
- Aviation  
- Digital Security  

---

## Datasets

### Employee Actuals
Represents the current workforce baseline at the same planning grain as the headcount plan.

Each row reflects a workforce segment (not individual employees), including:

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
- location  
- job_role  
- snapshot_date  
- planned_headcount  

Used to define **required workforce demand**.

---

### Hiring Plan
Represents projected hiring needs.

**Example fields:**
- business_unit  
- department  
- job_role  
- snapshot_date  
- hiring_needed  

Supports **staffing strategy and recruiting planning**.

---

### Attrition Plan
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

The model follows a simplified workforce planning framework:

- **Required Headcount** → derived from business demand  
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

The solution follows a layered architecture in Snowflake:

### Raw Layer
Data is ingested from CSV files into raw tables:

- HEADCOUNT_PLAN_RAW  
- HIRING_PLAN_RAW  
- ATTRITION_PLAN_RAW  
- EMPLOYEE_ACTUALS_RAW  

This layer stores source data **as-is** and represents the ingestion boundary.

---

### Curated Layer

#### FACT_WORKFORCE_PLAN
Integrates headcount plan, hiring plan, and attrition plan into a unified, scenario-based dataset.

This table aligns all planning inputs at a consistent grain, enabling direct comparison of:

- planned headcount  
- hiring demand  
- expected attrition  

across business units, functions, locations, and time periods.

It serves as the foundational dataset for workforce planning and variance analysis.

#### ACTUAL_HEADCOUNT
Aggregates employee-level data to compute actual workforce supply.

#### FACT_WORKFORCE_VARIANCE
Combines planned workforce data with actual workforce supply to quantify workforce gaps and capacity alignment.

This table joins `FACT_WORKFORCE_PLAN` with actual workforce data to calculate:

- actual_headcount  
- headcount_gap = planned_headcount - actual_headcount  

It enables direct comparison between workforce demand and available capacity across:

- time (snapshot_date)  
- business units  
- departments  
- locations  
- job roles  
- planning scenarios (Budget vs Forecast)  

This dataset is the core analytical layer for identifying:

- workforce shortages and surpluses  
- hiring requirements  
- capacity risks  

and supports decision-making for workforce planning and resource allocation.

---

### Analytics Layer

#### VW_WORKFORCE_SUMMARY
Provides an aggregated, executive-level view of workforce capacity, demand, and variance.

This view summarizes workforce metrics across key dimensions:

- snapshot_date  
- business_unit  
- plan_type  

**Key metrics include:**

- total_actual_headcount  
- total_planned_headcount  
- total_hiring_needed  
- total_attrition_expected  
- total_headcount_gap  
- capacity_ratio (actual_headcount / planned_headcount)  

It enables leadership to quickly assess:

- overall workforce capacity vs demand  
- hiring requirements at a strategic level  
- impact of attrition on workforce readiness  
- differences between Budget and Forecast scenarios  

This view is designed to support high-level decision-making, trend analysis, and executive reporting.

It serves as the primary interface for dashboards and executive workforce reporting.

---

## Data Grain

The data model is standardized at the following level:

- snapshot_date  
- business_unit  
- department  
- location_city  
- location_state  
- job_role  
- plan_type  

This consistent grain ensures accurate aggregation and comparability across datasets.

---

## Pipeline Execution

The project follows a structured execution flow:

1. **Setup Environment**  
   - Create database and schemas  

2. **Ingest Raw Data**  
   - Load CSV files into RAW tables  

3. **Transform Data**  
   - Build curated datasets:
     - FACT_WORKFORCE_PLAN  
     - ACTUAL_HEADCOUNT  
     - FACT_WORKFORCE_VARIANCE  

4. **Analytics Layer**  
   - Create VW_WORKFORCE_SUMMARY  

This layered design improves scalability, maintainability, and clarity.

---

## Project Structure

- **01_setup** → environment setup  
- **02_ingestion** → raw data loading  
- **03_transformation** → curated tables  
- **04_analytics** → reporting views  
- **archive** → legacy scripts (not part of final pipeline)

---

## Technical Stack

- **Python** → mock data generation  
- **Snowflake** → data storage and transformation  
- **SQL** → business logic and modeling  
- **Tableau / Power BI** → (future) visualization layer  

---

## Example Analytical Questions

This model enables analysis of:

- Where are the largest workforce gaps?  
- Which roles require the most hiring?  
- How does attrition impact capacity?  
- Which business units are under or over capacity?  
- How does workforce capacity evolve over time?  

---

## Key Value

This project demonstrates how to:

- translate business demand into workforce requirements  
- integrate multiple workforce datasets into a unified model  
- enable proactive hiring and capacity planning  
- structure data for executive-level decision support  

It highlights the ability to move from **raw data → structured insights → decision-ready analytics**.

---

## Next Steps

Potential enhancements include:

- building a Tableau or Power BI dashboard  
- adding forward-looking workforce projections  
- implementing data quality validation rules  
- automating ingestion (Airflow / Azure Data Factory)  
- enabling scenario-based workforce planning (e.g., productivity, attrition changes)