






    with grouped_expression as (
    select
        
        
    
  
( 1=1 and fraud_rate >= 0 and fraud_rate <= 100
)
 as expression


    from `fraud_db`.`mart_hourly_fraud_pattern`
    

),
validation_errors as (

    select
        *
    from
        grouped_expression
    where
        not(expression = true)

)

select *
from validation_errors







