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






