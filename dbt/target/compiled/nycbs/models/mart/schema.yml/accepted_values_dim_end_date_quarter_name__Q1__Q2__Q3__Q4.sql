
    
    

with all_values as (

    select
        quarter_name as value_field,
        count(*) as n_records

    from "test"."raw_mart"."dim_end_date"
    group by quarter_name

)

select *
from all_values
where value_field not in (
    'Q1','Q2','Q3','Q4'
)


