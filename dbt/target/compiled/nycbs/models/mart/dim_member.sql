

/*
@owner: Juan Aldamiz
@version: 1.0.0
@description: Member dimension containing user type information for the bike sharing system
*/

with member_types as (
    select * from "test"."raw_raw"."member"
),

-- Add additional attributes for the dimension
enriched as (
    select
        member_casual,
        
        -- Add descriptive fields
        case
            when member_casual = 'member' then 'Annual Membership'
            when member_casual = 'casual' then 'Casual Rider'
            else 'Unknown Membership Type'
        end as membership_description,
        
        -- Add membership tier and benefit attributes
        case
            when member_casual = 'member' then 'premium'
            when member_casual = 'casual' then 'basic'
            else 'unknown'
        end as membership_tier,
        
        -- Add pricing attributes
        case
            when member_casual = 'member' then 0.85  -- 15% discount multiplier
            else 1.0
        end as price_multiplier,
        
        -- Add capability flags
        case when member_casual = 'member' then true else false end as has_unlimited_rides,
        case when member_casual = 'member' then true else false end as has_priority_booking,
        case when member_casual = 'member' then 45 else 30 end as max_ride_duration_minutes,
        
        -- Add SCD Type 2 tracking for future use
        true as is_current,
        '2023-01-01'::date as valid_from,  -- Example static date, would be dynamic in production
        '9999-12-31'::date as valid_to      -- End of time for current records
    from member_types
),

final as (
    select
        md5(cast(coalesce(cast(member_casual as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as member_id,
        member_casual,
        membership_description,
        membership_tier,
        price_multiplier,
        has_unlimited_rides,
        has_priority_booking,
        max_ride_duration_minutes,
        is_current,
        valid_from,
        valid_to
    from enriched
)

select * from final