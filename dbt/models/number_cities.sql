{{ config(materialized='table') }}

SELECT
    COUNT(city) AS number_cities,
    country
FROM {{ source('public', 'places') }}
GROUP BY country
