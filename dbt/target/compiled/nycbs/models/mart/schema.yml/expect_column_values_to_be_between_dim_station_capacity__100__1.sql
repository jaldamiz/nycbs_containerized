

with validation as (
    select
        capacity as column_value
    from "test"."raw_mart"."dim_station"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 1 or column_value > 100
    
)

select count(*) from validation_errors

