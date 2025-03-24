

with validation as (
    select
        date_key as column_value
    from "test"."raw_mart"."dim_start_date"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

