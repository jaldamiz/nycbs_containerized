select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        DAY_SUFFIX as value_field,
        count(*) as n_records

    from "test"."raw_raw"."date"
    group by DAY_SUFFIX

)

select *
from all_values
where value_field not in (
    'st','nd','rd','th'
)



      
    ) dbt_internal_test