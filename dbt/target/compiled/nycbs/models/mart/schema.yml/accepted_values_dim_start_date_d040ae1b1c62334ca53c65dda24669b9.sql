
    
    

with all_values as (

    select
        season as value_field,
        count(*) as n_records

    from "test"."raw_mart"."dim_start_date"
    group by season

)

select *
from all_values
where value_field not in (
    'Winter','Spring','Summer','Fall'
)


