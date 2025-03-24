select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select start_date
from "test"."raw"."trip_analysis"
where start_date is null



      
    ) dbt_internal_test