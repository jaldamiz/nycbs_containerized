select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select test_result
from "test"."raw"."test_station_metrics"
where test_result is null



      
    ) dbt_internal_test