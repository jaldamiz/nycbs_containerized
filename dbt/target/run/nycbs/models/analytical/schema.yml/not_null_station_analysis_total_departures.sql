select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_departures
from "test"."raw"."station_analysis"
where total_departures is null



      
    ) dbt_internal_test