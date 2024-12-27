SELECT *
FROM us_project.us_household_income;

SELECT * 
FROM us_project.us_household_income_statistics;

ALTER TABLE us_household_income_statistics
RENAME COLUMN ï»¿id TO id;
-- Rename the column ï»¿id to id to fix any encoding or formatting issues

SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;
-- Identify duplicate records based on the id column

DELETE FROM us_household_income
WHERE row_id IN
(
    SELECT row_id
    FROM
    (
        SELECT row_id, id,
               ROW_NUMBER() OVER(PARTITION BY id ORDER BY row_id) AS row_num
        FROM us_household_income
    ) AS Row_Table
    WHERE row_num > 1
)
;
-- Remove duplicate rows while keeping the first occurrence of each id

SELECT DISTINCT State_Name 
FROM us_household_income
ORDER BY State_Name;
-- Retrieve and order unique state names alphabetically

UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';
-- Standardize the state name formatting

SELECT DISTINCT State_Name 
FROM us_household_income
ORDER BY State_Name;
-- Confirm state name changes by retrieving unique state names again

SELECT * 
FROM us_household_income
WHERE County = 'Autauga County'
  AND City = 'Vinemont'
;
-- Retrieve records for a specific county and city

SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type;
-- Count the number of records for each type

UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';
-- Standardize the type values by consolidating similar entries

SELECT ALand, AWater
FROM us_project.us_household_income
WHERE AWater = 0
;
-- Retrieve records where the water area is zero
