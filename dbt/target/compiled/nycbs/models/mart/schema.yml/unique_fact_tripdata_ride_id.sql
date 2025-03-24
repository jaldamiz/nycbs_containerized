
    
    

select
    ride_id as unique_field,
    count(*) as n_records

from "test"."raw_mart"."fact_tripdata"
where ride_id is not null
group by ride_id
having count(*) > 1


