select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        peak_arrival_hour as column_value
    from "test"."raw"."station_analysis"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('0' as float) 
        or 
        cast(column_value as float) > cast('23' as float)
    )
)

select count(*) from validation_errors


      
    ) dbt_internal_test