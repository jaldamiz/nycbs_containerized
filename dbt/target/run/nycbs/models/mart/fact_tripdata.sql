
  
    
    
      
    

    create  table
      "test"."raw_mart"."fact_tripdata__dbt_tmp"
  
  (
    trip_id varchar,
    ride_id varchar,
    rideable_type_id varchar,
    start_station_id varchar,
    end_station_id varchar,
    member_id varchar,
    start_date_id date,
    end_date_id date,
    start_lat double,
    start_lng double,
    end_lat double,
    end_lng double,
    trip_duration_minutes bigint,
    trip_duration_seconds bigint,
    start_hour bigint,
    end_hour bigint,
    start_day_of_week bigint,
    end_day_of_week bigint,
    is_peak_hour integer,
    is_weekend integer,
    distance_km double,
    distance_bucket varchar,
    speed_kmh double,
    insurance_trip integer,
    pricing_tier varchar,
    is_round_trip integer,
    is_one_way_trip integer,
    city varchar
    
    )
 ;
    insert into "test"."raw_mart"."fact_tripdata__dbt_tmp" 
  (
    
      
      trip_id ,
    
      
      ride_id ,
    
      
      rideable_type_id ,
    
      
      start_station_id ,
    
      
      end_station_id ,
    
      
      member_id ,
    
      
      start_date_id ,
    
      
      end_date_id ,
    
      
      start_lat ,
    
      
      start_lng ,
    
      
      end_lat ,
    
      
      end_lng ,
    
      
      trip_duration_minutes ,
    
      
      trip_duration_seconds ,
    
      
      start_hour ,
    
      
      end_hour ,
    
      
      start_day_of_week ,
    
      
      end_day_of_week ,
    
      
      is_peak_hour ,
    
      
      is_weekend ,
    
      
      distance_km ,
    
      
      distance_bucket ,
    
      
      speed_kmh ,
    
      
      insurance_trip ,
    
      
      pricing_tier ,
    
      
      is_round_trip ,
    
      
      is_one_way_trip ,
    
      
      city 
    
  )
 (
      
    select trip_id, ride_id, rideable_type_id, start_station_id, end_station_id, member_id, start_date_id, end_date_id, start_lat, start_lng, end_lat, end_lng, trip_duration_minutes, trip_duration_seconds, start_hour, end_hour, start_day_of_week, end_day_of_week, is_peak_hour, is_weekend, distance_km, distance_bucket, speed_kmh, insurance_trip, pricing_tier, is_round_trip, is_one_way_trip, city
    from (
        

with tripdata as (
    select * from "test"."raw_raw"."tripdata"
),

dim_dates_start as (
    select * from "test"."raw_mart"."dim_start_date"
),

dim_dates_end as (
    select * from "test"."raw_mart"."dim_end_date"
),

dim_member as (
    select * from "test"."raw_mart"."dim_member"
),

dim_bike as (
    select * from "test"."raw_mart"."dim_bike"
),

dim_station as (
    select * from "test"."raw_mart"."dim_station"
),

-- Pre-calculate time metrics
time_metrics as (
    select
        ride_id,
        date_diff('minute', started_at, ended_at) as trip_duration_minutes,
        date_diff('second', started_at, ended_at) as trip_duration_seconds,
        -- Time of day metrics
        extract('hour' from started_at) as start_hour,
        extract('hour' from ended_at) as end_hour,
        -- Day of week metrics (1=Sunday, 7=Saturday)
        extract('dow' from started_at) + 1 as start_day_of_week,
        extract('dow' from ended_at) + 1 as end_day_of_week,
        -- Peak hours flag
        case 
            when extract('hour' from started_at) between 7 and 9 
                or extract('hour' from started_at) between 16 and 19 
            then 1 else 0 
        end as is_peak_hour,
        -- Weekend flag
        case 
            when extract('dow' from started_at) in (0, 6) then 1 else 0 
        end as is_weekend
    from tripdata
),

-- Join to station dimension for start station
start_station_lookup as (
    select
        t.ride_id,
        coalesce(s.station_id, md5(cast(coalesce(cast(t.start_station_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))) as start_station_dim_id
    from tripdata t
    left join dim_station s on t.start_station_id = s.original_station_id
),

-- Join to station dimension for end station
end_station_lookup as (
    select
        t.ride_id,
        coalesce(s.station_id, md5(cast(coalesce(cast(t.end_station_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT))) as end_station_dim_id
    from tripdata t
    left join dim_station s on t.end_station_id = s.original_station_id
),

-- Assign a bike type to each ride since our data doesn't have actual bike types
bike_assignment as (
    select
        t.ride_id,
        case 
            when ascii(substring(t.ride_id, 1, 1)) % 3 = 0 then 'electric_bike'
            when ascii(substring(t.ride_id, 1, 1)) % 3 = 1 then 'classic_bike'
            else 'docked_bike'
        end as assigned_bike_type
    from tripdata t
),

final as (
    select
        md5(cast(coalesce(cast(t.ride_id as TEXT), '_dbt_utils_surrogate_key_null_') as TEXT)) as trip_id,
        t.ride_id,
        b.rideable_type_id,
        ssl.start_station_dim_id as start_station_id,
        esl.end_station_dim_id as end_station_id,
        m.member_id,
        sd.date_key as start_date_id,
        ed.date_key as end_date_id,
        t.start_lat,
        t.start_lng,
        t.end_lat,
        t.end_lng,
        
        -- Time metrics
        tm.trip_duration_minutes,
        tm.trip_duration_seconds,
        tm.start_hour,
        tm.end_hour,
        tm.start_day_of_week,
        tm.end_day_of_week,
        tm.is_peak_hour,
        tm.is_weekend,
        
        -- Distance metrics
        
      -- Earth's radius in kilometers
    
    (
        2 * 6371.0 * asin(
            sqrt(
                pow(sin(radians(t.end_lat - t.start_lat) / 2), 2) +
                cos(radians(t.start_lat)) * cos(radians(t.end_lat)) *
                pow(sin(radians(t.end_lng - t.start_lng) / 2), 2)
            )
        )
    )
 as distance_km,
        case
            when 
      -- Earth's radius in kilometers
    
    (
        2 * 6371.0 * asin(
            sqrt(
                pow(sin(radians(t.end_lat - t.start_lat) / 2), 2) +
                cos(radians(t.start_lat)) * cos(radians(t.end_lat)) *
                pow(sin(radians(t.end_lng - t.start_lng) / 2), 2)
            )
        )
    )
 <= 1 then '0-1 km'
            when 
      -- Earth's radius in kilometers
    
    (
        2 * 6371.0 * asin(
            sqrt(
                pow(sin(radians(t.end_lat - t.start_lat) / 2), 2) +
                cos(radians(t.start_lat)) * cos(radians(t.end_lat)) *
                pow(sin(radians(t.end_lng - t.start_lng) / 2), 2)
            )
        )
    )
 <= 4 then '1-4 km'
            when 
      -- Earth's radius in kilometers
    
    (
        2 * 6371.0 * asin(
            sqrt(
                pow(sin(radians(t.end_lat - t.start_lat) / 2), 2) +
                cos(radians(t.start_lat)) * cos(radians(t.end_lat)) *
                pow(sin(radians(t.end_lng - t.start_lng) / 2), 2)
            )
        )
    )
 <= 9 then '4-9 km'
            else '10+ km'
        end as distance_bucket,
        
        -- Speed estimate (km/h) - only if duration is positive
        case 
            when tm.trip_duration_seconds > 0 
            then (
      -- Earth's radius in kilometers
    
    (
        2 * 6371.0 * asin(
            sqrt(
                pow(sin(radians(t.end_lat - t.start_lat) / 2), 2) +
                cos(radians(t.start_lat)) * cos(radians(t.end_lat)) *
                pow(sin(radians(t.end_lng - t.start_lng) / 2), 2)
            )
        )
    )
 / tm.trip_duration_seconds) * 3600 
            else null 
        end as speed_kmh,
        
        -- Insurance and revenue indicators
        case
            when tm.trip_duration_minutes > 30 then 1
            else 0
        end as insurance_trip,
        
        -- Pricing tier (example)
        case
            when tm.trip_duration_minutes <= 30 then 'standard'
            when tm.trip_duration_minutes <= 60 then 'extended'
            else 'premium'
        end as pricing_tier,
        
        -- Round trip indicator (if start and end stations are the same)
        case when t.start_station_id = t.end_station_id then 1 else 0 end as is_round_trip,
        
        -- Return to different station indicator
        case when t.start_station_id != t.end_station_id then 1 else 0 end as is_one_way_trip,
        
        -- City
        t.city
    from tripdata t
    inner join time_metrics tm on t.ride_id = tm.ride_id
    inner join start_station_lookup ssl on t.ride_id = ssl.ride_id
    inner join end_station_lookup esl on t.ride_id = esl.ride_id
    inner join dim_dates_start sd on cast(t.started_at as date) = sd.date_key
    inner join dim_dates_end ed on cast(t.ended_at as date) = ed.date_key
    inner join dim_member m on t.member_casual = m.member_casual  -- Using properly mapped member_casual values
    inner join bike_assignment ba on t.ride_id = ba.ride_id
    inner join dim_bike b on ba.assigned_bike_type = b.rideable_type
    where tm.trip_duration_minutes > 0  -- Filter out invalid trips with zero or negative duration
)

select * from final
    ) as model_subq
    );
  
  