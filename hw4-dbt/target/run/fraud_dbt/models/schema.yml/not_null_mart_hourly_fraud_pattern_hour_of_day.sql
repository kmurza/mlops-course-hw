
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select hour_of_day
from `fraud_db`.`mart_hourly_fraud_pattern`
where hour_of_day is null



  
  
    ) dbt_internal_test