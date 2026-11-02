
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select us_state
from `fraud_db`.`mart_daily_state_metrics`
where us_state is null



  
  
    ) dbt_internal_test