

with validation as (
    select
        distance_km as column_value
    from "test"."raw_mart"."fact_tripdata"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 0 or column_value > 100
    
)

select count(*) from validation_errors

