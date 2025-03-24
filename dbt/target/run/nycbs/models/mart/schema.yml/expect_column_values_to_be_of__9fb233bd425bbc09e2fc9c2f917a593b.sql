select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

-- Note: This test is limited by DuckDB's capabilities
-- It checks if values can be cast to the expected type without error
with validation as (
    select
        is_weekend as column_value
    from "test"."raw_mart"."dim_end_date"
),

validation_errors as (
    select
        column_value
    from validation
    where
    
        try_cast(column_value as boolean) is null and column_value is not null
    
)

select count(*) from validation_errors


      
    ) dbt_internal_test