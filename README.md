# COVID-19 Data Analysis Project

> **Note:** This project was built while following a YouTube tutorial to practice MySQL data analysis. The goal was to understand the concepts and apply them. Any modifications or experiments I made are my own.
## Overview

Cleaning and analyzing COVID-19 data from 2020 using **MySQL**, with the aim to explore trends in confirmed cases, deaths, and recoveries across countries, regions, and time periods.

## Files
- `corona-dataset.csv` – Original dataset containing records of COVID-19 cases.
- `data-cleaning.sql` – SQL queries for cleaning the dataset.
- `data-analysis.sql` – SQL queries for analyzing the dataset.

## Key Questions
The analysis addresses the following questions:

1. If there are NULL values, how can they be updated with 0 in all columns?
2. What is the total number of rows in the dataset?
3. What are the start and end dates of the dataset?
4. How can the `Date` column be updated to a proper date format?
5. How many months are present in the dataset?
6. What is the monthly average for `Confirmed`, `Deaths`, and `Recovered` cases?
7. What are the minimum values for `Confirmed`, `Deaths`, and `Recovered` per year?
8. What is the total number of confirmed cases, deaths, and recoveries each month?
9. Which country has the highest number of confirmed cases?
10. Which country has the lowest number of deaths?
11. What are the most frequent values for `Confirmed`, `Deaths`, and `Recovered` for each month?

## Data Cleaning

The COVID-19 dataset was cleaned and prepared for analysis using MySQL:

- Created a database named `virusdb` and a table named `corona` with columns: `Province`, `Country/Region`, `Latitude`, `Longitude`, `Date`, `Confirmed`, `Deaths`, and `Recovered`.
- Replaced NULL values in `Province` and `Country/Region` with 'Unknown', and in `Latitude`, `Longitude`, `Confirmed`, `Deaths`, and `Recovered` with 0. Replaced NULLs in `Date` with '0'.
- Checked for empty strings (' ') to ensure data consistency.
- Converted the `Date` column to a proper `DATE` format.
- Verified data types and checked for missing or inconsistent values.

These steps ensured a clean, structured dataset ready for analysis.

## SQL Analysis

### 1. If there are NULL values, how can they be updated with 0 in all columns?
Replaced NULLs in `Province` and `Country/Region` with 'Unknown', and in `Latitude`, `Longitude`, `Confirmed`, `Deaths`, and `Recovered` with 0. Replaced NULLs in `Date` with '0'. Checked for empty strings (' ') to ensure data consistency.
```sql
SELECT * FROM corona
WHERE province IS NULL
OR `Country/Region` IS NULL
OR latitude IS NULL 
OR longitude IS NULL 
OR date IS NULL
OR confirmed IS NULL 
OR deaths IS NULL 
OR recovered IS NULL;

SELECT * FROM corona
WHERE province = ' ' 
OR `Country/Region` = ' ' 
OR latitude = ' ' 
OR longitude = ' ' 
OR date = ' ' 
OR confirmed = ' ' 
OR deaths = ' ' 
OR recovered = ' ';

UPDATE corona
SET confirmed = 0
WHERE confirmed IS NULL;

SET SQL_SAFE_UPDATES = 0;

UPDATE corona
SET province = IFNULL(province, 'Unknown'),
    `Country/Region` = IFNULL(`Country/Region`, 'Unknown'),
    latitude = IFNULL(latitude, 0),
    longitude = IFNULL(longitude, 0),
    date = IFNULL(date, '0'),
    confirmed = IFNULL(confirmed, 0),
    deaths = IFNULL(deaths, 0),
    recovered = IFNULL(recovered, 0);
```

### 2. What is the total number of rows in the dataset?
```sql
SELECT COUNT(*) AS total_rows
FROM corona;
```

### 3. What are the start and end dates of the dataset?
Determined the earliest and latest dates in the `Date` column.
```sql
SELECT MIN(STR_TO_DATE(date, '%Y-%m-%d')) AS start_date, 
       MAX(STR_TO_DATE(date, '%Y-%m-%d')) AS end_date
FROM corona;
```

### 4. How can the `Date` column be updated to a proper date format?
Modified the `Date` column to store data in a proper `DATE` format.
```sql
ALTER TABLE corona
MODIFY COLUMN `Date` DATE;
```

### 5. How many months are present in the dataset?
Calculated the total number of months, including gaps, using `TIMESTAMPDIFF`.
```sql
SELECT TIMESTAMPDIFF(MONTH, MIN(date), MAX(date)) AS num_of_months
FROM corona;
```

### 6. What is the monthly average for `Confirmed`, `Deaths`, and `Recovered` cases?
Calculated the average number of confirmed cases, deaths, and recoveries per month, rounded to two decimal places.
```sql
SELECT SUBSTR(`Date`, 1, 7) AS `Month`,
       ROUND(AVG(confirmed), 2) AS confirmed,
       ROUND(AVG(deaths), 2) AS deaths,
       ROUND(AVG(recovered), 2) AS recovered
FROM corona
GROUP BY `Month`;
```

### 7. What are the minimum values for `Confirmed`, `Deaths`, and `Recovered` per year?
```sql
SELECT DISTINCT YEAR(`date`) AS `Year`,
       MIN(CASE WHEN confirmed != 0 THEN confirmed END) AS confirmed,
       MIN(CASE WHEN deaths != 0 THEN deaths END) AS deaths,
       MIN(CASE WHEN recovered != 0 THEN recovered END) AS recovered
FROM corona
GROUP BY `Year`;
```

### 8. What is the total number of confirmed cases, deaths, and recoveries each month?
Calculated the sum of confirmed cases, deaths, and recoveries for each month.
```sql
SELECT SUBSTR(`date`, 1, 7) AS month, 
       SUM(confirmed) AS confirmed, 
       SUM(deaths) AS deaths, 
       SUM(recovered) AS recovered
FROM corona
GROUP BY SUBSTR(`date`, 1, 7);
```

### 9. Which country has the highest number of confirmed cases?
Identified the country with the highest total confirmed cases.
```sql
WITH cte AS (
    SELECT `country/Region`, SUM(confirmed) AS confirmed, 
           ROW_NUMBER() OVER(ORDER BY SUM(confirmed) DESC) AS rn 
    FROM corona
    GROUP BY `country/Region`
)
SELECT `country/Region`, confirmed
FROM cte
WHERE rn = 1;
```

### 10. Which country has the lowest number of deaths?
Identified the country with the lowest total deaths.
```sql
WITH cte AS (
    SELECT `Country/Region`, SUM(deaths) AS deaths, 
           ROW_NUMBER() OVER(ORDER BY SUM(deaths)) AS rn
    FROM corona
    GROUP BY `Country/Region`
)
SELECT `Country/Region`, deaths
FROM cte
WHERE rn = 1;
```

### 11. What are the most frequent values for `Confirmed`, `Deaths`, and `Recovered` for each month?
Determined the highest sum of confirmed cases, deaths, and recoveries per month.
```sql
WITH mostFrequentConfirmed AS (
    SELECT SUBSTR(`Date`, 1, 7) AS month, SUM(confirmed) AS mfconfirmed, 
           ROW_NUMBER() OVER(ORDER BY SUM(confirmed) DESC) AS rn
    FROM corona
    GROUP BY SUBSTR(`Date`, 1, 7)
), 
mostFrequentDeaths AS (
    SELECT SUBSTR(`Date`, 1, 7) AS month, SUM(deaths) AS mfdeaths, 
           ROW_NUMBER() OVER(ORDER BY SUM(deaths) DESC) AS rn
    FROM corona
    GROUP BY SUBSTR(`Date`, 1, 7)
),
mostFrequentRecovered AS (
    SELECT SUBSTR(`Date`, 1, 7) AS month, SUM(recovered) AS mfrecovered, 
           ROW_NUMBER() OVER(ORDER BY SUM(recovered)) AS rn
    FROM corona
    GROUP BY SUBSTR(`Date`, 1, 7)
)
SELECT c.month AS confirmed_month, c.mfconfirmed, 
       d.month AS deaths_month, d.mfdeaths,
       r.month AS recovered_month, r.mfrecovered
FROM mostFrequentConfirmed c
JOIN mostFrequentDeaths d ON d.rn = 1
JOIN mostFrequentRecovered r ON r.rn = 1
WHERE c.rn = 1;
```

## Learning Outcomes

- Enhanced MySQL skills with real-world COVID-19 data.
- Mastered data cleaning, handling NULLs and date formats.
- Learned aggregations, grouping, and `ROW_NUMBER()` functions.
- Explored creative query solutions, improving problem-solving.
- Gained confidence in turning raw data into insights.
- Strengthened complex query design for data analysis.
