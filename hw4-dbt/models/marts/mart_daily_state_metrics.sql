{{ config(materialized='view') }}

SELECT
    toDate(parseDateTimeBestEffort(transaction_time)) AS transaction_date,
    us_state,
    COUNT(*) AS transaction_count,
    SUM(amount) AS total_amount,
    AVG(amount) AS avg_amount,
    quantile(0.95)(amount) AS p95_amount,
    SUM(CASE WHEN amount > 500 THEN 1 ELSE 0 END) / COUNT(*) AS large_transaction_share
FROM {{ source('fraud_source', 'transactions') }}
GROUP BY transaction_date, us_state
ORDER BY transaction_date, us_state