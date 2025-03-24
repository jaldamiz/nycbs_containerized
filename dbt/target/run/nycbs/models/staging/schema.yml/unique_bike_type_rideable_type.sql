select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    rideable_type as unique_field,
    count(*) as n_records

from "test"."raw_raw"."bike_type"
where rideable_type is not null
group by rideable_type
having count(*) > 1



      
    ) dbt_internal_test