select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
    

select
    start_station_id as unique_field,
    count(*) as n_records

from "test"."raw_raw"."start_station"
where start_station_id is not null
group by start_station_id
having count(*) > 1



      
    ) dbt_internal_test