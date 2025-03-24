select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      


    


with ordered_data as (
    select
        date_key as column_value,
        lag(date_key) over (order by date_key) as prev_value
    from "test"."raw_mart"."dim_start_date"
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


      
    ) dbt_internal_test