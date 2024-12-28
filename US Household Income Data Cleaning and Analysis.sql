-- Data Cleaning
-- Query to retrieve all records from the household income table
SELECT *
FROM us_project.us_household_income;

-- Query to retrieve all records from the household income statistics table
SELECT * 
FROM us_project.us_household_income_statistics;

-- Alter table to rename a column in household income statistics
ALTER TABLE us_household_income_statistics
RENAME COLUMN ï»¿id TO id;

-- Query to find duplicate IDs in the household income table
SELECT id, COUNT(id)
FROM us_household_income
GROUP BY id
HAVING COUNT(id) > 1;

-- Delete duplicate rows based on row number
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
);

-- Retrieve distinct state names in the household income table
SELECT DISTINCT State_Name 
FROM us_household_income
ORDER BY State_Name;

-- Update state names to have consistent capitalization
UPDATE us_household_income
SET State_Name = 'Alabama'
WHERE State_Name = 'alabama';

-- Query to count occurrences of each type in the household income table
SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type;

-- Update type names for consistency
UPDATE us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

-- Summarize total land and water area by state and retrieve the top 10 by land area
SELECT State_Name, SUM(ALand) AS Total_Land, SUM(AWater) AS Total_Water
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY Total_Land DESC
LIMIT 10;

-- Summarize total land and water area by state and retrieve the top 10 by water area
SELECT State_Name, SUM(ALand) AS Total_Land, SUM(AWater) AS Total_Water
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY Total_Water DESC
LIMIT 10;

-- Join household income and statistics tables and retrieve non-zero mean records
SELECT *
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0;

-- Retrieve detailed records of household income with specific columns and non-zero mean
SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0;

-- Calculate average mean and median by state and retrieve the top 10 states by average mean
SELECT u.State_Name, ROUND(AVG(Mean), 1) AS Avg_Mean, ROUND(AVG(Median), 1) AS Avg_Median
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
GROUP BY State_Name
ORDER BY Avg_Mean DESC
LIMIT 10;

-- Summarize type count and average mean and median by type, retrieving the top 10 by average mean
SELECT Type, COUNT(Type) AS Type_Count, ROUND(AVG(Mean), 1) AS Avg_Mean, ROUND(AVG(Median), 1) AS Avg_Median
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 1
ORDER BY Avg_Mean DESC
LIMIT 10;

-- Calculate average mean and median by city within each state and order by average mean
SELECT u.State_Name, City, ROUND(AVG(Mean), 1) AS Avg_Mean, ROUND(AVG(Median), 1) AS Avg_Median
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
GROUP BY u.State_Name, City
ORDER BY Avg_Mean DESC;
