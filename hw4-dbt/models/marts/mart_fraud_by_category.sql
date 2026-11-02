{{ config(materialized='view') }}

SELECT
    cat_id,
    COUNT(*) AS total_transactions,
    SUM(target) AS fraud_count,
    ROUND(SUM(target) / COUNT(*) * 100, 2) AS fraud_rate,
    SUM(amount) AS total_amount,
    SUM(CASE WHEN target = 1 THEN amount ELSE 0 END) AS fraud_amount
FROM {{ source('fraud_source', 'transactions') }}
GROUP BY cat_id
ORDER BY fraud_rate DESC