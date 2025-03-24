
    
    

with all_values as (

    select
        QUARTER_DESC as value_field,
        count(*) as n_records

    from "test"."raw_raw"."date"
    group by QUARTER_DESC

)

select *
from all_values
where value_field not in (
    'Quarter 1','Quarter 2','Quarter 3','Quarter 4'
)


