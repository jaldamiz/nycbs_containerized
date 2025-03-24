

-- Since our data doesn't contain actual bike types (the rideable_type field
-- actually contains member/casual information), we'll create some placeholder
-- bike types for our dimensional model

with bike_types as (
    select 
        'electric_bike' as rideable_type
    
    union all
    
    select 
        'classic_bike' as rideable_type
        
    union all
    
    select 
        'docked_bike' as rideable_type
)

select * from bike_types