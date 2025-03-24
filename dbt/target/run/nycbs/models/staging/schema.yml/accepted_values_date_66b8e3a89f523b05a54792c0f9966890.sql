select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        MONTH_SHORT_DESC as value_field,
        count(*) as n_records

    from "test"."raw_raw"."date"
    group by MONTH_SHORT_DESC

)

select *
from all_values
where value_field not in (
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
)



      
    ) dbt_internal_test