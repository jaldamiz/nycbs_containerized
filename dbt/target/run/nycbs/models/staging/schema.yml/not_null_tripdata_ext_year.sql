select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select year
from "test"."raw_raw"."tripdata_ext"
where year is null



      
    ) dbt_internal_test