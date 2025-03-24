select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        day_name as value_field,
        count(*) as n_records

    from "test"."raw"."trip_analysis"
    group by day_name

)

select *
from all_values
where value_field not in (
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
)



      
    ) dbt_internal_test