
    
    

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


