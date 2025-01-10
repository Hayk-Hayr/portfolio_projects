-- Select all data from the world_life_expectancy table
SELECT *
FROM world_life_expectancy;

-- Identify duplicate records by Country and Year
SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_life_expectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year)) > 1;

-- Find duplicate rows and assign row numbers to identify them
SELECT *
FROM
(
    SELECT Row_ID,
           CONCAT(Country, Year) AS CountryYear,
           ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY Row_ID) AS Row_Num
    FROM world_life_expectancy
) AS Row_Table
WHERE Row_Num > 1;

-- Remove duplicate records based on Row_ID
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
    SELECT Row_ID
    FROM
    (
        SELECT Row_ID,
               CONCAT(Country, Year) AS CountryYear,
               ROW_NUMBER() OVER (PARTITION BY CONCAT(Country, Year) ORDER BY Row_ID) AS Row_Num
        FROM world_life_expectancy
    ) AS Row_Table
    WHERE Row_Num > 1
);

-- Identify records with missing status
SELECT *
FROM world_life_expectancy
WHERE Status = '';

-- Find distinct status values that are not empty
SELECT DISTINCT Status
FROM world_life_expectancy
WHERE Status <> '';

-- Identify countries with a 'Developing' status
SELECT DISTINCT Country
FROM world_life_expectancy
WHERE Status = 'Developing';

-- Update missing statuses to 'Developing' based on the country
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
  AND t2.Status = 'Developing';

-- Update missing statuses to 'Developed' based on the country
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
  AND t2.Status = 'Developed';

-- Identify records with missing life expectancy values
SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = '';

-- Calculate interpolated life expectancy values for missing records
SELECT t1.Country, t1.Year, t1.`Life expectancy`, 
       t2.Country AS Prev_Country, t2.Year AS Prev_Year, t2.`Life expectancy` AS Prev_Life_Exp, 
       t3.Country AS Next_Country, t3.Year AS Next_Year, t3.`Life expectancy` AS Next_Life_Exp,
       ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1) AS Interpolated_Value
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
  ON t1.Country = t2.Country
 AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
  ON t1.Country = t3.Country
 AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = '';

-- Update missing life expectancy values with interpolated values
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
  ON t1.Country = t2.Country
 AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
  ON t1.Country = t3.Country
 AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2, 1)
WHERE t1.`Life expectancy` = '';

-- Calculate life expectancy increase over 15 years by country
SELECT Country, 
       MIN(`Life expectancy`) AS Min_Life_Expectancy,
       MAX(`Life expectancy`) AS Max_Life_Expectancy,
       ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`), 1) AS Life_Increase_15_Years
FROM world_life_expectancy
GROUP BY Country
HAVING MIN(`Life expectancy`) <> 0 AND MAX(`Life expectancy`) <> 0
ORDER BY Life_Increase_15_Years DESC;

-- Average life expectancy by year
SELECT Year, ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Expectancy
FROM world_life_expectancy
WHERE `Life expectancy` <> 0
GROUP BY Year
ORDER BY Year;

-- Aggregate life expectancy and GDP by country
SELECT Country, 
       ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Expectancy, 
       ROUND(AVG(GDP), 1) AS Avg_GDP
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_Life_Expectancy > 0 AND Avg_GDP > 0
ORDER BY Avg_GDP DESC;

-- Count high and low GDP countries and their respective life expectancy
SELECT SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) AS High_GDP_Count,
       ROUND(AVG(CASE WHEN GDP >= 1500 THEN `Life expectancy` ELSE NULL END), 1) AS High_GDP_Life_Expectancy,
       SUM(CASE WHEN GDP < 1500 THEN 1 ELSE 0 END) AS Low_GDP_Count,
       ROUND(AVG(CASE WHEN GDP < 1500 THEN `Life expectancy` ELSE NULL END), 1) AS Low_GDP_Life_Expectancy
FROM world_life_expectancy;

-- Average life expectancy and country count by status
SELECT Status, 
       ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Expectancy, 
       COUNT(DISTINCT Country) AS Country_Count
FROM world_life_expectancy
GROUP BY Status;

-- Aggregate BMI and life expectancy by country
SELECT Country, 
       ROUND(AVG(`Life expectancy`), 1) AS Avg_Life_Expectancy, 
       ROUND(AVG(BMI), 1) AS Avg_BMI
FROM world_life_expectancy
GROUP BY Country
HAVING Avg_Life_Expectancy > 0 AND Avg_BMI > 0
ORDER BY Avg_BMI DESC;

-- Calculate rolling total of adult mortality by country and year
SELECT Country, Year, `Life expectancy`, `Adult Mortality`,
       SUM(`Adult Mortality`) OVER (PARTITION BY Country ORDER BY Year) AS Rolling_Total
FROM world_life_expectancy;
