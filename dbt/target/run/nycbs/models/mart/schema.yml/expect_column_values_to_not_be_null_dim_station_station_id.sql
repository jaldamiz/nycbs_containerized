select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        station_id as column_value
    from "test"."raw_mart"."dim_station"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors


      
    ) dbt_internal_test