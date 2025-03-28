select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    date_key as unique_field,
    count(*) as n_records

from "test"."raw_mart"."dim_start_date"
where date_key is not null
group by date_key
having count(*) > 1



      
    ) dbt_internal_test