select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select rideable_type
from "test"."raw_raw"."tripdata_ext"
where rideable_type is null



      
    ) dbt_internal_test