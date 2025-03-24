
    
    

with all_values as (

    select
        rebalancing_need as value_field,
        count(*) as n_records

    from "test"."raw_raw"."station_analysis"
    group by rebalancing_need

)

select *
from all_values
where value_field not in (
    'High','Medium','Low','None'
)


