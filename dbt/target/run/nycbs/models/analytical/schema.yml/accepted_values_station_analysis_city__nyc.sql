select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        city as value_field,
        count(*) as n_records

    from "test"."raw"."station_analysis"
    group by city

)

select *
from all_values
where value_field not in (
    'nyc'
)



      
    ) dbt_internal_test