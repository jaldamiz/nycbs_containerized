select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      

with parent as (
    select distinct ride_id as id
    from "test"."raw_raw"."tripdata"
),

child as (
    select distinct ride_id as id
    from "test"."raw_mart"."fact_tripdata"
    where ride_id is not null
),

invalid_keys as (
    select id
    from child
    where id not in (select id from parent)
)

select count(*) from invalid_keys


      
    ) dbt_internal_test