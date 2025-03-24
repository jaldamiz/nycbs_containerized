



with actual as (
    select 
        
        station_id,
        
        
        total_departures as actual_total_departures,
        
        total_arrivals as actual_total_arrivals,
        
        net_flow as actual_net_flow,
        
        member_trip_pct as actual_member_trip_pct,
        
        avg_trip_duration as actual_avg_trip_duration
        
    from "test"."raw"."test_station_metrics"
),

expected as (
    select 
        
        station_id,
        
        
        total_departures as expected_total_departures,
        
        total_arrivals as expected_total_arrivals,
        
        net_flow as expected_net_flow,
        
        member_trip_pct as expected_member_trip_pct,
        
        avg_trip_duration as expected_avg_trip_duration
        
    from "test"."raw"."expected_station_metrics"
),

compared as (
    select
        a.*,
        
        e.expected_total_departures,
        abs(a.actual_total_departures - e.expected_total_departures) as total_departures_diff,
        case
            when a.actual_total_departures = 0 and e.expected_total_departures = 0 then 0
            when e.expected_total_departures = 0 then 1.0
            else abs(a.actual_total_departures - e.expected_total_departures) / e.expected_total_departures
        end as total_departures_pct_diff,
        
        e.expected_total_arrivals,
        abs(a.actual_total_arrivals - e.expected_total_arrivals) as total_arrivals_diff,
        case
            when a.actual_total_arrivals = 0 and e.expected_total_arrivals = 0 then 0
            when e.expected_total_arrivals = 0 then 1.0
            else abs(a.actual_total_arrivals - e.expected_total_arrivals) / e.expected_total_arrivals
        end as total_arrivals_pct_diff,
        
        e.expected_net_flow,
        abs(a.actual_net_flow - e.expected_net_flow) as net_flow_diff,
        case
            when a.actual_net_flow = 0 and e.expected_net_flow = 0 then 0
            when e.expected_net_flow = 0 then 1.0
            else abs(a.actual_net_flow - e.expected_net_flow) / e.expected_net_flow
        end as net_flow_pct_diff,
        
        e.expected_member_trip_pct,
        abs(a.actual_member_trip_pct - e.expected_member_trip_pct) as member_trip_pct_diff,
        case
            when a.actual_member_trip_pct = 0 and e.expected_member_trip_pct = 0 then 0
            when e.expected_member_trip_pct = 0 then 1.0
            else abs(a.actual_member_trip_pct - e.expected_member_trip_pct) / e.expected_member_trip_pct
        end as member_trip_pct_pct_diff,
        
        e.expected_avg_trip_duration,
        abs(a.actual_avg_trip_duration - e.expected_avg_trip_duration) as avg_trip_duration_diff,
        case
            when a.actual_avg_trip_duration = 0 and e.expected_avg_trip_duration = 0 then 0
            when e.expected_avg_trip_duration = 0 then 1.0
            else abs(a.actual_avg_trip_duration - e.expected_avg_trip_duration) / e.expected_avg_trip_duration
        end as avg_trip_duration_pct_diff
        
    from actual a
    join expected e on
        
        a.station_id = e.station_id
        
),

validation_errors as (
    select *
    from compared
    where 
        
        total_departures_pct_diff > 0.1 or 
        
        total_arrivals_pct_diff > 0.1 or 
        
        net_flow_pct_diff > 0.1 or 
        
        member_trip_pct_pct_diff > 0.1 or 
        
        avg_trip_duration_pct_diff > 0.1
        
)

select count(*) from validation_errors

