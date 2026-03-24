-- =========================================================
-- 01_create_environment.sql
-- Creates the workforce planning database, schemas, file format,
-- and internal stage for raw CSV ingestion.
-- =========================================================

-- Create database
CREATE OR REPLACE DATABASE WORKFORCE_PLANNING;

-- Create schemas
CREATE OR REPLACE SCHEMA WORKFORCE_PLANNING.RAW;
CREATE OR REPLACE SCHEMA WORKFORCE_PLANNING.CURATED;
CREATE OR REPLACE SCHEMA WORKFORCE_PLANNING.PUBLISHED;

-- Use RAW schema for ingestion setup
USE DATABASE WORKFORCE_PLANNING;
USE SCHEMA RAW;

-- File format for CSV ingestion
CREATE OR REPLACE FILE FORMAT FF_WORKFORCE_CSV
TYPE = CSV
SKIP_HEADER = 1
FIELD_OPTIONALLY_ENCLOSED_BY = '"'
TRIM_SPACE = TRUE
EMPTY_FIELD_AS_NULL = TRUE;

-- Internal stage for inbound workforce files
CREATE OR REPLACE STAGE STG_WORKFORCE_FILES
FILE_FORMAT = FF_WORKFORCE_CSV;