
  
    
    

    create  table
      "test"."raw_raw"."debug_schema__dbt_tmp"
  
    as (
      -- This is a debug script to be run manually with duckdb CLI
-- It will show the column names from the delta table

with delta_data as (
    select * from '/Users/aldam/git/nycbs_containerized/dbt/data/bronze/rides_nyc/col-b9bb1351-dcb9-46c3-958c-e6c8aefc083f=2024/*/*.parquet' limit 1
)

select 
    column_name
from information_schema.columns 
where table_name = 'delta_data'
order by ordinal_position
    );
  
  