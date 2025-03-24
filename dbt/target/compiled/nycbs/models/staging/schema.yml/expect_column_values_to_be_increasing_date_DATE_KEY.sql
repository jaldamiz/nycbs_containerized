


    


with ordered_data as (
    select
        DATE_KEY as column_value,
        lag(DATE_KEY) over (order by DATE_KEY) as prev_value
    from "test"."raw_raw"."date"
),

validation_errors as (
    select
        column_value,
        prev_value
    from ordered_data
    where column_value <= prev_value
    and prev_value is not null
)

select count(*) from validation_errors

