create database virusdb;

-- Q1. If there are null values, update them with 0 in all the columns

select * from corona;

select * from 
corona
where province is null
or `Country/Region` is null
or latitude is null 
or longitude is null 
or date is null
or confirmed is null 
or deaths is null 
or recovered is null;

select * from 
corona
where province = ' ' 
or `Country/Region` =  ' ' 
or latitude = ' ' 
or longitude = ' ' 
or date = ' ' 
or confirmed = ' ' 
or deaths  = ' ' 
or recovered = ' ';

update corona
set confirmed = 0
where confirmed is null;

set sql_safe_updates = 0;

UPDATE corona
SET province = IFNULL(province, 'Unknown'),
    `Country/Region` = IFNULL(`Country/Region`, 'Unknown'),
    latitude = IFNULL(latitude, 0),
    longitude = IFNULL(longitude, 0),
    date = IFNULL(date, '0'),
    confirmed = IFNULL(confirmed, 0),
    deaths = IFNULL(deaths, 0),
    recovered = IFNULL(recovered, 0);
    
-- Q2. Check the total number of rows

select count(*) as total_rows
from corona;

-- Q3. Check the start date and the end date

select * from corona;

select min(str_to_date(date, '%Y-%m-%d')) as start_date, max(str_to_date(date, '%Y-%m-%d')) as end_date
from corona;

-- Q4. Update the date to date and time

select * from corona;

alter table corona
modify column `Date` date;

-- Q5. Find the number of months present in the dataset

select * from corona;

select distinct extract(month from `date`) 
from corona;

select count(distinct substr(`Date`, 1, 7)) as month
from corona;


/*

If you want to find the months even with gaps. Does not take the first month and last month into account.alter

select timestampdiff(month, min(date), max(date)) as num_of_months
from corona;

*/

-- Q5. Find the monthly average for confirmed, deaths, recovered

select * from corona;

select
substr(`Date`, 1, 7) as `Month`,
round(avg(confirmed), 2) as confirmed,
round(avg(deaths), 2) as deaths,
round(avg(recovered), 2)as recovered
from corona
group by `Month`;


-- Q6. Find the minimum values for confirmed, deaths, recovered per year

select
distinct year(`date`) as `Year`,
min(case when confirmed != 0 then confirmed end ) as confirmed,
min(case when deaths != 0 then deaths end) as deaths,
min(case when recovered != 0 then recovered end) as recovered
from corona
group by `Year`;

-- Q7. Find the total number of confirmed cases, deaths, recovered each month

select substr(`date`, 1, 7) month, sum(confirmed) confirmed, sum(deaths) deaths, sum(recovered) recovered
from corona
group by substr(`date`, 1, 7);

-- Q8. Find the country with the highest number of confrimed cases

select * from corona;

with cte as (select `country/Region`, sum(confirmed) confirmed, row_number() over(order by sum(confirmed) desc) rn 
from corona
group by `country/Region`)

select `country/Region`, confirmed
from cte
where rn = 1;

-- Q9. Find the country with the lowest number of death case

select * from corona;

with cte as (select `Country/Region`, sum(deaths) deaths, row_number() over(order by sum(deaths)) as rn
from corona
group by `Country/Region`)

select `Country/Region`, deaths
from cte
where rn = 1;

-- Q10. Find the most frequent value for confirmed, deaths, recovered for each months

select distinct confirmed
from corona;

select distinct deaths
from corona;

select distinct recovered
from corona;

with mostFrequentConfirmed as
( select substr(`Date`, 1, 7) as month, sum(confirmed) mfconfirmed, row_number() over(order by sum(confirmed) desc) as rn
	from corona
    group by substr(`Date`, 1, 7)
), 
    
mostFrequentDeaths as (
select substr(`Date`, 1, 7) as month, sum(deaths) mfdeaths, row_number() over(order by sum(deaths) desc) as rn
from corona
group by substr(`Date`, 1, 7)),

mostFrequentRecovered as (
select substr(`Date`, 1, 7) as month, sum(recovered) mfrecovered, row_number() over(order by sum(recovered))as rn
from corona
group by substr(`Date`, 1, 7))

select c.month as confirmed_month, c.mfconfirmed, 
		d.month as deaths_month, d.mfdeaths,
			r.month as recovered_month, r.mfRecovered
from mostFrequentConfirmed c
join mostFrequentDeaths d on d.rn = 1
join mostFrequentRecovered r on r.rn = 1
where c.rn = 1



