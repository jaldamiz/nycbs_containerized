
    
    

with all_values as (

    select
        rideable_type as value_field,
        count(*) as n_records

    from "test"."raw_raw"."tripdata"
    group by rideable_type

)

select *
from all_values
where value_field not in (
    'member','casual'
)


