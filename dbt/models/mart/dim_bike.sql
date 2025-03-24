{{
    config(
        materialized="table",
        version = "1.0.0",
        latest_version = true,
        owner = "Juan Aldamiz"
    )
}}

/*
@owner: Juan Aldamiz
@version: 1.0.0
@description: Bike dimension containing information about bike types and their attributes
*/

with bike_types as (
    select * from {{ ref('bike_type') }}
),

-- Add additional attributes for the dimension
enriched as (
    select
        rideable_type,
        case
            when rideable_type = 'electric_bike' then 'Electric-Powered Bicycle'
            when rideable_type = 'classic_bike' then 'Standard Pedal Bicycle'
            when rideable_type = 'docked_bike' then 'Station-Docked Bicycle'
            else 'Unknown Bicycle Type'
        end as bike_type_description,
        
        -- Add bike category grouping
        case
            when rideable_type = 'electric_bike' then 'powered'
            when rideable_type in ('classic_bike', 'docked_bike') then 'manual'
            else 'unknown'
        end as propulsion_category,
        
        -- Add capability flags
        case when rideable_type = 'electric_bike' then true else false end as has_electric_assist,
        case when rideable_type = 'docked_bike' then true else false end as requires_docking,
        
        -- Add estimated maintenance attributes
        case
            when rideable_type = 'electric_bike' then 14 -- days between maintenance checks
            when rideable_type = 'classic_bike' then 30
            when rideable_type = 'docked_bike' then 30
            else 30
        end as maintenance_interval_days,
        
        -- Add business metrics
        case
            when rideable_type = 'electric_bike' then 1.5 -- price multiplier
            else 1.0
        end as price_multiplier,
        
        -- Add SCD Type 2 tracking
        true as is_current,
        '2023-01-01'::date as valid_from, -- Example static date, would be dynamic in production
        '9999-12-31'::date as valid_to     -- End of time for current records
    from bike_types
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['rideable_type']) }} as rideable_type_id,
        rideable_type,
        bike_type_description,
        propulsion_category,
        has_electric_assist,
        requires_docking,
        maintenance_interval_days,
        price_multiplier,
        is_current,
        valid_from,
        valid_to
    from enriched
)

select * from final