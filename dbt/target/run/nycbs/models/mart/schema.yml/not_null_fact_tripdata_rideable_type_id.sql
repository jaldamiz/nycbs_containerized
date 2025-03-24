select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select rideable_type_id
from "test"."raw_mart"."fact_tripdata"
where rideable_type_id is null



      
    ) dbt_internal_test