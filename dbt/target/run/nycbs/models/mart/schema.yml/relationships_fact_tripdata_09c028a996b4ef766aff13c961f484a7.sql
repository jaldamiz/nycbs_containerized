select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with child as (
    select start_date_id as from_field
    from "test"."raw_mart"."fact_tripdata"
    where start_date_id is not null
),

parent as (
    select date_key as to_field
    from "test"."raw_mart"."dim_start_date"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null



      
    ) dbt_internal_test