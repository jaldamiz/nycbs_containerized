select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select actual_arrivals
from "test"."raw"."test_station_metrics"
where actual_arrivals is null



      
    ) dbt_internal_test