with 

source as (

    select * from {{ ref('tripdata_ext') }}

),

renamed as (

    select
        source.end_station_name,
        source.end_station_id,
        source.end_lat,
        source.end_lng

    from source

)

select * from renamed