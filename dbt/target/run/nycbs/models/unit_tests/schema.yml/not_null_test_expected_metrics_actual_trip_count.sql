select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select actual_trip_count
from "test"."raw"."test_expected_metrics"
where actual_trip_count is null



      
    ) dbt_internal_test