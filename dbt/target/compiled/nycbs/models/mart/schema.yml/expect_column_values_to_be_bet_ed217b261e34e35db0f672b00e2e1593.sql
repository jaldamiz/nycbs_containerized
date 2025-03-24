

with validation as (
    select
        trip_duration_minutes as column_value
    from "test"."raw_mart"."fact_tripdata"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 0 or column_value > 1440
    
)

select count(*) from validation_errors

