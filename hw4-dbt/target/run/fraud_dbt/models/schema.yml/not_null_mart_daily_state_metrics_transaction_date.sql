
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select transaction_date
from `fraud_db`.`mart_daily_state_metrics`
where transaction_date is null



  
  
    ) dbt_internal_test