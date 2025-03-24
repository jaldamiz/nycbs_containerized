
  
    
    

    create  table
      "test"."raw_raw"."end_station__dbt_tmp"
  
    as (
      with 

source as (

    select * from "test"."raw_raw"."tripdata_ext"

),

renamed as (

    select
        source.end_station_name,
        source.end_station_id,
        source.end_lat,
        source.end_lng

    from source

)

select * from renamed
    );
  
  