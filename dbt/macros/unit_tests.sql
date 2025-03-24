{% macro test_model_aggregate_equality(model, model_reference, group_by_columns, aggregate_column, aggregate_method='sum') %}

-- Test if aggregations in a model match expected values
with actual as (
    select
        {{ group_by_columns | join(', ') }},
        {{ aggregate_method }}({{ aggregate_column }}) as actual_value
    from {{ model }}
    group by {{ group_by_columns | join(', ') }}
),

expected as (
    select
        {{ group_by_columns | join(', ') }},
        {{ aggregate_method }}({{ aggregate_column }}) as expected_value
    from {{ ref(model_reference) }}
    group by {{ group_by_columns | join(', ') }}
),

validation_errors as (
    select
        a.actual_value,
        e.expected_value
    from actual a
    inner join expected e on 
    {% for column in group_by_columns %}
        a.{{ column }} = e.{{ column }}
        {% if not loop.last %} and {% endif %}
    {% endfor %}
    where a.actual_value != e.expected_value
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_model_full_equality(model, model_reference) %}

-- Test if a model matches an expected model exactly
with actual as (
    select * from {{ model }}
    except
    select * from {{ ref(model_reference) }}
),

expected as (
    select * from {{ ref(model_reference) }}
    except
    select * from {{ model }}
),

all_errors as (
    select * from actual
    union all
    select * from expected
)

select count(*) from all_errors

{% endmacro %}

{% macro test_model_row_count_equality(model, model_reference) %}

-- Test if the row count of a model matches an expected model
with actual as (
    select count(*) as row_count from {{ model }}
),

expected as (
    select count(*) as row_count from {{ ref(model_reference) }}
),

validation_errors as (
    select 
        a.row_count as actual_row_count,
        e.row_count as expected_row_count
    from actual a
    cross join expected e
    where a.row_count != e.row_count
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_model_column_equality(model, model_reference, column_name) %}

-- Test if a specific column in a model matches an expected model
with actual as (
    select {{ column_name }} from {{ model }}
    except
    select {{ column_name }} from {{ ref(model_reference) }}
),

expected as (
    select {{ column_name }} from {{ ref(model_reference) }}
    except
    select {{ column_name }} from {{ model }}
),

all_errors as (
    select * from actual
    union all
    select * from expected
)

select count(*) from all_errors

{% endmacro %}

{% macro test_model_referential_integrity(child_model, child_column, parent_model, parent_column) %}

-- Test referential integrity between models
with child_data as (
    select distinct {{ child_column }} as child_key
    from {{ child_model }}
    where {{ child_column }} is not null
),

parent_data as (
    select distinct {{ parent_column }} as parent_key
    from {{ parent_model }}
),

validation_errors as (
    select child_key
    from child_data
    where child_key not in (select parent_key from parent_data)
)

select count(*) from validation_errors

{% endmacro %}

{% macro test_model_expected_result(model, seed_file, comparison_columns, metrics_columns=none, tolerance=0.1) %}

{% if not metrics_columns %}
  {% set metrics_columns = comparison_columns %}
{% endif %}

with actual as (
    select 
        {% for col in comparison_columns %}
        {{ col }},
        {% endfor %}
        {% for col in metrics_columns %}
        {{ col }} as actual_{{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from {{ model }}
),

expected as (
    select 
        {% for col in comparison_columns %}
        {{ col }},
        {% endfor %}
        {% for col in metrics_columns %}
        {{ col }} as expected_{{ col }}{% if not loop.last %},{% endif %}
        {% endfor %}
    from {{ ref(seed_file) }}
),

compared as (
    select
        a.*,
        {% for col in metrics_columns %}
        e.expected_{{ col }},
        abs(a.actual_{{ col }} - e.expected_{{ col }}) as {{ col }}_diff,
        case
            when a.actual_{{ col }} = 0 and e.expected_{{ col }} = 0 then 0
            when e.expected_{{ col }} = 0 then 1.0
            else abs(a.actual_{{ col }} - e.expected_{{ col }}) / e.expected_{{ col }}
        end as {{ col }}_pct_diff{% if not loop.last %},{% endif %}
        {% endfor %}
    from actual a
    join expected e on
        {% for col in comparison_columns %}
        a.{{ col }} = e.{{ col }}{% if not loop.last %} and {% endif %}
        {% endfor %}
),

validation_errors as (
    select *
    from compared
    where 
        {% for col in metrics_columns %}
        {{ col }}_pct_diff > {{ tolerance }}{% if not loop.last %} or {% endif %}
        {% endfor %}
)

select count(*) from validation_errors

{% endmacro %} 