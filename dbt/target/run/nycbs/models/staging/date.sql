
  
    
    

    create  table
      "test"."raw_raw"."date__dbt_tmp"
  
    as (
      

WITH DATE_SPINE AS
(






with rawdata as (

    

    

    with p as (
        select 0 as generated_number union all select 1
    ), unioned as (

    select

    
    p0.generated_number * power(2, 0)
     + 
    
    p1.generated_number * power(2, 1)
     + 
    
    p2.generated_number * power(2, 2)
     + 
    
    p3.generated_number * power(2, 3)
     + 
    
    p4.generated_number * power(2, 4)
     + 
    
    p5.generated_number * power(2, 5)
     + 
    
    p6.generated_number * power(2, 6)
     + 
    
    p7.generated_number * power(2, 7)
     + 
    
    p8.generated_number * power(2, 8)
     + 
    
    p9.generated_number * power(2, 9)
     + 
    
    p10.generated_number * power(2, 10)
     + 
    
    p11.generated_number * power(2, 11)
     + 
    
    p12.generated_number * power(2, 12)
    
    
    + 1
    as generated_number

    from

    
    p as p0
     cross join 
    
    p as p1
     cross join 
    
    p as p2
     cross join 
    
    p as p3
     cross join 
    
    p as p4
     cross join 
    
    p as p5
     cross join 
    
    p as p6
     cross join 
    
    p as p7
     cross join 
    
    p as p8
     cross join 
    
    p as p9
     cross join 
    
    p as p10
     cross join 
    
    p as p11
     cross join 
    
    p as p12
    
    

    )

    select *
    from unioned
    where generated_number <= 5112
    order by generated_number



),

all_periods as (

    select (
        

    date_add(cast('2018-01-01' as date), interval (row_number() over (order by 1) - 1) day)


    ) as date_day
    from rawdata

),

filtered as (

    select *
    from all_periods
    where date_day <= cast(concat(cast(extract('year' from current_date) + 6 as varchar), '-12-31') as date)

)

select * from filtered


)
SELECT
CAST(DATE_DAY AS DATE) AS DATE_KEY
,CAST(DAYOFYEAR(DATE_KEY) AS INT) AS DAY_OF_YEAR
,CAST(CASE 
    WHEN RIGHT(EXTRACT('day' FROM DATE_KEY)::varchar, 1) = '1' THEN 'st'
    WHEN RIGHT(EXTRACT('day' FROM DATE_KEY)::varchar, 1) = '2' THEN 'nd'
    WHEN RIGHT(EXTRACT('day' FROM DATE_KEY)::varchar, 1) = '3' THEN 'rd'
    ELSE 'th'
  END AS VARCHAR(2)) AS DAY_SUFFIX
,CAST(YEAR(DATE_KEY) || RIGHT('0' || WEEK(DATE_KEY), 2) AS INT) AS WEEK_KEY
,CAST(WEEKOFYEAR(DATE_KEY) AS INT) AS WEEK_OF_YEAR
,CAST(DAYOFWEEK(DATE_KEY) AS INT) AS DAY_OF_WEEK
,CAST(DAYNAME(DATE_KEY) AS VARCHAR(5)) AS WEEK_DAY_SHORT_DESC
,CAST(CASE 
    WHEN EXTRACT('dow' FROM DATE_KEY) = 0 THEN 'Sunday'
    WHEN EXTRACT('dow' FROM DATE_KEY) = 1 THEN 'Monday'
    WHEN EXTRACT('dow' FROM DATE_KEY) = 2 THEN 'Tuesday'
    WHEN EXTRACT('dow' FROM DATE_KEY) = 3 THEN 'Wednesday'
    WHEN EXTRACT('dow' FROM DATE_KEY) = 4 THEN 'Thursday'
    WHEN EXTRACT('dow' FROM DATE_KEY) = 5 THEN 'Friday'
    WHEN EXTRACT('dow' FROM DATE_KEY) = 6 THEN 'Saturday'
  END AS VARCHAR(9)) AS WEEK_DAY_DESC
,CAST(DATE_TRUNC('week', DATE_KEY) AS DATE) AS FIRST_DAY_OF_WEEK
,CAST(DATE_TRUNC('week', DATE_KEY) + INTERVAL '6 days' AS DATE) AS LAST_DAY_OF_WEEK
,CAST(YEAR(DATE_KEY) || RIGHT('0' || MONTH(DATE_KEY), 2) AS INT) AS MONTH_KEY
,CAST(MONTH(DATE_KEY) AS INT) AS MONTH_OF_YEAR
,CAST(DAY(DATE_KEY) AS INT) AS DAY_OF_MONTH
,CAST(MONTHNAME(DATE_KEY) AS VARCHAR(5)) AS MONTH_SHORT_DESC
,CAST(MONTHNAME(DATE_KEY) AS VARCHAR(50)) AS MONTH_DESC
,CAST(DATE_TRUNC('month', DATE_KEY) AS DATE) AS FIRST_DAY_OF_MONTH
,CAST(LAST_DAY(DATE_KEY) AS DATE) AS LAST_DAY_OF_MONTH
,CAST(YEAR(DATE_KEY) || QUARTER(DATE_KEY) AS INT) AS QUARTER_KEY
,CAST(QUARTER(DATE_KEY) AS INT) AS QUARTER_OF_YEAR
,CAST(DATE_KEY - DATE_TRUNC('quarter', DATE_KEY) + 1 AS INT) AS DAY_OF_QUARTER
,CAST('Q' || QUARTER_OF_YEAR AS VARCHAR(5)) AS QUARTER_SHORT_DESC
,CAST('Quarter ' || QUARTER_OF_YEAR AS VARCHAR(50)) AS QUARTER_DESC
,CAST(DATE_TRUNC('quarter', DATE_KEY) AS DATE) AS FIRST_DAY_OF_QUARTER
,CAST(DATE_TRUNC('quarter', DATE_KEY) + INTERVAL '3 months' - INTERVAL '1 day' AS DATE) AS LAST_DAY_OF_QUARTER
,CAST(YEAR(DATE_KEY) AS INT) AS YEAR_KEY
,CAST(DATE_TRUNC('year', DATE_KEY) AS DATE) AS FIRST_DAY_OF_YEAR
,CAST(DATE_TRUNC('year', DATE_KEY) + INTERVAL '1 year' - INTERVAL '1 day' AS DATE) AS LAST_DAY_OF_YEAR
,CAST(ROW_NUMBER() OVER (PARTITION BY YEAR(DATE_KEY), MONTH(DATE_KEY), DAYOFWEEK(DATE_KEY) ORDER BY DATE_KEY) AS INT) AS ORDINAL_WEEKDAY_OF_MONTH
,CAST(CASE
WHEN MONTH(DATE_KEY) = 1 AND DAY(DATE_KEY) = 1
THEN 'New Year''s Day'
WHEN MONTH(DATE_KEY) = 1 AND DAY(DATE_KEY) = 20 AND ((YEAR(DATE_KEY) - 1) % 4) = 0
THEN 'Inauguration Day'
WHEN MONTH(DATE_KEY) = 1 AND DAYOFWEEK(DATE_KEY) = 1 AND ORDINAL_WEEKDAY_OF_MONTH = 3
THEN 'Martin Luther King Jr Day'
WHEN MONTH(DATE_KEY) = 2 AND DAY(DATE_KEY) = 14
THEN 'Valentine''s Day'
WHEN MONTH(DATE_KEY) = 2 AND DAYOFWEEK(DATE_KEY) = 1 AND ORDINAL_WEEKDAY_OF_MONTH = 3
THEN 'President''s Day'
WHEN MONTH(DATE_KEY) = 3 AND DAY(DATE_KEY) = 17
THEN 'Saint Patrick''s Day'
WHEN MONTH(DATE_KEY) = 5 AND DAYOFWEEK(DATE_KEY) = 0 AND ORDINAL_WEEKDAY_OF_MONTH = 2
THEN 'Mother''s Day'
WHEN MONTH(DATE_KEY) = 5 AND DAYOFWEEK(DATE_KEY) = 1
AND LAST_VALUE(DAY(DATE_KEY)) OVER (PARTITION BY MONTH_KEY
ORDER BY DATE_KEY) - 7 <= DAY(DATE_KEY)
THEN 'Memorial Day'
WHEN MONTH(DATE_KEY) = 6 AND DAYOFWEEK(DATE_KEY) = 0 AND ORDINAL_WEEKDAY_OF_MONTH = 3
THEN 'Father''s Day'
WHEN MONTH(DATE_KEY) = 7 AND DAY(DATE_KEY) = 4
THEN 'Independence Day'
WHEN MONTH(DATE_KEY) = 9 AND DAYOFWEEK(DATE_KEY) = 1 AND ORDINAL_WEEKDAY_OF_MONTH = 1
THEN 'Labor Day'
WHEN MONTH(DATE_KEY) = 10 AND DAYOFWEEK(DATE_KEY) = 1 AND ORDINAL_WEEKDAY_OF_MONTH = 2
THEN 'Columbus Day'
WHEN MONTH(DATE_KEY) = 10 AND DAY(DATE_KEY) = 31
THEN 'Halloween'
WHEN MONTH(DATE_KEY) = 11 AND DAYOFWEEK(DATE_KEY) = 4 AND ORDINAL_WEEKDAY_OF_MONTH = 4
THEN 'Thanksgiving Day'
WHEN MONTH(DATE_KEY) = 12 AND DAY(DATE_KEY) = 25
THEN 'Christmas Day'
WHEN MONTH(DATE_KEY) = 12 AND DAY(DATE_KEY) = 26
THEN 'Boxing Day'
ELSE NULL
END AS VARCHAR(50)) AS HOLIDAY_DESC
,CAST(CASE WHEN HOLIDAY_DESC IS NULL THEN 0 ELSE 1 END AS BOOLEAN) AS IS_HOLIDAY
FROM DATE_SPINE
    );
  
  