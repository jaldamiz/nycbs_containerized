select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        QUARTER_SHORT_DESC as value_field,
        count(*) as n_records

    from "test"."raw_raw"."date"
    group by QUARTER_SHORT_DESC

)

select *
from all_values
where value_field not in (
    'Q1','Q2','Q3','Q4'
)



      
    ) dbt_internal_test