
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select day_of_week
from `fraud_db`.`mart_hourly_fraud_pattern`
where day_of_week is null



  
  
    ) dbt_internal_test