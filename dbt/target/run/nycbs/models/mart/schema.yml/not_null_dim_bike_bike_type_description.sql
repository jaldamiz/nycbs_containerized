select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select bike_type_description
from "test"."raw_mart"."dim_bike"
where bike_type_description is null



      
    ) dbt_internal_test