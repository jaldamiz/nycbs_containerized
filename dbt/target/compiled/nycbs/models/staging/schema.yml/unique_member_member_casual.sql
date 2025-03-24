
    
    

select
    member_casual as unique_field,
    count(*) as n_records

from "test"."raw_raw"."member"
where member_casual is not null
group by member_casual
having count(*) > 1


