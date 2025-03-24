with 

source as (

    select * from {{ ref('date') }}

),

renamed as (

    select
        {{ dbt_utils.generate_surrogate_key(['DATE_KEY']) }} as date_id,
        DATE_KEY,
        DAY_OF_YEAR,
        DAY_SUFFIX,
        WEEK_KEY,
        WEEK_OF_YEAR,
        DAY_OF_WEEK,
        WEEK_DAY_SHORT_DESC,
        WEEK_DAY_DESC,
        FIRST_DAY_OF_WEEK,
        LAST_DAY_OF_WEEK,
        MONTH_KEY,
        MONTH_OF_YEAR,
        DAY_OF_MONTH,
        MONTH_SHORT_DESC,
        MONTH_DESC,
        FIRST_DAY_OF_MONTH,
        LAST_DAY_OF_MONTH,
        QUARTER_KEY,
        QUARTER_OF_YEAR,
        DAY_OF_QUARTER,
        QUARTER_SHORT_DESC,
        QUARTER_DESC,
        FIRST_DAY_OF_QUARTER,
        LAST_DAY_OF_QUARTER,
        YEAR_KEY,
        FIRST_DAY_OF_YEAR,
        LAST_DAY_OF_YEAR,
        ORDINAL_WEEKDAY_OF_MONTH,
        HOLIDAY_DESC,
        IS_HOLIDAY BOOLEAN

    from source

)

select * from renamed