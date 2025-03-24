select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        rideable_type as value_field,
        count(*) as n_records

    from "test"."raw_raw"."bike_type"
    group by rideable_type

)

select *
from all_values
where value_field not in (
    'electric_bike','classic_bike','docked_bike'
)



      
    ) dbt_internal_test