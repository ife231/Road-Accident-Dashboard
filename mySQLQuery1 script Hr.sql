CREATE DATABASE hr;
USE hr;

SELECT *
FROM [HR Data];

SELECT termdate
FROM [HR Data]
ORDER BY termdate DESC

UPDATE [HR Data]
SET termdate = FORMAT(CONVERT(DATETIME, LEFT(termdate, 19), 120), 'yyyy-MM-dd');

ALTER TABLE [HR DATA]
ADD new_termdate DATE;

-- copy converted time value from terdate to new_termdate

UPDATE [HR Data]
SET new_termdate = CASE
WHEN termdate IS NOT NULL AND ISDATE(termdate) = 1 THEN CAST (termdate AS DATETIME) ELSE NULL END;


-- create new column "age
 ALTER TABLE [HR Data]
ADD age nvarchar (50);

-- populate new column with age 
UPDATE [HR Data]
SET age = DATEDIFF(YEAR, birthdate, GETDATE())

SELECT age
FROM [HR Data]



-- QUESTION TO ANSWER FROM THE DATA

--1) What`s the age distribution in the company?

--age distribution

SELECT
MIN(age) AS youngest,
MAX(age) AS OLDEST
FROM [HR Data]


--age group by gender

SELECT age_group,
gender,
count(*) AS count
FROM
(SELECT
CASE
WHEN age <= 22 AND age <= 30 THEN '22 to 30'
WHEN age <= 32 AND age <= 40 THEN '32 to 40'
WHEN age <= 42 AND age <= 50 THEN '42 to 50'
ELSE '50+'
END AS age_group,
gender
FROM [HR Data]
WHERE new_termdate IS NULL
) AS subquery
GROUP BY age_group, gender
ORDER BY age_group, gender




--2) whats`s the gender breakdown in the company?

SELECT
gender,
count(gender) AS count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY gender
ORDER BY gender ASC



--3) How does gender cross deparment and jobs titles?

SELECT
department,
gender,
count(gender) AS count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY department, gender
ORDER BY department, gender ASC

--job titles
SELECT
department, jobtitle,
gender,
count(gender) AS count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY department, jobtitle, gender
ORDER BY department, jobtitle, gender ASC



--4) What`s the race distribution in the company?

SELECT
race,
count(*) AS count
FROM 
[HR Data]
WHERE new_termdate IS NULL
GROUP BY race
ORDER BY count DESC;


--5) What`s the average length of employment in the company?


SELECT
AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM [HR Data]
WHERE new_termdate IS NOT NULL AND new_termdate <=GETDATE();


--6) Which department has the highest turnover rate?


-- get total count
-- get terminated count
-- terminated count/total count
SELECT
department,
total_count,
terminated_count,
round((CAST(terminated_count AS FLOAT)/total_count), 2) * 100 AS turnover_rate
FROM
(SELECT
	department,
	COUNT(*) AS total_count,
	SUM(CASE
	WHEN new_termdate IS NOT NULL AND new_termdate <= GETDATE() THEN 1 ELSE 0
	END
	) AS terminated_count
	FROM [HR Data]
	GROUP BY department
	)AS subquery
	ORDER BY turnover_rate DESC;



--7) what is the tenure distribution for each department?


SELECT
department,
AVG(DATEDIFF(year, hire_date, new_termdate)) AS tenure
FROM [HR Data]
WHERE new_termdate IS NOT NULL AND new_termdate <=GETDATE()
GROUP BY department
ORDER BY tenure DESC;


--8) How many employees work remotely for each department?

SELECT
location,
count(*) as count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY location


--9) What`s the distribution of employees across different state?

SELECT
location_state,
COUNT(*) AS count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY location_state
ORDER BY count DESC;


--10) How are job titles distributed in the company?

SELECT
jobtitle,
COUNT(*) AS count
FROM [HR Data]
WHERE new_termdate IS NULL
GROUP BY jobtitle
ORDER BY count DESC;





--11) How have employee hire counts varied over time?
-- calculate hires
-- calculate terminations
-- (hires-terminations)/hires percent hire change
SELECT
hire_year,
hires,
terminations,
hires - terminations AS net_change,
round(CAST(hires-terminations AS FLOAT)/hires, 2) *100 AS percent_hires_change
FROM
(SELECT
 YEAR(hire_date) AS hire_year,
COUNT(*) AS hires,
SUM(CASE
       WHEN new_termdate is not null and new_termdate <= GETDATE() THEN 1 ELSE 0
       END
       ) AS terminations
FROM [HR Data]
GROUP BY YEAR(hire_date)
) AS subquery
ORDER BY percent_hires_change ASC;