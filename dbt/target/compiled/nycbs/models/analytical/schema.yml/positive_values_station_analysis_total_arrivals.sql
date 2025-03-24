

with validation as (
    select
        total_arrivals as column_value
    from "test"."raw_raw"."station_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null and column_value <= 0
)

select count(*) from validation_errors

