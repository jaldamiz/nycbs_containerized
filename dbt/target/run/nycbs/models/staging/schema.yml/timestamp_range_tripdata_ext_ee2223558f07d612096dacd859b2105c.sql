select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

-- Convert 'current_timestamp()' text to an actual current_timestamp function call

    



    


with validation as (
    select
        started_at as column_value
    from "test"."raw_raw"."tripdata_ext"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value < '2020-01-01' or column_value > 'now()'
)

select count(*) from validation_errors


      
    ) dbt_internal_test