
    
    

select
    rideable_type_id as unique_field,
    count(*) as n_records

from "test"."raw_mart"."dim_bike"
where rideable_type_id is not null
group by rideable_type_id
having count(*) > 1


