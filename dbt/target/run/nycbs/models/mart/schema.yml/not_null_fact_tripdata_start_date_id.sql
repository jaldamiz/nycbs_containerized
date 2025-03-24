select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select start_date_id
from "test"."raw_mart"."fact_tripdata"
where start_date_id is null



      
    ) dbt_internal_test