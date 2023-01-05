{{ config(materialized='table') }}

SELECT
    place_of_birth, AVG(date_part('year', AGE(date_of_birth)))
FROM
    people
GROUP BY place_of_birth
ORDER BY place_of_birth
