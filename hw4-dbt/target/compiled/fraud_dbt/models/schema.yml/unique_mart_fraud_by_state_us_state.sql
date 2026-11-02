
    
    

select
    us_state as unique_field,
    count(*) as n_records

from `fraud_db`.`mart_fraud_by_state`
where us_state is not null
group by us_state
having count(*) > 1


