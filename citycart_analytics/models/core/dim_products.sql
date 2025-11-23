{{
    config(
        materialized = 'table'
    )
}}

WITH source AS (
    SELECT 
        *
    FROM 
        {{ ref('stg_products')}}
),

final AS (
    SELECT
        product_id,
        product_sku,
        product_name,
        category,
        sub_category,
        brand,
        unit_of_measure,
        standard_price,
        cost_price,
        is_active,
        created_at,
        updated_at
    from source
)

SELECT * FROM final

