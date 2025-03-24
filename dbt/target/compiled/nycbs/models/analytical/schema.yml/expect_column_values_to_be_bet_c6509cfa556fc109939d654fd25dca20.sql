

with validation as (
    select
        max_trip_duration as column_value
    from "test"."raw"."trip_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 0 or column_value > 1440
    
)

select count(*) from validation_errors

