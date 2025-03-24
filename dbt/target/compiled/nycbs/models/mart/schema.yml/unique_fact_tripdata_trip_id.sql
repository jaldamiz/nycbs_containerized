
    
    

select
    trip_id as unique_field,
    count(*) as n_records

from "test"."raw_mart"."fact_tripdata"
where trip_id is not null
group by trip_id
having count(*) > 1


