

with validation as (
    select
        member_id as column_value
    from "test"."raw_mart"."dim_member"
),

validation_errors as (
    select
        column_value,
        count(*) as occurrences
    from validation
    group by column_value
    having count(*) > 1
)

select count(*) from validation_errors

