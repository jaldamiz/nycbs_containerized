

with validation as (
    select
        sum(trip_count) as column_sum
    from "test"."raw_raw"."trip_analysis"
),

validation_errors as (
    select
        column_sum
    from validation
    where column_sum < 1 or column_sum > 100000000
)

select count(*) from validation_errors

