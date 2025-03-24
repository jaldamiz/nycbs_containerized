
    
    

with child as (
    select end_date_id as from_field
    from "test"."raw_mart"."fact_tripdata"
    where end_date_id is not null
),

parent as (
    select date_key as to_field
    from "test"."raw_mart"."dim_end_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


