
    
    

with child as (
    select start_station_id as from_field
    from "test"."raw_mart"."fact_tripdata"
    where start_station_id is not null
),

parent as (
    select station_id as to_field
    from "test"."raw_mart"."dim_station"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


