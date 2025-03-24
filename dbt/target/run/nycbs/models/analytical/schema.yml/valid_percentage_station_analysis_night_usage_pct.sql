select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        night_usage_pct as column_value
    from "test"."raw"."station_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < 0.0 
        or 
        cast(column_value as float) > 100.0
    )
    and column_value != 'PASS'
    and column_value != 'FAIL'
)

select count(*) from validation_errors


      
    ) dbt_internal_test