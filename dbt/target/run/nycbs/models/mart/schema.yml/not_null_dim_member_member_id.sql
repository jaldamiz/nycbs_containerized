select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    



select member_id
from "test"."raw_mart"."dim_member"
where member_id is null



      
    ) dbt_internal_test