select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select expected_departures
from "test"."raw"."test_station_metrics"
where expected_departures is null



      
    ) dbt_internal_test