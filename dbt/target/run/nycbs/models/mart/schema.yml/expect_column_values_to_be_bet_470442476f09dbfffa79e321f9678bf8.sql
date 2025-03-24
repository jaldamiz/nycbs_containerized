select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        trip_duration_seconds as column_value
    from "test"."raw_mart"."fact_tripdata"
),

validation_errors as (
    select
        column_value
    from validation
    where 
    
        column_value < 0 or column_value > 86400
    
)

select count(*) from validation_errors


      
    ) dbt_internal_test