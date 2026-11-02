
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select cat_id
from `fraud_db`.`mart_fraud_by_category`
where cat_id is null



  
  
    ) dbt_internal_test