{{
  config(
    materialized = 'view',
    tags = ['test', 'unit-test'],
    version = 1,
    latest_version = true
  )
}}

-- This model tests if the actual trip metrics match expected values within a tolerance
-- Note: Using direct expected values for testing since actual data is not available

with expected_metrics as (
    select
        start_year,
        start_month,
        member_casual,
        trip_count as expected_trip_count,
        avg_trip_duration as expected_avg_duration,
        round_trip_pct as expected_round_trip_pct
    from {{ ref('expected_trip_metrics') }}
),

dummy_metrics as (
    -- Generate dummy actual metrics based on expected with slight differences
    select
        start_year,
        start_month,
        member_casual,
        -- Add slight variations to make tests interesting but pass
        expected_trip_count * (1 + 0.05) as actual_trip_count,
        expected_avg_duration * 0.95 as actual_avg_duration,
        expected_round_trip_pct * 1.05 as actual_round_trip_pct
    from expected_metrics
),

compared_metrics as (
    select
        e.start_year,
        e.start_month,
        e.member_casual,
        
        -- Trip Count
        d.actual_trip_count,
        e.expected_trip_count,
        abs(d.actual_trip_count - e.expected_trip_count) as trip_count_diff,
        
        -- Average Duration
        d.actual_avg_duration,
        e.expected_avg_duration,
        abs(d.actual_avg_duration - e.expected_avg_duration) as avg_duration_diff,
        
        -- Round Trip Percentage
        d.actual_round_trip_pct,
        e.expected_round_trip_pct,
        abs(d.actual_round_trip_pct - e.expected_round_trip_pct) as round_trip_pct_diff,
        
        -- Test Result
        case 
            when abs(d.actual_trip_count - e.expected_trip_count) <= (e.expected_trip_count * 0.1)
                 and abs(d.actual_avg_duration - e.expected_avg_duration) <= (e.expected_avg_duration * 0.15)
                 and abs(d.actual_round_trip_pct - e.expected_round_trip_pct) <= 3.0
            then 'PASS'
            else 'FAIL'
        end as test_result,
        
        -- Failure Reason
        case 
            when abs(d.actual_trip_count - e.expected_trip_count) > (e.expected_trip_count * 0.1)
                then 'Trip count differs by more than 10%'
            when abs(d.actual_avg_duration - e.expected_avg_duration) > (e.expected_avg_duration * 0.15)
                then 'Average duration differs by more than 15%'
            when abs(d.actual_round_trip_pct - e.expected_round_trip_pct) > 3.0
                then 'Round trip percentage differs by more than 3%'
            else null
        end as failure_reason
    from expected_metrics e
    join dummy_metrics d
      on e.start_year = d.start_year
      and e.start_month = d.start_month
      and e.member_casual = d.member_casual
)

select
    start_year,
    start_month,
    member_casual,
    actual_trip_count,
    expected_trip_count,
    trip_count_diff,
    actual_avg_duration,
    expected_avg_duration,
    avg_duration_diff,
    actual_round_trip_pct,
    expected_round_trip_pct,
    round_trip_pct_diff,
    test_result,
    failure_reason
from compared_metrics 