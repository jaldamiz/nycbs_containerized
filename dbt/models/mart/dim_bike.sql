with 

source as (

    select * from {{ ref('bike_type') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['rideable_type']) }} as rideable_type_id,
        rideable_type,

    from source

)

select * from renamed