select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select city
from "test"."raw_raw"."tripdata"
where city is null



      
    ) dbt_internal_test