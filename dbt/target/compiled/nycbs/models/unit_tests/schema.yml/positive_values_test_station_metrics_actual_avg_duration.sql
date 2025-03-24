

with validation as (
    select
        actual_avg_duration as column_value
    from "test"."raw"."test_station_metrics"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value <= 0 or column_value is null
)

select count(*) from validation_errors

