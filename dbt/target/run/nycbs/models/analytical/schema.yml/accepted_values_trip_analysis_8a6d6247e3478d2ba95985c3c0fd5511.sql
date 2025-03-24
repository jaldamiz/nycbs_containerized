select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        part_of_day as value_field,
        count(*) as n_records

    from "test"."raw"."trip_analysis"
    group by part_of_day

)

select *
from all_values
where value_field not in (
    'Morning','Afternoon','Evening','Night'
)



      
    ) dbt_internal_test