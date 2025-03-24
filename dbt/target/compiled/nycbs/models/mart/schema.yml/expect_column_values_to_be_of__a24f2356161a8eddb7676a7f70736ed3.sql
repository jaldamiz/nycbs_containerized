

-- Note: This test is limited by DuckDB's capabilities
-- It checks if values can be cast to the expected type without error
with validation as (
    select
        is_round_trip as column_value
    from "test"."raw_mart"."fact_tripdata"
),

validation_errors as (
    select
        column_value
    from validation
    where
    
        try_cast(column_value as boolean) is null and column_value is not null
    
)

select count(*) from validation_errors

