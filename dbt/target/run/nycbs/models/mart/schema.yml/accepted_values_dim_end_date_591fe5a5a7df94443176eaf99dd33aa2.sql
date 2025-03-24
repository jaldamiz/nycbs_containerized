select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        season as value_field,
        count(*) as n_records

    from "test"."raw_mart"."dim_end_date"
    group by season

)

select *
from all_values
where value_field not in (
    'Winter','Spring','Summer','Fall'
)



      
    ) dbt_internal_test