{% macro init_duckdb() %}

{% if target.type == 'duckdb' %}
    {{ log("Initializing DuckDB with Delta extension", info=True) }}
    
    {% set extensions_query %}
        -- Install and load Delta extension
        INSTALL delta;
        LOAD delta;
        
        -- Install and load a few more helpful extensions
        INSTALL httpfs;
        LOAD httpfs;
        
        -- List installed extensions for debug
        SELECT name FROM duckdb_extensions() WHERE loaded = true;
    {% endset %}
    
    {% do run_query(extensions_query) %}
{% endif %}

{% endmacro %}

-- Hook into dbt's run start to ensure Delta extension is loaded
{% macro on_run_start() %}
    {{ init_duckdb() }}
{% endmacro %} 