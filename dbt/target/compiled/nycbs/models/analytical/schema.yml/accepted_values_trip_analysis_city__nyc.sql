
    
    

with all_values as (

    select
        city as value_field,
        count(*) as n_records

    from "test"."raw"."trip_analysis"
    group by city

)

select *
from all_values
where value_field not in (
    'nyc'
)


