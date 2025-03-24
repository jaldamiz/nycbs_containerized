

with validation as (
    select
        end_station_name as column_value
    from "test"."raw_raw"."end_station"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

