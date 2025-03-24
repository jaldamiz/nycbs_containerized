select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

-- Test if the row count of a model matches an expected model
with actual as (
    select count(*) as row_count from "test"."raw_raw"."tripdata"
),

expected as (
    select count(*) as row_count from "test"."raw_raw"."tripdata_ext"
),

validation_errors as (
    select 
        a.row_count as actual_row_count,
        e.row_count as expected_row_count
    from actual a
    cross join expected e
    where a.row_count != e.row_count
)

select count(*) from validation_errors


      
    ) dbt_internal_test