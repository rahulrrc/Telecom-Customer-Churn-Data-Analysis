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


-- ============================================================
-- 4. STAR SCHEMA
-- ============================================================

-- Create the customer dimension
CREATE TABLE dim_customer (

    -- Surrogate key generated for each customer
    customer_key INT AUTO_INCREMENT PRIMARY KEY,

    -- Original customer identifier from the source data
    customer_id VARCHAR(20) NOT NULL,

    -- Customer demographic information
    gender VARCHAR(10),
    senior_citizen INT,
    partner VARCHAR(10),
    dependents VARCHAR(10),

    -- Customer tenure information
    tenure_months INT,
    tenure_group VARCHAR(20),

    -- Make sure each customer_id appears only once
    UNIQUE (customer_id)
);


-- Insert customer information from the staging table
INSERT INTO dim_customer (
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure_months,
    tenure_group
)
SELECT
    customer_id,
    gender,
    senior_citizen,
    partner,
    dependents,
    tenure_months,
    tenure_group
FROM staging_churn;

-- Check total rows and unique customers in the customer dimension
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM dim_customer;

-- Check that MySQL generated the surrogate customer keys
SELECT *
FROM dim_customer
LIMIT 5;


-- Create the contract dimension
CREATE TABLE dim_contract (

    contract_key INT AUTO_INCREMENT PRIMARY KEY,
    contract_type VARCHAR(30),
    paperless_billing VARCHAR(10),
    UNIQUE (contract_type, paperless_billing)
);


-- Insert unique contract combinations into the contract dimension
INSERT INTO dim_contract (
    contract_type,
    paperless_billing
)
SELECT DISTINCT
    contract_type,
    paperless_billing
FROM staging_churn;


-- Check the number of unique contract combinations
SELECT COUNT(*) AS total_contract_combinations
FROM dim_contract;


-- Create the service dimension
CREATE TABLE dim_service (

    service_key INT AUTO_INCREMENT PRIMARY KEY,
    phone_service VARCHAR(10),
    multiple_lines VARCHAR(30),
    internet_service VARCHAR(20),
    online_security VARCHAR(30),
    online_backup VARCHAR(30),
    device_protection VARCHAR(30),
    tech_support VARCHAR(30),
    streaming_tv VARCHAR(30),
    streaming_movies VARCHAR(30),

    UNIQUE (
        phone_service,
        multiple_lines,
        internet_service,
        online_security,
        online_backup,
        device_protection,
        tech_support,
        streaming_tv,
        streaming_movies
    )
);


-- Insert unique service combinations into the service dimension
INSERT INTO dim_service (
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies
)
SELECT DISTINCT
    phone_service,
    multiple_lines,
    internet_service,
    online_security,
    online_backup,
    device_protection,
    tech_support,
    streaming_tv,
    streaming_movies
FROM staging_churn;

-- Count the unique service combinations
SELECT COUNT(*) AS total_service_combinations
FROM dim_service;

-- Display the service dimension with its generated keys
SELECT *
FROM dim_service
ORDER BY service_key;


-- Create the payment dimension
CREATE TABLE dim_payment (
    payment_key INT AUTO_INCREMENT PRIMARY KEY,
    payment_method VARCHAR(50),
    UNIQUE (payment_method)
);


-- Insert unique payment methods into the payment dimension
INSERT INTO dim_payment (
    payment_method
)
SELECT DISTINCT
    payment_method
FROM staging_churn;


-- Count the unique payment methods
SELECT COUNT(*) AS total_payment_methods
FROM dim_payment;


-- Display the payment dimension and generated keys
SELECT *
FROM dim_payment
ORDER BY payment_key;


-- Create the customer churn fact table
CREATE TABLE fact_churn (

    -- Links the fact to the customer dimension
    customer_key INT NOT NULL,

    -- Links the fact to the contract dimension
    contract_key INT NOT NULL,

    -- Links the fact to the service dimension
    service_key INT NOT NULL,

    -- Links the fact to the payment dimension
    payment_key INT NOT NULL,

    -- Financial measures
    monthly_charges DECIMAL(10,2),
    total_charges DECIMAL(10,2),

    -- Business outcome we are analyzing
    churn VARCHAR(10),

    -- Ensure one fact row per customer
    PRIMARY KEY (customer_key),

    -- Relationships with dimension tables
    FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    FOREIGN KEY (contract_key)
        REFERENCES dim_contract(contract_key),

    FOREIGN KEY (service_key)
        REFERENCES dim_service(service_key),

    FOREIGN KEY (payment_key)
        REFERENCES dim_payment(payment_key)
);


-- Insert customer-level facts into the fact table
INSERT INTO fact_churn (
    customer_key,
    contract_key,
    service_key,
    payment_key,
    monthly_charges,
    total_charges,
    churn
)
SELECT
    dc.customer_key,
    dct.contract_key,
    ds.service_key,
    dp.payment_key,
    s.monthly_charges,
    s.total_charges,
    s.churn

FROM staging_churn AS s

-- Find the customer's surrogate key
JOIN dim_customer AS dc
    ON s.customer_id = dc.customer_id

-- Find the contract surrogate key
JOIN dim_contract AS dct
    ON s.contract_type = dct.contract_type
    AND s.paperless_billing = dct.paperless_billing

-- Find the service surrogate key
JOIN dim_service AS ds
    ON s.phone_service = ds.phone_service
    AND s.multiple_lines = ds.multiple_lines
    AND s.internet_service = ds.internet_service
    AND s.online_security = ds.online_security
    AND s.online_backup = ds.online_backup
    AND s.device_protection = ds.device_protection
    AND s.tech_support = ds.tech_support
    AND s.streaming_tv = ds.streaming_tv
    AND s.streaming_movies = ds.streaming_movies
-- Find the payment surrogate key
JOIN dim_payment AS dp
    ON s.payment_method = dp.payment_method;
 
 
 
 
 
 
 
 
-- ============================================================
-- 5. DATA MODEL VALIDATION
-- ============================================================

    -- Check the number of rows in the fact table
SELECT COUNT(*) AS total_fact_rows
FROM fact_churn;


-- Check that each customer appears only once in the fact table
SELECT COUNT(DISTINCT customer_key) AS unique_customers
FROM fact_churn;

-- View a few rows from the fact table
SELECT *
FROM fact_churn
LIMIT 5;


-- Check that every fact row has a matching customer
SELECT COUNT(*) AS unmatched_customers
FROM fact_churn AS f
LEFT JOIN dim_customer AS dc
    ON f.customer_key = dc.customer_key
WHERE dc.customer_key IS NULL;

-- Check that every fact row has a matching contract
SELECT COUNT(*) AS unmatched_contracts
FROM fact_churn AS f
LEFT JOIN dim_contract AS dc
    ON f.contract_key = dc.contract_key
WHERE dc.contract_key IS NULL;

-- Check that every fact row has a matching service
SELECT COUNT(*) AS unmatched_services
FROM fact_churn AS f
LEFT JOIN dim_service AS ds
    ON f.service_key = ds.service_key
WHERE ds.service_key IS NULL;


-- Check that every fact row has a matching payment method
SELECT COUNT(*) AS unmatched_payments
FROM fact_churn AS f
LEFT JOIN dim_payment AS dp
    ON f.payment_key = dp.payment_key
WHERE dp.payment_key IS NULL;


-- Compare the customer population across the staging,
-- customer dimension, and fact table
SELECT
    (SELECT COUNT(*) FROM staging_churn) AS staging_rows,
    (SELECT COUNT(*) FROM dim_customer) AS customer_dimension_rows,
    (SELECT COUNT(*) FROM fact_churn) AS fact_rows;






-- ============================================================
-- 6. BUSINESS ANALYSIS
-- ============================================================

-- ============================================================
-- BUSINESS QUESTION 1
-- What is the overall churn rate?
-- ============================================================

SELECT
    COUNT(*) AS total_customers,
    SUM(churn = 'Yes') AS churned_customers,
    ROUND(SUM(churn = 'Yes') * 100.0 / COUNT(*), 2) AS churn_rate
FROM fact_churn;



-- ============================================================
-- BUSINESS QUESTION 2
-- Which contract type has the highest churn?
-- ============================================================

SELECT
    dc.contract_type,
    COUNT(*) AS total_customers,
    SUM(f.churn = 'Yes') AS churned_customers,
    ROUND(
        SUM(f.churn = 'Yes') * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM fact_churn AS f
JOIN dim_contract AS dc
    ON f.contract_key = dc.contract_key
GROUP BY dc.contract_type
ORDER BY churn_rate DESC;



-- ============================================================
-- BUSINESS QUESTION 3
-- Are new customers more likely to churn?
-- ============================================================

SELECT
    dc.tenure_group,
    COUNT(*) AS total_customers,
    SUM(f.churn = 'Yes') AS churned_customers,
    ROUND(
        SUM(f.churn = 'Yes') * 100.0 / COUNT(*),
        2
    ) AS churn_rate
FROM fact_churn AS f
JOIN dim_customer AS dc
    ON f.customer_key = dc.customer_key
GROUP BY dc.tenure_group
ORDER BY churn_rate DESC;


-- ============================================================
-- BUSINESS QUESTION 4
-- Which internet service has the highest churn?
-- ============================================================

SELECT
    ds.internet_service,
    COUNT(*) AS total_customers,
    SUM(f.churn = 'Yes') AS churned_customers,
    SUM(f.churn = 'Yes') / COUNT(*) * 100 AS churn_rate
FROM fact_churn f
JOIN dim_service ds
    ON f.service_key = ds.service_key
GROUP BY ds.internet_service
ORDER BY churn_rate DESC;


-- ============================================================
-- BUSINESS QUESTION 5
-- Which payment method has the highest churn?
-- ============================================================

SELECT
    dp.payment_method,
    COUNT(*) AS total_customers,
    SUM(f.churn = 'Yes') AS churned_customers,
    SUM(f.churn = 'Yes') / COUNT(*) * 100 AS churn_rate
FROM fact_churn f
JOIN dim_payment dp
    ON f.payment_key = dp.payment_key
GROUP BY dp.payment_method
ORDER BY churn_rate DESC;


-- ============================================================
-- BUSINESS QUESTION 6
-- Does Tech Support reduce churn?
-- ============================================================

SELECT
    ds.tech_support,
    COUNT(*) AS total_customers,
    SUM(f.churn = 'Yes') AS churned_customers,
    SUM(f.churn = 'Yes') / COUNT(*) * 100 AS churn_rate
FROM fact_churn f
JOIN dim_service ds
    ON f.service_key = ds.service_key
GROUP BY ds.tech_support
ORDER BY churn_rate DESC;


-- ============================================================
-- BUSINESS QUESTION 7
-- Does Online Security relate to lower churn?
-- ============================================================

SELECT
    ds.online_security,
    COUNT(*) AS total_customers,
    SUM(f.churn = 'Yes') AS churned_customers,
    SUM(f.churn = 'Yes') / COUNT(*) * 100 AS churn_rate
FROM fact_churn f
JOIN dim_service ds
    ON f.service_key = ds.service_key
GROUP BY ds.online_security
ORDER BY churn_rate DESC;


-- ============================================================
-- BUSINESS QUESTION 8
-- Do higher monthly charges relate to higher churn?
-- ============================================================

SELECT
    f.churn,
    COUNT(*) AS total_customers,
    ROUND(AVG(f.monthly_charges), 2) AS avg_monthly_charges
FROM fact_churn f
GROUP BY f.churn
ORDER BY avg_monthly_charges DESC;


-- ============================================================
-- BUSINESS QUESTION 9
-- Which customer segments are most at risk of churn?
-- ============================================================

SELECT
    dc.contract_type,
    dcu.tenure_group,
    ds.internet_service,
    COUNT(*) AS total_customers,
    SUM(f.churn = 'Yes') AS churned_customers,
    ROUND(SUM(f.churn = 'Yes') / COUNT(*) * 100, 2) AS churn_rate
FROM fact_churn f
JOIN dim_customer dcu ON f.customer_key = dcu.customer_key
JOIN dim_contract dc ON f.contract_key = dc.contract_key
JOIN dim_service ds ON f.service_key = ds.service_key
GROUP BY dc.contract_type, dcu.tenure_group, ds.internet_service
HAVING COUNT(*) >= 50
ORDER BY churn_rate DESC;



-- ============================================================
-- BUSINESS QUESTION 10
-- What actionable recommendations can the company take
-- to reduce churn?
-- ============================================================

-- 1. Target new month-to-month fiber-optic customers
--    with proactive retention campaigns during their first year.

-- 2. Encourage month-to-month customers to move to
--    one-year or two-year contracts using suitable incentives.

-- 3. Investigate the customer experience of fiber-optic
--    customers, especially those in their first 12 months.

-- 4. Promote Tech Support and Online Security among
--    high-risk customers, as these services are associated
--    with lower churn.

-- 5. Review the payment experience for electronic-check
--    customers, who show a higher churn rate.

-- 6. Prioritize high-value customers who show high churn risk
--    to reduce potential revenue loss.






