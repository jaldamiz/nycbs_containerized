

with validation as (
    select
        avg_speed as column_value
    from "test"."raw_raw"."trip_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 0 or column_value > 50
    
)

select count(*) from validation_errors

