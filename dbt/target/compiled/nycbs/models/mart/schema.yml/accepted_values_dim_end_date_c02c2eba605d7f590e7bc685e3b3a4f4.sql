
    
    

with all_values as (

    select
        day_short_name as value_field,
        count(*) as n_records

    from "test"."raw_mart"."dim_end_date"
    group by day_short_name

)

select *
from all_values
where value_field not in (
    'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
)


