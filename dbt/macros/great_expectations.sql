{% macro test_expect_column_values_to_be_in_set(model, column_name, value_set) %}

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
    and column_value not in ({{ value_set | join("','") | replace("'PASS'", "'PASS'") | replace("'FAIL'", "'FAIL'") }})
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_values_to_not_be_null(model, column_name) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_values_to_be_between(model, column_name, min_value, max_value, strictly=false) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where 
    {% if strictly %}
        column_value <= {{ min_value }} or column_value >= {{ max_value }}
    {% else %}
        column_value < {{ min_value }} or column_value > {{ max_value }}
    {% endif %}
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_values_to_be_unique(model, column_name) %}

with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value,
        count(*) as occurrences
    from validation
    group by column_value
    having count(*) > 1
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_values_to_match_regex(model, column_name, regex) %}

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
    and regexp_matches(cast(column_value as varchar), '{{ regex }}') = false
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_values_to_be_of_type(model, column_name, type_name) %}

-- Note: This test is limited by DuckDB's capabilities
-- It checks if values can be cast to the expected type without error
with validation as (
    select
        {{ column_name }} as column_value
    from {{ model }}
),

validation_errors as (
    select
        column_value
    from validation
    where
    {% if type_name in ['int', 'integer', 'bigint'] %}
        try_cast(column_value as {{ type_name }}) is null and column_value is not null
    {% elif type_name in ['float', 'double', 'real', 'numeric'] %}
        try_cast(column_value as {{ type_name }}) is null and column_value is not null
    {% elif type_name in ['date', 'timestamp', 'datetime'] %}
        try_cast(column_value as {{ type_name }}) is null and column_value is not null
    {% elif type_name in ['varchar', 'string', 'text'] %}
        try_cast(column_value as {{ type_name }}) is null and column_value is not null
    {% elif type_name in ['boolean', 'bool'] %}
        try_cast(column_value as {{ type_name }}) is null and column_value is not null
    {% else %}
        -- Default case: use direct type check
        typeof(column_value) != '{{ type_name }}'
    {% endif %}
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_pair_values_to_be_equal(model, column_a=none, column_b=none, column_name=none) %}

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
    where column_a_value != column_b_value
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_sum_to_be_between(model, column_name, min_sum, max_sum) %}

with validation as (
    select
        sum({{ column_name }}) as column_sum
    from {{ model }}
),

validation_errors as (
    select
        column_sum
    from validation
    where column_sum < {{ min_sum }} or column_sum > {{ max_sum }}
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_mean_to_be_between(model, column_name, min_mean, max_mean) %}

with validation as (
    select
        avg({{ column_name }}) as column_mean
    from {{ model }}
),

validation_errors as (
    select
        column_mean
    from validation
    where column_mean < {{ min_mean }} or column_mean > {{ max_mean }}
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_values_to_be_increasing(model, column_name, sort_column=none) %}

{% if sort_column is none %}
    {% set sort_column = column_name %}
{% endif %}

with ordered_data as (
    select
        {{ column_name }} as column_value,
        lag({{ column_name }}) over (order by {{ sort_column }}) as prev_value
    from {{ model }}
),

validation_errors as (
    select
        column_value,
        prev_value
    from ordered_data
    where column_value <= prev_value
    and prev_value is not null
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_expect_column_values_to_be_decreasing(model, column_name, sort_column=none) %}

{% if sort_column is none %}
    {% set sort_column = column_name %}
{% endif %}

with ordered_data as (
    select
        {{ column_name }} as column_value,
        lag({{ column_name }}) over (order by {{ sort_column }}) as prev_value
    from {{ model }}
),

validation_errors as (
    select
        column_value,
        prev_value
    from ordered_data
    where column_value >= prev_value
    and prev_value is not null
)

select count(*) from validation_errors

{% endmacro %} 