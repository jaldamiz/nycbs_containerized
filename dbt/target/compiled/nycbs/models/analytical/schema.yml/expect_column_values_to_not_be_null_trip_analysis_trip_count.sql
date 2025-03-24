

with validation as (
    select
        trip_count as column_value
    from "test"."raw_raw"."trip_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

