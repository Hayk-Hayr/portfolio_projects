SELECT *
FROM us_project.us_household_income
; -- Retrieve all records from the us_household_income table again

SELECT * 
FROM us_project.us_household_income_statistics;
-- Retrieve all records from the us_household_income_statistics table again

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;
-- Retrieve the top 10 states by total land area in descending order

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 3 DESC
LIMIT 10
;
-- Retrieve the top 10 states by total water area in descending order

SELECT *
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
;
-- Join household income data with statistics where the mean is non-zero

SELECT u.State_Name, County, Type, `Primary`, Mean, Median
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
;
-- Retrieve specific columns from joined tables for non-zero mean records

SELECT u.State_Name, ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
GROUP BY State_Name
ORDER BY 2 DESC
LIMIT 10
;
-- Retrieve the top 10 states by average mean income in descending order

SELECT Type, COUNT(Type), ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
GROUP BY Type
HAVING COUNT(Type) > 1
ORDER BY 3 DESC
LIMIT 10
;
-- Retrieve the top 10 types by average mean income in descending order

SELECT u.State_Name, City, ROUND(AVG(Mean), 1), ROUND(AVG(Median), 1)
FROM us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE mean <> 0
GROUP BY u.State_Name, City
ORDER BY ROUND(AVG(Mean), 1) DESC
;
-- Retrieve cities within states ordered by average mean income in descending order
