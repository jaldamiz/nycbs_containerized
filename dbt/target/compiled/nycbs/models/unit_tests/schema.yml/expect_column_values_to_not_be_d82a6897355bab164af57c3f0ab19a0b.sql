

with validation as (
    select
        test_result as column_value
    from "test"."raw"."test_expected_metrics"
),

validation_errors as (
    select
        column_value
    from validation
    where column_value is null
)

select count(*) from validation_errors

