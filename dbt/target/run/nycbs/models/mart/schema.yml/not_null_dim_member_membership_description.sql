select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select membership_description
from "test"."raw_mart"."dim_member"
where membership_description is null



      
    ) dbt_internal_test