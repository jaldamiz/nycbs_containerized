
  
    
  create view "test"."raw_raw"."trip_analysis__dbt_tmp" as (
    

/*
@owner: Juan Aldamiz
@version: 1.0.0
@description: Analytical model for trip patterns and performance metrics
*/

-- This view demonstrates how to leverage the fact and dimension tables
-- to produce analytical insights for business users

with fact_data as (
    select * from "test"."raw_mart"."fact_tripdata"
),

dim_bike as (
    select * from "test"."raw_mart"."dim_bike"
),

dim_member as (
    select * from "test"."raw_mart"."dim_member"
),

dim_start_date as (
    select * from "test"."raw_mart"."dim_start_date"
),

dim_end_date as (
    select * from "test"."raw_mart"."dim_end_date"
),

dim_station as (
    select * from "test"."raw_mart"."dim_station"
),

-- Join all dimensions to the fact table
enriched_trips as (
    select
        -- Trip identifiers
        f.trip_id,
        f.ride_id,
        
        -- Time dimensions
        sd.date_day as start_date,
        sd.year as start_year,
        sd.month_name as start_month,
        sd.day_name as start_day_name,
        sd.is_weekend as start_is_weekend,
        sd.is_holiday as start_is_holiday,
        sd.season as start_season,
        sd.is_peak_season as start_is_peak_season,
        
        -- Time metrics
        f.trip_duration_minutes,
        f.start_hour,
        f.is_peak_hour,
        
        -- Member attributes
        m.member_casual,
        m.membership_description,
        m.membership_tier,
        
        -- Bike attributes
        b.rideable_type,
        b.bike_type_description,
        b.propulsion_category,
        b.has_electric_assist,
        
        -- Station information
        ss.station_name as start_station_name,
        ss.station_type as start_station_type,
        es.station_name as end_station_name,
        es.station_type as end_station_type,
        
        -- Trip metrics
        f.distance_km,
        f.distance_bucket,
        f.speed_kmh,
        f.is_round_trip,
        
        -- Business metrics
        f.pricing_tier,
        f.insurance_trip,
        
        -- Calculate derived business metrics
        case
            when f.trip_duration_minutes <= 30 then f.trip_duration_minutes * 0.15 * m.price_multiplier * b.price_multiplier
            when f.trip_duration_minutes <= 60 then (30 * 0.15 + (f.trip_duration_minutes - 30) * 0.25) * m.price_multiplier * b.price_multiplier
            else (30 * 0.15 + 30 * 0.25 + (f.trip_duration_minutes - 60) * 0.40) * m.price_multiplier * b.price_multiplier
        end as estimated_revenue_usd,
        
        case
            when f.trip_duration_minutes > b.maintenance_interval_days * 24 * 60 then 1
            else 0
        end as needs_maintenance_flag
        
    from fact_data f
    inner join dim_bike b on f.rideable_type_id = b.rideable_type_id
    inner join dim_member m on f.member_id = m.member_id
    inner join dim_start_date sd on f.start_date_id = sd.date_key
    inner join dim_end_date ed on f.end_date_id = ed.date_key
    inner join dim_station ss on f.start_station_id = ss.station_id
    inner join dim_station es on f.end_station_id = es.station_id
    where b.is_current = true and m.is_current = true -- SCD Type 2 current version filter
),

-- Example aggregation: Trip metrics by month, bike type, and member type
monthly_summaries as (
    select
        start_year,
        start_month,
        start_season,
        start_is_peak_season,
        propulsion_category,
        rideable_type,
        member_casual,
        
        -- Trip counts
        count(*) as trip_count,
        
        -- Duration metrics
        avg(trip_duration_minutes) as avg_trip_duration,
        min(trip_duration_minutes) as min_trip_duration,
        max(trip_duration_minutes) as max_trip_duration,
        
        -- Distance metrics
        avg(distance_km) as avg_distance,
        sum(distance_km) as total_distance,
        
        -- Speed metrics
        avg(speed_kmh) as avg_speed,
        
        -- Business metrics
        sum(estimated_revenue_usd) as estimated_total_revenue,
        avg(estimated_revenue_usd) as avg_revenue_per_trip,
        sum(insurance_trip) as insurance_required_trips,
        sum(needs_maintenance_flag) as maintenance_flag_count,
        
        -- Trip patterns
        sum(is_round_trip) as round_trip_count,
        sum(case when start_hour between 7 and 9 then 1 else 0 end) as morning_commute_trips,
        sum(case when start_hour between 16 and 19 then 1 else 0 end) as evening_commute_trips,
        sum(case when start_is_weekend = true then 1 else 0 end) as weekend_trips
        
    from enriched_trips
    group by 1, 2, 3, 4, 5, 6, 7
    order by 1, 2, 6, 7
)

-- Final output: monthly metrics with percentage calculations
select
    start_year,
    start_month,
    start_season,
    start_is_peak_season,
    propulsion_category,
    rideable_type,
    member_casual,
    trip_count,
    avg_trip_duration,
    avg_distance,
    avg_speed,
    estimated_total_revenue,
    avg_revenue_per_trip,
    insurance_required_trips,
    round(insurance_required_trips * 100.0 / trip_count, 2) as pct_insurance_trips,
    maintenance_flag_count,
    round_trip_count,
    round(round_trip_count * 100.0 / trip_count, 2) as pct_round_trips,
    morning_commute_trips,
    evening_commute_trips,
    weekend_trips,
    round(weekend_trips * 100.0 / trip_count, 2) as pct_weekend_trips
from monthly_summaries
  );
