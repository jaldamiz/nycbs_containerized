

with validation as (
    select
        QUARTER_KEY as column_value
    from "test"."raw_raw"."date"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null
    and regexp_matches(cast(column_value as varchar), '^\d{5}$') = false
)

select count(*) from validation_errors

