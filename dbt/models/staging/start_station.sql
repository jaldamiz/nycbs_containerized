with 

source as (

    select * from {{ source('raw', 'tripdata') }}

),

renamed as (

    select
        start_station_name,
        start_station_id,
        start_lat,
        start_lng

    from source

)

select * from renamed