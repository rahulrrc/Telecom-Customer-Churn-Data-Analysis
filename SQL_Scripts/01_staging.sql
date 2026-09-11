-- ============================================================
-- 1. DATABASE SETUP
-- ============================================================

-- Create a separate database for the Customer Churn Analysis project
CREATE DATABASE customer_churn;

-- Select the database so all following tables and queries are created inside it
USE customer_churn;


-- ============================================================
-- 2. STAGING TABLE
-- ============================================================

-- Create a staging table to load and validate the cleaned CSV data
CREATE TABLE staging_churn (

    -- Unique identifier for each customer
    customer_id VARCHAR(20),

    -- Customer demographic information
    gender VARCHAR(10),
    senior_citizen INT,
    partner VARCHAR(10),
    dependents VARCHAR(10),

    -- Customer tenure
    tenure_months INT,

    -- Services used by the customer
    phone_service VARCHAR(10),
    multiple_lines VARCHAR(30),
    internet_service VARCHAR(20),
    online_security VARCHAR(30),
    online_backup VARCHAR(30),
    device_protection VARCHAR(30),
    tech_support VARCHAR(30),
    streaming_tv VARCHAR(30),
    streaming_movies VARCHAR(30),

    -- Contract and billing information
    contract_type VARCHAR(30),
    paperless_billing VARCHAR(10),
    payment_method VARCHAR(50),

    -- Financial information
    monthly_charges DECIMAL(10,2),
    total_charges DECIMAL(10,2),

    -- Churn information
    churn VARCHAR(10),

    -- Customer tenure category created during Python analysis
    tenure_group VARCHAR(20)
);


-- ============================================================
-- 3. DATA GRAIN
-- ============================================================

-- Check the total number of rows imported
SELECT COUNT(*) AS total_rows
FROM staging_churn;

-- View a few rows to make sure the data looks correct
SELECT *
FROM staging_churn
LIMIT 5;

-- Check total rows and unique customers
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM staging_churn;






