

with validation as (
    select
        date_key as column_value
    from "test"."raw_mart"."dim_end_date"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null
    and regexp_matches(cast(column_value as varchar), '^\d{4}-\d{2}-\d{2}$') = false
)

select count(*) from validation_errors

