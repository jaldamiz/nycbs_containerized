with 

source as (

    select * from {{ ref('member') }}

),

renamed as (

    select 
        {{ dbt_utils.generate_surrogate_key(['member_casual']) }} as member_casual_id,
        member_casual

    from source

)

select * from renamed