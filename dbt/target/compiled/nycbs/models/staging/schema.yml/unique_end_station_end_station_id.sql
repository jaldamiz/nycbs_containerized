
    
    

select
    end_station_id as unique_field,
    count(*) as n_records

from "test"."raw_raw"."end_station"
where end_station_id is not null
group by end_station_id
having count(*) > 1


