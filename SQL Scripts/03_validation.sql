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










