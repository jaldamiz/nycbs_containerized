

with validation as (
    select
        member_casual as column_value
    from "test"."raw_raw"."member"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

