
    
    

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


