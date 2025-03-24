



with actual as (
    select 
        
        start_year,
        
        start_month,
        
        member_casual,
        
        
        trip_count as actual_trip_count,
        
        avg_trip_duration as actual_avg_trip_duration,
        
        round_trip_pct as actual_round_trip_pct
        
    from "test"."raw"."test_expected_metrics"
),

expected as (
    select 
        
        start_year,
        
        start_month,
        
        member_casual,
        
        
        trip_count as expected_trip_count,
        
        avg_trip_duration as expected_avg_trip_duration,
        
        round_trip_pct as expected_round_trip_pct
        
    from "test"."raw"."expected_trip_metrics"
),

compared as (
    select
        a.*,
        
        e.expected_trip_count,
        abs(a.actual_trip_count - e.expected_trip_count) as trip_count_diff,
        case
            when a.actual_trip_count = 0 and e.expected_trip_count = 0 then 0
            when e.expected_trip_count = 0 then 1.0
            else abs(a.actual_trip_count - e.expected_trip_count) / e.expected_trip_count
        end as trip_count_pct_diff,
        
        e.expected_avg_trip_duration,
        abs(a.actual_avg_trip_duration - e.expected_avg_trip_duration) as avg_trip_duration_diff,
        case
            when a.actual_avg_trip_duration = 0 and e.expected_avg_trip_duration = 0 then 0
            when e.expected_avg_trip_duration = 0 then 1.0
            else abs(a.actual_avg_trip_duration - e.expected_avg_trip_duration) / e.expected_avg_trip_duration
        end as avg_trip_duration_pct_diff,
        
        e.expected_round_trip_pct,
        abs(a.actual_round_trip_pct - e.expected_round_trip_pct) as round_trip_pct_diff,
        case
            when a.actual_round_trip_pct = 0 and e.expected_round_trip_pct = 0 then 0
            when e.expected_round_trip_pct = 0 then 1.0
            else abs(a.actual_round_trip_pct - e.expected_round_trip_pct) / e.expected_round_trip_pct
        end as round_trip_pct_pct_diff
        
    from actual a
    join expected e on
        
        a.start_year = e.start_year and 
        
        a.start_month = e.start_month and 
        
        a.member_casual = e.member_casual
        
),

validation_errors as (
    select *
    from compared
    where 
        
        trip_count_pct_diff > 0.1 or 
        
        avg_trip_duration_pct_diff > 0.1 or 
        
        round_trip_pct_pct_diff > 0.1
        
)

select count(*) from validation_errors

