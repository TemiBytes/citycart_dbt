{{
    config(
        materialized = 'table'
    )
}}

WITH enriched AS (
    SELECT 
        *
    FROM 
        {{ ref('int_order_items_enriched')}}
),

final AS (
    SELECT 
        order_item_id,
        order_id,
        product_id,
        quantity,
        unit_price,
        line_subtotal,
        line_discount,
        line_total,
        line_created_at,
        category,
        sub_category,
        brand,
        unit_of_measure
    FROM 
        enriched
)

SELECT * FROM final