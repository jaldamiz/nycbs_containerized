
    
    

with all_values as (

    select
        test_result as value_field,
        count(*) as n_records

    from "test"."raw"."test_expected_metrics"
    group by test_result

)

select *
from all_values
where value_field not in (
    'PASS','FAIL'
)


