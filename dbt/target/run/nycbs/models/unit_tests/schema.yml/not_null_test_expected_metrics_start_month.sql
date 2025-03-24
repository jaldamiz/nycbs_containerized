select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select start_month
from "test"."raw"."test_expected_metrics"
where start_month is null



      
    ) dbt_internal_test