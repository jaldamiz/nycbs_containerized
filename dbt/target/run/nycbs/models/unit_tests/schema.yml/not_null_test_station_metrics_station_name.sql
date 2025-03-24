select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select station_name
from "test"."raw"."test_station_metrics"
where station_name is null



      
    ) dbt_internal_test