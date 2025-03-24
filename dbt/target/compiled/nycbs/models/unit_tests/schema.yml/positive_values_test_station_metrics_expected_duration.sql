

with validation as (
    select
        expected_duration as column_value
    from "test"."raw"."test_station_metrics"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null and column_value <= 0
)

select count(*) from validation_errors

