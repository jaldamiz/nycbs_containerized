select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select end_date_id
from "test"."raw_mart"."fact_tripdata"
where end_date_id is null



      
    ) dbt_internal_test