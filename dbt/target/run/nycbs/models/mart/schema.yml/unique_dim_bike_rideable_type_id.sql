select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    rideable_type_id as unique_field,
    count(*) as n_records

from "test"."raw_mart"."dim_bike"
where rideable_type_id is not null
group by rideable_type_id
having count(*) > 1



      
    ) dbt_internal_test