{% macro get_table_schema(table_name) %}

    {% set query %}
        DESCRIBE {{ table_name }}
    {% endset %}
    
    {% do run_query(query) %}
    {% do log('Table schema retrieved for ' ~ table_name, info=true) %}

{% endmacro %} 