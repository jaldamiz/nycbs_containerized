with 

source as (

    select * from {{ ref('tripdata_ext') }}

),

renamed as (

    select
        source.start_station_name,
        source.start_station_id,
        source.start_lat,
        source.start_lng

    from source

)

select * from renamed