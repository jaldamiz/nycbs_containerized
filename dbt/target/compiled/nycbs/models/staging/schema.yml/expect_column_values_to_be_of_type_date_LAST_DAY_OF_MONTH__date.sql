

-- Note: This test is limited by DuckDB's capabilities
-- It checks if values can be cast to the expected type without error
with validation as (
    select
        LAST_DAY_OF_MONTH as column_value
    from "test"."raw_raw"."date"
),

validation_errors as (
    select
        column_value
    from validation
    where
    
        try_cast(column_value as date) is null and column_value is not null
    
)

select count(*) from validation_errors

