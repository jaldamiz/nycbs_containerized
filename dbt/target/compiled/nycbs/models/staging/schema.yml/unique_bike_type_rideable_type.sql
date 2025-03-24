
    
    

select
    rideable_type as unique_field,
    count(*) as n_records

from "test"."raw_raw"."bike_type"
where rideable_type is not null
group by rideable_type
having count(*) > 1


