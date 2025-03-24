select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    member_casual as unique_field,
    count(*) as n_records

from "test"."raw_raw"."member"
where member_casual is not null
group by member_casual
having count(*) > 1



      
    ) dbt_internal_test