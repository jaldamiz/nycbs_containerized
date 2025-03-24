{{
    config(
        materialized="table",
        version = "1.0.0",
        latest_version = true,
        owner = "Juan Aldamiz"
    )
}}

/*
@owner: Juan Aldamiz
@version: 1.0.0
@description: Date dimension for trip start dates with calendar attributes and business logic
*/

with date_spine as (
    select * from {{ ref('date') }}
),

final as (
    select
        DATE_KEY as date_key,
        DATE_KEY as date_day,
        
        -- Standard date parts
        extract('year' from DATE_KEY) as year,
        extract('month' from DATE_KEY) as month_number,
        extract('day' from DATE_KEY) as day_of_month,
        
        -- Month name
        MONTH_DESC as month_name,
        MONTH_SHORT_DESC as month_short_name,
        
        -- Day of week
        DAY_OF_WEEK as day_of_week,
        WEEK_DAY_DESC as day_name,
        WEEK_DAY_SHORT_DESC as day_short_name,
        
        -- Week information
        WEEK_OF_YEAR as week_number,
        FIRST_DAY_OF_WEEK as week_start_date,
        LAST_DAY_OF_WEEK as week_end_date,
        
        -- Quarter information
        QUARTER_OF_YEAR as quarter_number,
        QUARTER_SHORT_DESC as quarter_name,
        
        -- Season (Northern hemisphere)
        case
            when extract('month' from DATE_KEY) in (12, 1, 2) then 'Winter'
            when extract('month' from DATE_KEY) in (3, 4, 5) then 'Spring'
            when extract('month' from DATE_KEY) in (6, 7, 8) then 'Summer'
            when extract('month' from DATE_KEY) in (9, 10, 11) then 'Fall'
        end as season,
        
        -- Holiday flags
        IS_HOLIDAY as is_holiday,
        
        -- Weekend flag
        case when extract('dow' from DATE_KEY) in (0, 6) then true else false end as is_weekend,
        
        -- Time period flags
        case when extract('month' from DATE_KEY) in (5, 6, 7, 8, 9) then true else false end as is_peak_season,
        
        case when extract('month' from DATE_KEY) between 4 and 10 then true else false end as is_cycling_season,
        
        -- Fiscal periods (example - fiscal year starting in October)
        case 
            when extract('month' from DATE_KEY) >= 10 then extract('year' from DATE_KEY) + 1
            else extract('year' from DATE_KEY)
        end as fiscal_year
    from date_spine
)

select * from final