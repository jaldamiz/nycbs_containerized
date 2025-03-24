

with validation as (
    select
        longitude as column_value
    from "test"."raw_mart"."dim_station"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('-74.1' as float) 
        or 
        cast(column_value as float) > cast('-73.7' as float)
    )
)

select count(*) from validation_errors

