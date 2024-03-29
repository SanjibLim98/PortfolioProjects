
-- Create database

CREATE DATABASE HR
USE HR

SELECT *
FROM hr_data


SELECT termdate
FROM hr_data
ORDER BY termdate DESC


-- Fix column "termdate" formatting
-- Format termdate datetime UTC values
-- Update date/time to date

UPDATE hr_data
SET termdate = FORMAT(CONVERT(datetime,LEFT(termdate, 19), 120), 'yyyy-mm-dd')


-- Update from nvachar to date
-- First, add a new date column

ALTER TABLE hr_data
ADD new_termdate DATE

-- Update the new date column with the converted values

UPDATE hr_data
SET new_termdate = CASE	
 WHEN termdate IS NOT NULL 
 AND 
 ISDATE(termdate) = 1 
 THEN
 CAST(termdate AS DATETIME)
 ELSE NULL
END

-- Create new column "age"

ALTER TABLE hr_data
ADD age nvarchar(50)

-- Populate new column with age

UPDATE hr_data
SET age = DATEDIFF(YEAR, birthdate, GETDATE())

SELECT age
FROM hr_data

-- QUESTIONS TO ANSWER FROM THE DATA

-- 1. What's the age distribution in the company? 

-- -- Min and max ages

SELECT 
 MIN(age) AS min_age,
 MAX(age) AS max_age
FROM hr_data


-- Age distribution

SELECT age_group,
COUNT(*) as CountOfPeople
FROM
(SELECT
 CASE
  WHEN age <= 22 AND age <= 30 THEN '22 to 30'
  WHEN age <= 32 AND age <= 40 THEN '32 to 40'
  WHEN age <= 42 AND age <= 50 THEN '42 to 50'
  ELSE '50+'
  END AS age_group
FROM hr_data
WHERE new_termdate IS NULL
) AS subquery
GROUP BY age_group
ORDER BY age_group

-- Age group by gender

SELECT age_group, 
gender,
COUNT(*) as CountOfPeople
FROM
(SELECT
 CASE
  WHEN age <= 22 AND age <= 30 THEN '22 to 30'
  WHEN age <= 32 AND age <= 40 THEN '32 to 40'
  WHEN age <= 42 AND age <= 50 THEN '42 to 50'
  ELSE '50+'
  END AS age_group,
  gender
FROM hr_data
WHERE new_termdate IS NULL
) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender


--2. What's the gender breakdown in the company?

SELECT 
	gender, 
	COUNT(*) AS TotalGenderCount
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC			


-- 3) How does gender vary across departments and job titles?

SELECT 
	department, 
	gender, 
	COUNT(gender) AS GenderCount
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender



-- Job titles

SELECT 
	department, 
	jobtitle, 
	gender, 
	COUNT(gender) AS GenderCount
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender

-- 4) What's the race distribution in the company?

SELECT 
	race, 
	COUNT(race) as RaceCount
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY race DESC

-- 5) What's the average length of employment in the company?

SELECT 
	AVG(DATEDIFF(year, hire_date, new_termdate)) AS Tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()


SELECT *
FROM hr_data


-- 6) Which department has the highest turnover rate?

-- Get total count
-- Get terminated count
-- Terminated count/total count

SELECT
	department,
	TotalCount,
	TerminatedCount,
	(ROUND(CAST(TerminatedCount AS FLOAT)/TotalCount,2)) * 100 AS Turnover_rate
FROM
(SELECT 
	department,
	COUNT(*) AS TotalCount,
	SUM(CASE
		WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE()
		THEN 1 
		ELSE 0
		END)
	AS TerminatedCount
FROM hr_data
GROUP BY department
) AS Subquery
ORDER BY Turnover_rate DESC




-- 7) What is the tenure distribution for each department?

SELECT 
	department,
	AVG(DATEDIFF(year, hire_date, new_termdate)) AS Tenure
FROM hr_data
WHERE new_termdate IS NOT NULL AND new_termdate <= GETDATE()
GROUP BY department
ORDER BY Tenure DESC


-- 8) How many employees work remotely for each department?

SELECT 
	location, 
	COUNT(location) as Count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location

-- 9) What's the distribution of employees across different states?

SELECT 
	location_state,
	COUNT(*) as Count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY Count DESC

-- 10) How are job titles distributed in the company?

SELECT 
	jobtitle,
	COUNT(*) as Count
FROM hr_data
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY Count DESC


-- 11) How have employee hire counts varied over time?
-- calculate hires
--calculate terminations
--(hires-termination)/hires percent hire change

SELECT 
	hire_year,
	hires,
	terminations,
	hires - terminations AS net_change,
	(ROUND(CAST((hires-terminations) AS FLOAT)/hires,2)) *100 AS percent_hire_change
	FROM
		(SELECT 
		YEAR(hire_date) AS hire_year,
		COUNT(*) AS hires,
		SUM( CASE
			WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() 
			THEN 1 
			END) AS terminations
		FROM hr_data
		GROUP BY YEAR(hire_date)
		) AS subquery
	ORDER BY percent_hire_change ASC

