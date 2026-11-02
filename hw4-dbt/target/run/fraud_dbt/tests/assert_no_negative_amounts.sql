
    
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  SELECT * FROM `fraud_db`.`stg_transactions` WHERE amount < 0
  
  
    ) dbt_internal_test