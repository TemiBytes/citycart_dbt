{{ config(materialized='view') }}

WITH source AS (
        SELECT * FROM {{ source('raw_app', 'orders') }}
),

renamed AS (
    SELECT
        order_id,
        customer_id,
        order_datetime,
        order_status,
        payment_method,
        UPPER(city) AS city,
        UPPER(country) AS country,
        device_type,
        NULLIF(promo_code, '') AS promo_code,
        subtotal_amount,
        discount_amount,
        delivery_fee,
        tip_amount,
        total_amount,
        currency,
        created_at,
        updated_at
    FROM source
    WHERE order_id IS NOT NULL
)

SELECT * FROM renamed