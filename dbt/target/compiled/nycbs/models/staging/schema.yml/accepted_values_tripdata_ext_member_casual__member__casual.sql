
    
    

with all_values as (

    select
        member_casual as value_field,
        count(*) as n_records

    from "test"."raw_raw"."tripdata_ext"
    group by member_casual

)

select *
from all_values
where value_field not in (
    'member','casual'
)


