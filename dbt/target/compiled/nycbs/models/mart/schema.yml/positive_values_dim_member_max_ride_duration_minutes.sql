

with validation as (
    select
        max_ride_duration_minutes as column_value
    from "test"."raw_mart"."dim_member"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null and column_value <= 0
)

select count(*) from validation_errors

