select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

with all_values as (

    select
        pricing_tier as value_field,
        count(*) as n_records

    from "test"."raw_mart"."fact_tripdata"
    group by pricing_tier

)

select *
from all_values
where value_field not in (
    'standard','extended','premium'
)



      
    ) dbt_internal_test