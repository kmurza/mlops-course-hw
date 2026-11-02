{{ config(materialized='view') }}

SELECT
    transaction_time,
    merch,
    cat_id,
    amount,
    gender,
    us_state,
    population_city,
    jobs,
    {{ amount_bucket('amount') }} AS amount_segment
FROM {{ source('fraud_source', 'transactions') }}
WHERE amount >= 0