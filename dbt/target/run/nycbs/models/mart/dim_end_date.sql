
  
    
    
      
    

    create  table
      "test"."raw_mart"."dim_end_date__dbt_tmp"
  
  (
    date_key date,
    date_day date,
    year bigint,
    month_number bigint,
    day_of_month bigint,
    month_name varchar,
    month_short_name varchar,
    day_of_week integer,
    day_name varchar,
    day_short_name varchar,
    week_number integer,
    week_start_date date,
    week_end_date date,
    quarter_number integer,
    quarter_name varchar,
    season varchar,
    is_holiday boolean,
    is_weekend boolean,
    is_peak_season boolean,
    is_cycling_season boolean,
    fiscal_year bigint
    
    )
 ;
    insert into "test"."raw_mart"."dim_end_date__dbt_tmp" 
  (
    
      
      date_key ,
    
      
      date_day ,
    
      
      year ,
    
      
      month_number ,
    
      
      day_of_month ,
    
      
      month_name ,
    
      
      month_short_name ,
    
      
      day_of_week ,
    
      
      day_name ,
    
      
      day_short_name ,
    
      
      week_number ,
    
      
      week_start_date ,
    
      
      week_end_date ,
    
      
      quarter_number ,
    
      
      quarter_name ,
    
      
      season ,
    
      
      is_holiday ,
    
      
      is_weekend ,
    
      
      is_peak_season ,
    
      
      is_cycling_season ,
    
      
      fiscal_year 
    
  )
 (
      
    select date_key, date_day, year, month_number, day_of_month, month_name, month_short_name, day_of_week, day_name, day_short_name, week_number, week_start_date, week_end_date, quarter_number, quarter_name, season, is_holiday, is_weekend, is_peak_season, is_cycling_season, fiscal_year
    from (
        

with date_spine as (
    select * from "test"."raw_raw"."date"
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
    ) as model_subq
    );
  
  