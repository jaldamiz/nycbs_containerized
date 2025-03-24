select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select station_name
from "test"."raw"."station_analysis"
where station_name is null



      
    ) dbt_internal_test