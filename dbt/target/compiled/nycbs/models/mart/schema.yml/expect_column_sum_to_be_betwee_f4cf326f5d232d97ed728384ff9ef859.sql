

with validation as (
    select
        sum(trip_duration_minutes) as column_sum
    from "test"."raw_mart"."fact_tripdata"
),

validation_errors as (
    select
        column_sum
    from validation
    where column_sum < 1 or column_sum > 100000000
)

select count(*) from validation_errors

