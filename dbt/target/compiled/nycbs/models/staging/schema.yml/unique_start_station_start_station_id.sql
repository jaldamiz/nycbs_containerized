
    
    

select
    start_station_id as unique_field,
    count(*) as n_records

from "test"."raw_raw"."start_station"
where start_station_id is not null
group by start_station_id
having count(*) > 1


