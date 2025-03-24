
    
    

with child as (
    select member_id as from_field
    from "test"."raw_mart"."fact_tripdata"
    where member_id is not null
),

parent as (
    select member_id as to_field
    from "test"."raw_mart"."dim_member"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


