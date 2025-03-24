select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select trip_count
from "test"."raw"."trip_analysis"
where trip_count is null



      
    ) dbt_internal_test