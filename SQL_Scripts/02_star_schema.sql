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
 
 
 
 
 
 





