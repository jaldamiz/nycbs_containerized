select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select total_arrivals
from "test"."raw"."station_analysis"
where total_arrivals is null



      
    ) dbt_internal_test