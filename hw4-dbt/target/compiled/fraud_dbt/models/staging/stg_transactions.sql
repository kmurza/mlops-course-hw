

SELECT
    transaction_time,
    merch,
    cat_id,
    amount,
    gender,
    us_state,
    population_city,
    jobs,
    
    CASE
        WHEN amount < 50 THEN 'low'
        WHEN amount < 200 THEN 'medium'
        WHEN amount < 1000 THEN 'high'
        ELSE 'very_high'
    END
 AS amount_segment
FROM `fraud_db`.`transactions`
WHERE amount >= 0