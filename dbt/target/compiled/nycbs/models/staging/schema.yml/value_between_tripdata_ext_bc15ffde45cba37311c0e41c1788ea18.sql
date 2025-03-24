

with validation as (
    select
        year as column_value
    from "test"."raw_raw"."tripdata_ext"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('2020' as float) 
        or 
        cast(column_value as float) > cast('2025' as float)
    )
)

select count(*) from validation_errors

