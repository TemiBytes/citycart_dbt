{{ config(materialized = 'view')}}

WITH source AS (
    SELECT * FROM {{ source('raw_app', 'products') }}
),

renamed AS (
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
        CAST(is_active AS BOOLEAN) AS is_active,
        created_at,
        updated_at
    FROM source
    WHERE product_id IS NOT NULL
)

SELECT * FROM renamed