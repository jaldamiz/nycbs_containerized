
    
    

select
    station_id as unique_field,
    count(*) as n_records

from "test"."raw_mart"."dim_station"
where station_id is not null
group by station_id
having count(*) > 1


