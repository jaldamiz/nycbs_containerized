select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        sum(trip_count) as column_sum
    from "test"."raw"."trip_analysis"
),

validation_errors as (
    select
        column_sum
    from validation
    where column_sum < 1 or column_sum > 100000000
)

select count(*) from validation_errors


      
    ) dbt_internal_test