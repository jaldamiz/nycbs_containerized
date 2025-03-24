select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        test_result as value_field,
        count(*) as n_records

    from "test"."raw"."test_station_metrics"
    group by test_result

)

select *
from all_values
where value_field not in (
    'PASS','FAIL'
)



      
    ) dbt_internal_test