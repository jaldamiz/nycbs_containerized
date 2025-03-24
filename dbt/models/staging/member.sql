{{
  config(
    materialized = 'table'
  )
}}

with source as (
    select * from {{ ref('tripdata_ext') }}
),

renamed as (
    select distinct
        source.member_casual -- Now correctly mapped from the source data
    from source
)

select * from renamed