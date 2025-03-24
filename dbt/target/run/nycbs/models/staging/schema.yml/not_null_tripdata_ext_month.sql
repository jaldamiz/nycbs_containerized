select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select month
from "test"."raw_raw"."tripdata_ext"
where month is null



      
    ) dbt_internal_test