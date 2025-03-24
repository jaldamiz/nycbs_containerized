select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        station_type as value_field,
        count(*) as n_records

    from "test"."raw"."station_analysis"
    group by station_type

)

select *
from all_values
where value_field not in (
    'bike_dock','virtual','hub','transit','mixed'
)



      
    ) dbt_internal_test