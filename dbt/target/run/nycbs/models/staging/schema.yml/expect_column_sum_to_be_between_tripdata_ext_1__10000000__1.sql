select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        sum(1) as column_sum
    from "test"."raw_raw"."tripdata_ext"
),

validation_errors as (
    select
        column_sum
    from validation
    where column_sum < 1 or column_sum > 10000000
)

select count(*) from validation_errors


      
    ) dbt_internal_test