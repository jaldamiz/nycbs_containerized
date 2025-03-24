select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select ended_at
from "test"."raw_raw"."tripdata"
where ended_at is null



      
    ) dbt_internal_test