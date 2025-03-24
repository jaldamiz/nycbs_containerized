select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with validation as (
    select
        start_station_id as column_value
    from "test"."raw_raw"."start_station"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null
    and regexp_matches(cast(column_value as varchar), '^[A-Za-z0-9.]+$') = false
)

select count(*) from validation_errors


      
    ) dbt_internal_test