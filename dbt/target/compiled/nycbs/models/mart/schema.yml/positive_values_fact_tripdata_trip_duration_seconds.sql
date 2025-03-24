

with validation as (
    select
        trip_duration_seconds as column_value
    from "test"."raw_mart"."fact_tripdata"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null and column_value <= 0
)

select count(*) from validation_errors

