

with validation as (
    select
        max_ride_duration_minutes as column_value
    from "test"."raw_mart"."dim_member"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 30 or column_value > 180
    
)

select count(*) from validation_errors

