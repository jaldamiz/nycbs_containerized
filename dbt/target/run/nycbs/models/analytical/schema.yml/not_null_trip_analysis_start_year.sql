select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select start_year
from "test"."raw"."trip_analysis"
where start_year is null



      
    ) dbt_internal_test