

with validation as (
    select
        quarter_number as column_value
    from "test"."raw_mart"."dim_start_date"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('1' as float) 
        or 
        cast(column_value as float) > cast('4' as float)
    )
)

select count(*) from validation_errors

