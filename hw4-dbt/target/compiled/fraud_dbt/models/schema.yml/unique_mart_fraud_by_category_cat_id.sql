
    
    

select
    cat_id as unique_field,
    count(*) as n_records

from `fraud_db`.`mart_fraud_by_category`
where cat_id is not null
group by cat_id
having count(*) > 1


