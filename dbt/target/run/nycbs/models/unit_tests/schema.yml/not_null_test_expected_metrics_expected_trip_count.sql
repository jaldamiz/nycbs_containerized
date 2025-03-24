select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select expected_trip_count
from "test"."raw"."test_expected_metrics"
where expected_trip_count is null



      
    ) dbt_internal_test