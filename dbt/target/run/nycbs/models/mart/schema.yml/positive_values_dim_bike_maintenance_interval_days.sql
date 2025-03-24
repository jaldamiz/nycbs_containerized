select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        maintenance_interval_days as column_value
    from "test"."raw_mart"."dim_bike"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null and column_value <= 0
)

select count(*) from validation_errors


      
    ) dbt_internal_test