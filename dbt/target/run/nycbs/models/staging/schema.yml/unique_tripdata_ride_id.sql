select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    ride_id as unique_field,
    count(*) as n_records

from "test"."raw_raw"."tripdata"
where ride_id is not null
group by ride_id
having count(*) > 1



      
    ) dbt_internal_test