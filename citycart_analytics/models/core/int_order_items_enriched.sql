{{
    config(materialized = 'ephemeral')
}}

with items AS (
    SELECT 
        *
    FROM 
        {{ ref('stg_order_items')}}
),
joined_products AS (
    SELECT 
        i.order_item_id,
        i.order_id,
        i.product_id,
        i.quantity,
        i.unit_price,
        i.line_subtotal,
        i.line_discount,
        i.line_total,
        i.created_at AS line_created_at,
        p.category,
        p.sub_category,
        p.brand,
        p.unit_of_measure
    FROM 
        items i 
    LEFT JOIN 
        {{ ref('dim_products')}} p
    ON 
        i.product_id = p.product_id
)

SELECT * FROM joined_products