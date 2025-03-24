
    
    

with all_values as (

    select
        station_type as value_field,
        count(*) as n_records

    from "test"."raw_raw"."station_analysis"
    group by station_type

)

select *
from all_values
where value_field not in (
    'bike_dock','virtual','hub','transit','mixed'
)


