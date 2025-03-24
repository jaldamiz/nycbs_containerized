select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        price_multiplier as column_value
    from "test"."raw_mart"."dim_member"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 0.5 or column_value > 2.0
    
)

select count(*) from validation_errors


      
    ) dbt_internal_test