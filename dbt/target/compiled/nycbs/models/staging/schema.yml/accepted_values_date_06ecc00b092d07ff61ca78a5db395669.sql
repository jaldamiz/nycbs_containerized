
    
    

with all_values as (

    select
        MONTH_DESC as value_field,
        count(*) as n_records

    from "test"."raw_raw"."date"
    group by MONTH_DESC

)

select *
from all_values
where value_field not in (
    'January','February','March','April','May','June','July','August','September','October','November','December'
)


