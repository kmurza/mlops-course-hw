-- категория с наибольшей суммой транзакций по каждому штату
SELECT
    us_state,
    cat_id,
    sum(amount) AS total_amount
FROM fraud_db.transactions
GROUP BY us_state, cat_id
ORDER BY us_state, total_amount DESC
LIMIT 1 BY us_state;