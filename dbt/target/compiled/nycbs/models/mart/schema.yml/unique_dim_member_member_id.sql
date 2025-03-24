
    
    

select
    member_id as unique_field,
    count(*) as n_records

from "test"."raw_mart"."dim_member"
where member_id is not null
group by member_id
having count(*) > 1


