

with validation as (
    select
        end_lat as lat_value,
        end_lng as lng_value
    from "test"."raw_raw"."tripdata"
),

validation_errors as (
    select
        lat_value,
        lng_value
    from validation
    where lat_value < -90 or lat_value > 90 or lng_value < -180 or lng_value > 180
)

select count(*) from validation_errors

