{{
    config(
        materialized = 'table'
    )
}}

with customers AS (
    SELECT 
        city,
        country
    FROM 
        {{ ref('stg_customers')}}
    WHERE 
        city IS NOT NULL 
    AND 
        country IS NOT NULL

),
deduped AS (
    SELECT DISTINCT
        city,
        country
    FROM 
        customers 
),
final AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['city', 'country']) }} AS city_key,
        city,
        country
    FROM 
        deduped
)

SELECT * FROM final