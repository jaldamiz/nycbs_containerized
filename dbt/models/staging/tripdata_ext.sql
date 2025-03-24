{{
  config(
    materialized = 'table'
  )
}}

-- Alternative approach using a relative path
with source_parquet as (
    select * from read_parquet('data/bronze/rides_nyc/col-b9bb1351-dcb9-46c3-958c-e6c8aefc083f=2025/col-81d0d7f8-9682-4836-ac3b-d1fc099d6e51=*/*.parquet')
    union all
    select * from read_parquet('data/bronze/rides_nyc/col-b9bb1351-dcb9-46c3-958c-e6c8aefc083f=2024/col-81d0d7f8-9682-4836-ac3b-d1fc099d6e51=*/*.parquet')
)

-- IMPORTANT NOTE ABOUT DATA STRUCTURE:
-- In this dataset, the column "col-7037afb6-dcc6-4f1f-928e-a9e42a8272ad" contains
-- membership status information (member/casual), not actual bike types.
-- The city information is derived from the folder structure ("nyc")

select
    "col-6fdc68ca-05d2-4192-bab6-f5f3004afc91" as ride_id,
    -- We're using this field below for member_casual, but keeping it here for consistency with the source schema
    "col-7037afb6-dcc6-4f1f-928e-a9e42a8272ad" as rideable_type, 
    "col-c9a74aca-e814-4ee4-821e-586618418d54" as started_at,
    "col-af2e2fa9-2758-4a10-8998-233a12e42bd2" as ended_at,
    "col-18983d2a-741b-4a7f-bee1-9ba67e9b203f" as start_station_name,
    "col-53f70002-3545-4b79-a45d-6be2702b4da5" as start_station_id,
    "col-3ccb12ef-5e30-4dd7-b7ff-de9f0ffb1dc5" as end_station_name,
    "col-969c544e-964d-4c3c-95de-a0ae59081905" as end_station_id,
    "col-0e4da5e8-fa3a-4e0d-b4c0-f383882e5628" as start_lat,
    "col-5abb0215-e0dc-4d85-be04-c3578803127c" as start_lng,
    "col-f4a9d89d-2326-4bc6-9b5f-dd134b52b4a1" as end_lat,
    "col-eec30ea1-5af2-4ab1-a29b-8c1cd872af81" as end_lng,
    -- Fixing the column mapping: This field contains member/casual values
    "col-7037afb6-dcc6-4f1f-928e-a9e42a8272ad" as member_casual, 
    -- Adding city information derived from folder structure
    'nyc' as city, 
    "col-b9bb1351-dcb9-46c3-958c-e6c8aefc083f" as year,
    "col-81d0d7f8-9682-4836-ac3b-d1fc099d6e51" as month,
    -- Include any other columns that might be present in the original data
    * exclude(
        "col-6fdc68ca-05d2-4192-bab6-f5f3004afc91",
        "col-7037afb6-dcc6-4f1f-928e-a9e42a8272ad",
        "col-c9a74aca-e814-4ee4-821e-586618418d54",
        "col-af2e2fa9-2758-4a10-8998-233a12e42bd2",
        "col-18983d2a-741b-4a7f-bee1-9ba67e9b203f",
        "col-53f70002-3545-4b79-a45d-6be2702b4da5",
        "col-3ccb12ef-5e30-4dd7-b7ff-de9f0ffb1dc5",
        "col-969c544e-964d-4c3c-95de-a0ae59081905",
        "col-0e4da5e8-fa3a-4e0d-b4c0-f383882e5628",
        "col-5abb0215-e0dc-4d85-be04-c3578803127c",
        "col-f4a9d89d-2326-4bc6-9b5f-dd134b52b4a1",
        "col-eec30ea1-5af2-4ab1-a29b-8c1cd872af81",
        "col-4cd31af1-f22d-4fb2-83dc-4132a0621f26",
        "col-b9bb1351-dcb9-46c3-958c-e6c8aefc083f",
        "col-81d0d7f8-9682-4836-ac3b-d1fc099d6e51"
    )
from source_parquet 