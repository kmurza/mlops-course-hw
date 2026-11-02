{{ config(materialized='view') }}

SELECT
    us_state,
    COUNT(*) AS total_transactions,
    SUM(target) AS fraud_count,
    ROUND(SUM(target) / COUNT(*) * 100, 2) AS fraud_rate,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN target = 1 THEN amount ELSE 0 END) AS fraud_amount,
    uniqExact(merch) AS unique_merchants
FROM {{ source('fraud_source', 'transactions') }}
GROUP BY us_state
ORDER BY fraud_rate DESC