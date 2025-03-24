select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select trip_duration_seconds
from "test"."raw_mart"."fact_tripdata"
where trip_duration_seconds is null



      
    ) dbt_internal_test