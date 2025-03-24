select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        start_date as column_value
    from "test"."raw"."trip_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null
    and regexp_matches(cast(column_value as varchar), '^\d{4}-\d{2}-\d{2}$') = false
)

select count(*) from validation_errors


      
    ) dbt_internal_test