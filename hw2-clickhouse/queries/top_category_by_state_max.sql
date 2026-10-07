-- категория самой крупной единичной транзакции по каждому штату
SELECT
    us_state,
    cat_id,
    amount
FROM fraud_db.transactions
ORDER BY us_state, amount DESC
LIMIT 1 BY us_state;