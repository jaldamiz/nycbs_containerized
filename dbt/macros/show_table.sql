{% macro show_table(table_name, schema_name='raw_raw') %}

    {% set query %}
        SELECT * FROM {{ schema_name }}.{{ table_name }}
    {% endset %}
    
    {% set results = run_query(query) %}
    
    {% if execute %}
        {% for row in results.rows %}
            {{ log(row, info=true) }}
        {% endfor %}
    {% endif %}

{% endmacro %} 