select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select trip_duration_minutes
from "test"."raw_mart"."fact_tripdata"
where trip_duration_minutes is null



      
    ) dbt_internal_test