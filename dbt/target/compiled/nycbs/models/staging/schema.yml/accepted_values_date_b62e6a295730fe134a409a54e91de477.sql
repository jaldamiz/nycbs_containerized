
    
    

with all_values as (

    select
        WEEK_DAY_DESC as value_field,
        count(*) as n_records

    from "test"."raw_raw"."date"
    group by WEEK_DAY_DESC

)

select *
from all_values
where value_field not in (
    'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
)


