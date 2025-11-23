
WITH date_spine AS (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="to_date('2022-01-01')",
        end_date = "dateadd(day, 1, current_date())"
    )
    }}
),

final_date AS (
    SELECT 
        -- dbt_utils.date spine returns a column named "date_day"
        date_day as date_day,
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(MONTH FROM date_day) AS month,
        EXTRACT(DAY FROM date_day) AS day,

        TO_CHAR(date_day , 'YYYY-MMM-DD') AS date_ymd,
        TO_CHAR(date_day , 'YYYYMMDD') AS date_key,

        TO_CHAR(date_day, 'Day') AS day_name,
        EXTRACT(dow FROM date_day) AS day_of_week,
        EXTRACT(week FROM date_day) AS week_of_year,
        EXTRACT(quarter FROM date_day) AS quarter,

        CASE 
            WHEN EXTRACT(month FROM date_day) IN (1,2,3) THEN 'Q1'
            WHEN EXTRACT(month FROM date_day) IN (4,5,6) THEN 'Q2'
            WHEN EXTRACT(month FROM date_day) IN (7,8,9) THEN 'Q3'
        ELSE 'Q4' 
        END AS quarter_label,

        CASE 
            WHEN EXTRACT(dow FROM date_day) IN (0,6) THEN TRUE
        ELSE FALSE 
        END AS is_weekend
    FROM date_spine
)

SELECT * FROM final_date