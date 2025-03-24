

with validation as (
    select
        station_id as column_value
    from "test"."raw"."station_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

