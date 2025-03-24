


    


with validation as (
    select
        ended_at as column_a_value,
        started_at as column_b_value
    from "test"."raw_raw"."tripdata"
),

validation_errors as (
    select
        column_a_value,
        column_b_value
    from validation
    where column_a_value <= column_b_value
)

select count(*) from validation_errors

