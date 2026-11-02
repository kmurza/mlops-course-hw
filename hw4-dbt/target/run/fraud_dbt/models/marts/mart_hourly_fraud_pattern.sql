

  create or replace view `fraud_db`.`mart_hourly_fraud_pattern` 
  
    
  
  
    
    
  as (
    

SELECT
    toDayOfWeek(parseDateTimeBestEffort(transaction_time)) AS day_of_week,
    toHour(parseDateTimeBestEffort(transaction_time)) AS hour_of_day,
    COUNT(*) AS total_transactions,
    SUM(target) AS fraud_count,
    ROUND(SUM(target) / COUNT(*) * 100, 2) AS fraud_rate,
    SUM(amount) AS total_amount
FROM `fraud_db`.`transactions`
GROUP BY day_of_week, hour_of_day
ORDER BY fraud_rate DESC
    
  )
      
      
                    -- end_of_sql
                    
                    