

with validation as (
    select
        start_station_name as column_value
    from "test"."raw_raw"."start_station"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

