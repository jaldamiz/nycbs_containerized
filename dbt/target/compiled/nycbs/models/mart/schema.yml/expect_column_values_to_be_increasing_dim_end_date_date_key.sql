


    


with ordered_data as (
    select
        date_key as column_value,
        lag(date_key) over (order by date_key) as prev_value
    from "test"."raw_mart"."dim_end_date"
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

