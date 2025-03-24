

with validation as (
    select
        peak_departure_hour as column_value
    from "test"."raw_raw"."station_analysis"
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

