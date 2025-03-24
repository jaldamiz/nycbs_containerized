

with validation as (
    select
        start_hour as column_value
    from "test"."raw_mart"."fact_tripdata"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('0' as float) 
        or 
        cast(column_value as float) > cast('23' as float)
    )
)

select count(*) from validation_errors

