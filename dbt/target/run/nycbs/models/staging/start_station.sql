
  
    
    

    create  table
      "test"."raw_raw"."start_station__dbt_tmp"
  
    as (
      with 

source as (

    select * from "test"."raw_raw"."tripdata_ext"

),

renamed as (

    select
        source.start_station_name,
        source.start_station_id,
        source.start_lat,
        source.start_lng

    from source

)

select * from renamed
    );
  
  