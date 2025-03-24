

with validation as (
    select
        rideable_type as column_value
    from "test"."raw_mart"."dim_bike"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

