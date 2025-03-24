select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select rideable_type
from "test"."raw_raw"."bike_type"
where rideable_type is null



      
    ) dbt_internal_test