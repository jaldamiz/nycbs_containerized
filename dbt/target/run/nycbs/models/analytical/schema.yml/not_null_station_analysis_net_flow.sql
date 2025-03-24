select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select net_flow
from "test"."raw"."station_analysis"
where net_flow is null



      
    ) dbt_internal_test