
    
    

with all_values as (

    select
        WEEK_DAY_SHORT_DESC as value_field,
        count(*) as n_records

    from "test"."raw_raw"."date"
    group by WEEK_DAY_SHORT_DESC

)

select *
from all_values
where value_field not in (
    'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
)


