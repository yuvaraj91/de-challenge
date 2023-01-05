{{ config(materialized='table') }}

WITH
POPULATION AS (
    SELECT
        place_of_birth,
        count(1) AS pop_count
    FROM people
    GROUP BY place_of_birth
)
SELECT
    pl.country,
    sum(pop.pop_count) AS population_count
FROM places pl
LEFT JOIN POPULATION pop
    ON pl.city = pop.place_of_birth
GROUP BY pl.country
