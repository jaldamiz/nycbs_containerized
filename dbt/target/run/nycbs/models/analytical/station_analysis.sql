
  
    
    
      
    

    create  table
      "test"."raw"."station_analysis__dbt_tmp"
  
  (
    station_id varchar,
    station_name varchar,
    latitude double,
    longitude double,
    station_type varchar,
    total_departures bigint,
    total_arrivals bigint,
    net_flow bigint,
    peak_departure_hour bigint,
    peak_arrival_hour bigint,
    member_trip_pct double,
    casual_trip_pct double,
    avg_trip_duration double,
    weekend_usage_pct double,
    night_usage_pct double,
    popular_destinations varchar,
    electric_bike_pct double,
    rebalancing_need varchar,
    city varchar
    
    )
 ;
    insert into "test"."raw"."station_analysis__dbt_tmp" 
  (
    
      
      station_id ,
    
      
      station_name ,
    
      
      latitude ,
    
      
      longitude ,
    
      
      station_type ,
    
      
      total_departures ,
    
      
      total_arrivals ,
    
      
      net_flow ,
    
      
      peak_departure_hour ,
    
      
      peak_arrival_hour ,
    
      
      member_trip_pct ,
    
      
      casual_trip_pct ,
    
      
      avg_trip_duration ,
    
      
      weekend_usage_pct ,
    
      
      night_usage_pct ,
    
      
      popular_destinations ,
    
      
      electric_bike_pct ,
    
      
      rebalancing_need ,
    
      
      city 
    
  )
 (
      
    select station_id, station_name, latitude, longitude, station_type, total_departures, total_arrivals, net_flow, peak_departure_hour, peak_arrival_hour, member_trip_pct, casual_trip_pct, avg_trip_duration, weekend_usage_pct, night_usage_pct, popular_destinations, electric_bike_pct, rebalancing_need, city
    from (
        

with fact_trips as (
    select * from "test"."raw_mart"."fact_tripdata"
),

dim_stations as (
    select * from "test"."raw_mart"."dim_station"
),

dim_members as (
    select * from "test"."raw_mart"."dim_member"
),

dim_bikes as (
    select * from "test"."raw_mart"."dim_bike"
),

start_station_metrics as (
    select 
        start_station_id as station_id,
        count(*) as departure_count,
        avg(trip_duration_minutes) as avg_trip_duration,
        sum(case when is_weekend = true then 1 else 0 end) as weekend_trips,
        sum(case when start_hour >= 20 or start_hour < 6 then 1 else 0 end) as night_trips,
        sum(case when member_id in (select member_id from dim_members where member_casual = 'member') then 1 else 0 end) as member_trips,
        sum(case when rideable_type_id in (select rideable_type_id from dim_bikes where rideable_type = 'electric_bike') then 1 else 0 end) as electric_bike_trips
    from fact_trips
    where start_station_id is not null
    group by 1
),

end_station_metrics as (
    select 
        end_station_id as station_id,
        count(*) as arrival_count
    from fact_trips
    where end_station_id is not null
    group by 1
),

popular_destinations as (
    select 
        start_station_id as station_id,
        end_station_id as destination_id,
        count(*) as trip_count,
        row_number() over (partition by start_station_id order by count(*) desc) as rank
    from fact_trips
    where start_station_id is not null and end_station_id is not null
    group by 1, 2
),

top_destinations as (
    select
        station_id,
        string_agg(
            cast(destination_id as varchar) || ' (' || cast(trip_count as varchar) || ' trips)',
            ', '
            order by rank
        ) as destinations
    from popular_destinations
    where rank <= 3  -- Top 3 destinations
    group by station_id
),

combined_metrics as (
    select
        coalesce(s.station_id, e.station_id) as station_id,
        coalesce(s.departure_count, 0) as total_departures,
        coalesce(e.arrival_count, 0) as total_arrivals,
        coalesce(s.departure_count, 0) - coalesce(e.arrival_count, 0) as net_flow,
        coalesce(s.avg_trip_duration, 0) as avg_trip_duration,
        case 
            when coalesce(s.departure_count, 0) > 0 then 
                (coalesce(s.weekend_trips, 0) * 100.0 / coalesce(s.departure_count, 1))
            else 0
        end as weekend_usage_pct,
        case 
            when coalesce(s.departure_count, 0) > 0 then 
                (coalesce(s.night_trips, 0) * 100.0 / coalesce(s.departure_count, 1))
            else 0
        end as night_usage_pct,
        case 
            when coalesce(s.departure_count, 0) > 0 then 
                (coalesce(s.member_trips, 0) * 100.0 / coalesce(s.departure_count, 1))
            else 0
        end as member_trip_pct,
        case 
            when coalesce(s.departure_count, 0) > 0 then 
                (coalesce(s.departure_count, 0) - coalesce(s.member_trips, 0)) * 100.0 / coalesce(s.departure_count, 1)
            else 0
        end as casual_trip_pct,
        case 
            when coalesce(s.departure_count, 0) > 0 then 
                (coalesce(s.electric_bike_trips, 0) * 100.0 / coalesce(s.departure_count, 1))
            else 0
        end as electric_bike_pct,
        coalesce(d.destinations, 'None') as popular_destinations
    from start_station_metrics s
    full outer join end_station_metrics e on s.station_id = e.station_id
    left join top_destinations d on coalesce(s.station_id, e.station_id) = d.station_id
),

hourly_departures as (
    select
        start_station_id as station_id,
        start_hour,
        count(*) as trips,
        row_number() over (partition by start_station_id order by count(*) desc) as rank
    from fact_trips
    where start_station_id is not null
    group by 1, 2
),

hourly_arrivals as (
    select
        end_station_id as station_id,
        end_hour,
        count(*) as trips,
        row_number() over (partition by end_station_id order by count(*) desc) as rank
    from fact_trips
    where end_station_id is not null
    group by 1, 2
),

peak_hours as (
    select
        cm.station_id,
        hd.start_hour as peak_departure_hour,
        ha.end_hour as peak_arrival_hour
    from combined_metrics cm
    left join (select * from hourly_departures where rank = 1) hd on cm.station_id = hd.station_id
    left join (select * from hourly_arrivals where rank = 1) ha on cm.station_id = ha.station_id
),

final as (
    select
        s.station_id,
        s.station_name,
        s.latitude,
        s.longitude,
        case
            when s.station_name ilike '%hub%' then 'hub'
            when s.station_name ilike '%transit%' or s.station_name ilike '%train%' or s.station_name ilike '%subway%' then 'transit'
            when s.station_name ilike '%virtual%' then 'virtual'
            when s.is_electric = true then 'electric'
            else 'bike_dock'
        end as station_type,
        cm.total_departures,
        cm.total_arrivals,
        cm.net_flow,
        ph.peak_departure_hour,
        ph.peak_arrival_hour,
        cm.member_trip_pct,
        cm.casual_trip_pct,
        cm.avg_trip_duration,
        cm.weekend_usage_pct,
        cm.night_usage_pct,
        cm.popular_destinations,
        cm.electric_bike_pct,
        case
            when abs(cm.net_flow) > 100 then 'High'
            when abs(cm.net_flow) > 50 then 'Medium'
            when abs(cm.net_flow) > 10 then 'Low'
            else 'None'
        end as rebalancing_need,
        'nyc' as city
    from dim_stations s
    join combined_metrics cm on s.station_id = cm.station_id
    left join peak_hours ph on s.station_id = ph.station_id
)

select * from final
    ) as model_subq
    );
  
  