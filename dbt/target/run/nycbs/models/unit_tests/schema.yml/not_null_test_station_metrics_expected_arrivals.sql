select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select expected_arrivals
from "test"."raw"."test_station_metrics"
where expected_arrivals is null



      
    ) dbt_internal_test