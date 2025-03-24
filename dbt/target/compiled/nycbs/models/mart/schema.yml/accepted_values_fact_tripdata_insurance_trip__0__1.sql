
    
    

with all_values as (

    select
        insurance_trip as value_field,
        count(*) as n_records

    from "test"."raw_mart"."fact_tripdata"
    group by insurance_trip

)

select *
from all_values
where value_field not in (
    '0','1'
)


