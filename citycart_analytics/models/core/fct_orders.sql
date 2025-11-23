{{
    config(
        materialized = 'table',
        unique_key = 'order_id',
        on_schema_change = 'sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_orders')}}
),

joined_customers AS (
    SELECT 
        o.order_id,
        o.customer_id,
        o.order_datetime,
        o.order_status,
        o.payment_method,
        o.city,
        o.country, 
        o.device_type,
        o.promo_code,
        o.subtotal_amount,
        o.discount_amount,
        o.delivery_fee,
        o.tip_amount,
        o.total_amount,
        o.currency,
        o.created_at,
        o.updated_at,
        dc.city_key,
        dcust.is_premium
    FROM 
        source o 
    LEFT JOIN 
        {{ ref('dim_city')}} dc
    ON 
        o.city = dc.city
    AND
        o.country = dc.country
    LEFT JOIN
        {{ ref('dim_customers')}} dcust
    ON 
        o.customer_id = dcust.customer_id
),

-- Incremental Filter:
-- for incremental runs (after first full run), only process new/updated orders

filtered AS (
    SELECT 
        *
    FROM 
        joined_customers
    {% if is_incremental() %}
    WHERE 
        order_datetime > (SELECT COALESCE(MAX(order_datetime), '1900-01-01'::timestamp) FROM {{ this }})
    {% endif %}
)

SELECT * FROM filtered

