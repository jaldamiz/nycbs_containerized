

with 

start_stations as (
    select 
        start_station_id as original_station_id,
        start_station_name as station_name,
        start_lat as latitude,
        start_lng as longitude,
        'start' as source_type
    from "test"."raw_raw"."start_station"
),

end_stations as (
    select 
        end_station_id as original_station_id,
        end_station_name as station_name,
        end_lat as latitude,
        end_lng as longitude,
        'end' as source_type
    from "test"."raw_raw"."end_station"
),

combined_stations as (
    select * from start_stations
    union
    select * from end_stations
),

deduplicated as (
    select
        original_station_id,
        station_name,
        latitude,
        longitude,
        -- Use the first occurrence of data for each station
        row_number() over(partition by original_station_id order by station_name) as rn
    from combined_stations
),

final as (
    select
        md5(cast(coalesce(cast(original_station_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as station_id,
        original_station_id,
        station_name,
        latitude,
        longitude,
        -- Derive station type based on name patterns
        case
            when station_name like '%Ave%' then 'avenue'
            when station_name like '%St%' then 'street'
            when station_name like '%Park%' then 'park'
            when station_name like '%Pl%' then 'plaza'
            else 'other'
        end as station_type,
        -- We don't have actual capacity data, but in a real implementation
        -- this would be populated from another source
        null as capacity,
        -- We don't have electric data, but in a real implementation
        -- this would be populated from another source
        false as is_electric
    from deduplicated
    where rn = 1  -- Deduplication logic
)

select * from final