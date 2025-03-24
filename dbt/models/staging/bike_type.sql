with 

source as (

    select * from {{ source('raw', 'tripdata') }}

),

renamed as (

    select distinct
        rideable_type,

    from source

)

select * from renamed