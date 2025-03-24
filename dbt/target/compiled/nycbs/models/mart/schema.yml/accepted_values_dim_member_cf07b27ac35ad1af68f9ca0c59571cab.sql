
    
    

with all_values as (

    select
        membership_tier as value_field,
        count(*) as n_records

    from "test"."raw_mart"."dim_member"
    group by membership_tier

)

select *
from all_values
where value_field not in (
    'premium','basic','unknown'
)


