{% macro test_referential_integrity(model, column_name, to, field) %}

with parent as (
    select distinct {{ field }} as id
    from {{ to }}
),

child as (
    select distinct {{ column_name }} as id
    from {{ model }}
    where {{ column_name }} is not null
),

invalid_keys as (
    select id
    from child
    where id not in (select id from parent)
)

select count(*) from invalid_keys

{% endmacro %} 