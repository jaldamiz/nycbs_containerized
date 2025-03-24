with 

source as (

    select * from {{ source('raw', 'tripdata') }}

),

renamed as (

    select distinct
        member_casual

    from source

)

select * from renamed