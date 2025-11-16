{{ config(materialized = 'view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_app', 'customers') }}
),

renamed AS (
    SELECT 
        customer_id,
        LOWER(email) AS email,
        first_name,
        last_name,
        phone_number,
        signup_date,
        signup_channel,
        UPPER(city) AS city,
        UPPER(country) AS country,
        birth_date,
        gender,
        CAST(is_premium AS BOOLEAN) AS is_premium,
        deleted_at
    FROM source 
    WHERE customer_id IS NOT NULL
)
SELECT * FROM renamed