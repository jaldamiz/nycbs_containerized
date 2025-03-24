select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        propulsion_category as value_field,
        count(*) as n_records

    from "test"."raw_mart"."dim_bike"
    group by propulsion_category

)

select *
from all_values
where value_field not in (
    'powered','manual','unknown'
)



      
    ) dbt_internal_test