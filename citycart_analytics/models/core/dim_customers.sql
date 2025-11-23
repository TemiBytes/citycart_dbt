{{
    config(
        materialized='table',
    )
}}

WITH source AS (
    SELECT 
        *
    FROM
        {{ ref('stg_customers')}}
),

joined_city AS (
    SELECT
        c.customer_id,
        c.email,
        c.first_name,
        c.last_name,
        c.phone_number,
        c.signup_date,
        c.signup_channel,
        c.birth_date,
        c.gender,
        c.is_premium,
        c.deleted_at,
        dc.city_key,
        dc.city,
        dc.country
    FROM 
        source c
    LEFT JOIN 
        {{ ref('dim_city')}} dc 
    ON 
        c.city = dc.city
    AND 
        c.country = dc.country
),

final AS (
    SELECT 
        customer_id,
        email,
        first_name,
        last_name,
        phone_number,
        signup_date,
        signup_channel,
        birth_date,
        gender,
        is_premium,
        deleted_at,
        city_key,
        city,
        country
    FROM 
        joined_city
)

SELECT * FROM final