{% macro test_positive_values(model, column_name) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null and column_value <= 0
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_value_between(model, column_name, max_value, min_value) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < cast('{{ min_value }}' as float) 
        or 
        cast(column_value as float) > cast('{{ max_value }}' as float)
    )
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_date_in_past(model, column_name) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value > CURRENT_DATE()
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_valid_percentage(model, column_name) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is not null 
    and (
        cast(column_value as float) < 0.0 
        or 
        cast(column_value as float) > 100.0
    )
    and column_value != 'PASS'
    and column_value != 'FAIL'
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_valid_email(model, column_name) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value NOT REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_valid_url(model, column_name) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value NOT REGEXP '^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$'
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_timestamp_range(model, column_name, min_date, max_date) %}

-- Convert 'current_timestamp()' text to an actual current_timestamp function call
{% if max_date == 'current_timestamp()' %}
    {% set max_date_value = "current_timestamp" %}
{% else %}
    {% set max_date_value = "'" ~ max_date ~ "'" %}
{% endif %}

{% if min_date == 'current_timestamp()' %}
    {% set min_date_value = "current_timestamp" %}
{% else %}
    {% set min_date_value = "'" ~ min_date ~ "'" %}
{% endif %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value < {{ min_date_value }} or column_value > {{ max_date_value }}
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_valid_geo_coordinates(model, lat_column, lng_column) %}

with validation as (
    select
        {{ lat_column }} as lat_value,
        {{ lng_column }} as lng_value
    from {{ model }}
),

validation_errors as (
    select
        lat_value,
        lng_value
    from validation
    where lat_value < -90 or lat_value > 90 or lng_value < -180 or lng_value > 180
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_accepted_pattern(model, column_name, pattern) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value NOT REGEXP '{{ pattern }}'
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_column_pair_greater_than(model, column_a=none, column_b=none, column_name=none) %}

{% if column_name is not none %}
    {% set column_a = column_name %}
{% endif %}

with validation as (
    select
        {{ column_a }} as column_a_value,
        {{ column_b }} as column_b_value
    from {{ model }}
),

validation_errors as (
    select
        column_a_value,
        column_b_value
    from validation
    where column_a_value <= column_b_value
)

select count(*) from validation_errors

{% endmacro %} 