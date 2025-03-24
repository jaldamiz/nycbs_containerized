select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        day_of_month as column_value
    from "test"."raw_mart"."dim_end_date"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('1' as float) 
        or 
        cast(column_value as float) > cast('31' as float)
    )
)

select count(*) from validation_errors


      
    ) dbt_internal_test