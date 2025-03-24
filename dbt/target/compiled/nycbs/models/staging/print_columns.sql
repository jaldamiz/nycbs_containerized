

-- Generate a list of all column names in tripdata_ext
with cols as (
  SELECT 
    column_name 
  FROM duckdb_columns()
  WHERE 
    table_name = 'tripdata_ext' 
    AND schema_name = 'raw'
)

SELECT 
  column_name,
  row_number() over () as position
FROM cols
ORDER BY position