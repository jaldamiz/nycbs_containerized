
    
    

with child as (
    select rideable_type_id as from_field
    from "test"."raw_mart"."fact_tripdata"
    where rideable_type_id is not null
),

parent as (
    select rideable_type_id as to_field
    from "test"."raw_mart"."dim_bike"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


