
    
    

with all_values as (

    select
        propulsion_category as value_field,
        count(*) as n_records

    from "test"."raw_raw"."trip_analysis"
    group by propulsion_category

)

select *
from all_values
where value_field not in (
    'powered','manual','unknown'
)


