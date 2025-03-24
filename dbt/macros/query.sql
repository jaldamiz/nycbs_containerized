{% macro query(sql) %}

{{ log('Running query: ' ~ sql, info=True) }}
{% set results = run_query(sql) %}
{% do results.print_table() %}

{% endmacro %} 