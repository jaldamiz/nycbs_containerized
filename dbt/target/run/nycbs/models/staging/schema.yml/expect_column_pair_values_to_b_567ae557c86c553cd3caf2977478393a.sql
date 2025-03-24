select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      


    


with validation as (
    select
        member_casual as column_a_value,
        rideable_type as column_b_value
    from "test"."raw_raw"."tripdata"
),

validation_errors as (
    select
        column_a_value,
        column_b_value
    from validation
    where column_a_value != column_b_value
)

select count(*) from validation_errors


      
    ) dbt_internal_test