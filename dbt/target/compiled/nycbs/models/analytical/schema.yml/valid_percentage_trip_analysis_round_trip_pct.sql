

with validation as (
    select
        round_trip_pct as column_value
    from "test"."raw"."trip_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < 0.0 
        or 
        cast(column_value as float) > 100.0
    )
    and column_value != 'PASS'
    and column_value != 'FAIL'
)

select count(*) from validation_errors

