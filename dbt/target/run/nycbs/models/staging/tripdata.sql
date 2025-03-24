
  
    
    

    create  table
      "test"."raw_raw"."tripdata__dbt_tmp"
  
    as (
      

-- Refined staging model for trip data
-- Note: In our source data, there's an issue with the column mappings:
-- The "rideable_type" column actually contains member/casual designation
-- The tripdata_ext.sql model has been corrected to properly map these fields

with source as (
    select * from "test"."raw_raw"."tripdata_ext"
),

renamed as (
    select
        source.ride_id,
        source.rideable_type,  -- Note: This contains member/casual data in source, but we keep the original field name for consistency
        source.started_at,
        source.ended_at,
        source.start_station_name,
        source.start_station_id,
        source.end_station_name,
        source.end_station_id,
        source.start_lat,
        source.start_lng,
        source.end_lat,
        source.end_lng,
        source.member_casual,  -- This is now correctly mapped in tripdata_ext
        source.city            -- This is now correctly derived from the folder structure
    from source
)

select * from renamed
    );
  
  