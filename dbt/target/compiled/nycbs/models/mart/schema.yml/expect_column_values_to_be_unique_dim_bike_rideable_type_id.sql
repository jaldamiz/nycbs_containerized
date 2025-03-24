

with validation as (
    select
        rideable_type_id as column_value
    from "test"."raw_mart"."dim_bike"
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

