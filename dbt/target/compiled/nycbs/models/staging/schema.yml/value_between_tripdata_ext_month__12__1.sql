

with validation as (
    select
        month as column_value
    from "test"."raw_raw"."tripdata_ext"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('1' as float) 
        or 
        cast(column_value as float) > cast('12' as float)
    )
)

select count(*) from validation_errors

