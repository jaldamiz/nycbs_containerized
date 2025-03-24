select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        distance_bucket as value_field,
        count(*) as n_records

    from "test"."raw_mart"."fact_tripdata"
    group by distance_bucket

)

select *
from all_values
where value_field not in (
    '0-1 km','1-4 km','4-9 km','10+ km'
)



      
    ) dbt_internal_test