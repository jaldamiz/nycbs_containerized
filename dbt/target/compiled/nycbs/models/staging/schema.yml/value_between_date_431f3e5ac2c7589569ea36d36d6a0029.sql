

with validation as (
    select
        YEAR_KEY as column_value
    from "test"."raw_raw"."date"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('2020' as float) 
        or 
        cast(column_value as float) > cast('2026' as float)
    )
)

select count(*) from validation_errors

