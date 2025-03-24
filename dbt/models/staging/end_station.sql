with 

source as (

    select * from {{ source('raw', 'tripdata') }}

),

renamed as (

    select
        end_station_name,
        end_station_id,
        end_lat,
        end_lng

    from source

)

select * from renamed