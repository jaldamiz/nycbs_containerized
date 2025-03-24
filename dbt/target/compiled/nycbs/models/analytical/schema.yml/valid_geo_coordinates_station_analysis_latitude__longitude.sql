

with validation as (
    select
        latitude as lat_value,
        longitude as lng_value
    from "test"."raw"."station_analysis"
),

validation_errors as (
    select
        lat_value,
        lng_value
    from validation
    where lat_value < -90 or lat_value > 90 or lng_value < -180 or lng_value > 180
)

select count(*) from validation_errors

