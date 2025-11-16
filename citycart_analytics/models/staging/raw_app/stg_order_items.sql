{{ config(materialized='view') }}

WITH source AS (
    SELECT * FROM {{ source('raw_app', 'order_items') }}
),

renamed AS (
    SELECT
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        line_subtotal,
        line_discount,
        line_total,
        created_at
    FROM source
    WHERE order_item_id IS NOT NULL
)

SELECT * FROM renamed