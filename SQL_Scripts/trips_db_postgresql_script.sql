-- Create the dim_city table
CREATE TABLE dim_city (
    city_id VARCHAR(50) PRIMARY KEY, -- Alphanumeric unique identifier for each city (e.g., RJ01)
    city_name VARCHAR(255) NOT NULL -- Name of the city (e.g., Jaipur, Lucknow)
);

-- Create the dim_date table
CREATE TABLE dim_date (
    date DATE PRIMARY KEY, -- Specific date (formatted as YYYY-MM-DD)
    start_of_month DATE NOT NULL, -- The first day of the month for the date
    month_name VARCHAR(50) NOT NULL, -- Name of the month (e.g., January)
    day_type VARCHAR(10) NOT NULL CHECK (day_type IN ('Weekday', 'Weekend')) -- Indicates whether it's a weekday or weekend
);

-- Create the fact_passenger_summary table (Aggregated Data)
CREATE TABLE fact_passenger_summary (
    month DATE NOT NULL, -- Start date of the month (formatted as YYYY-MM-DD)
    city_id VARCHAR(50) REFERENCES dim_city(city_id) ON DELETE CASCADE, -- Alphanumeric unique identifier for the city
    total_passengers INT NOT NULL, -- Total passengers (new + repeat) for the city and month
    new_passengers INT NOT NULL, -- Count of new passengers for the city and month
    repeat_passengers INT NOT NULL, -- Count of repeat passengers for the city and month
    PRIMARY KEY (month, city_id) -- Composite primary key
);

-- Create the dim_repeat_trip_distribution table (Aggregated Data)
CREATE TABLE dim_repeat_trip_distribution (
    month DATE NOT NULL, -- Start date of the month (formatted as YYYY-MM-DD)
    city_id VARCHAR(50) REFERENCES dim_city(city_id) ON DELETE CASCADE, -- Alphanumeric unique identifier for the city
    trip_count VARCHAR(20) NOT NULL, -- Trip frequency (e.g., "3-Trips" for passengers with 3 trips)
    repeat_passenger_count INT NOT NULL, -- Count of repeat passengers for the city, month, and trip_count
    PRIMARY KEY (month, city_id, trip_count) -- Composite primary key to ensure unique entries
);

-- Create the fact_trips table with allowance for negative ratings
CREATE TABLE fact_trips (
    trip_id VARCHAR(50) PRIMARY KEY, -- Unique alphanumeric identifier for each trip
    date DATE NOT NULL REFERENCES dim_date(date) ON DELETE CASCADE, -- Exact date of the trip
    city_id VARCHAR(50) NOT NULL REFERENCES dim_city(city_id) ON DELETE CASCADE, -- Alphanumeric unique identifier for the city
    passenger_type VARCHAR(10) NOT NULL CHECK (LOWER(passenger_type) IN ('new', 'repeated')), -- Case-insensitive check for 'New' or 'Repeated'
    distance_travelled_km NUMERIC(8, 2) NOT NULL CHECK (distance_travelled_km >= 0), -- Total distance in kilometers (e.g., 10.25 km)
    fare_amount NUMERIC(10, 2) NOT NULL CHECK (fare_amount >= 0), -- Fare amount in local currency (e.g., 250.75)
    passenger_rating NUMERIC(4, 2) CHECK (passenger_rating BETWEEN -10 AND 10), -- Passenger's rating (-10.00 to 10.00)
    driver_rating NUMERIC(4, 2) CHECK (driver_rating BETWEEN -10 AND 10) -- Driver's rating (-10.00 to 10.00)
);
/*check*/

SELECT *
FROM dim_repeat_trip_distribution
LIMIT 10;

SELECT *
FROM fact_passenger_summary
LIMIT 10;

SELECT *
FROM fact_trips
LIMIT 10;



-- Exploratory Data Analysis

SELECT COUNT (*) -- general sense of how big the table is
FROM dim_city; -- 10 rows no null checked

SELECT DISTINCT city_name -- all the location that cab service operates in 
FROM dim_city;

SELECT COUNT(*) -- 540
FROM dim_repeat_trip_distribution; -- need to check nulls

SELECT COUNT(*) -- 182 and check for nulls
FROM dim_date;

SELECT COUNT(*)  -- 60 and no visible null values
FROM fact_passenger_summary;

SELECT COUNT(*) -- 425903 and check for nulls and duplicates
FROM fact_trips;

/* COUNT(*) counts all rows, including those with NULLs */

--range of date in table
-- 6 months 2024-01-01 to 2024-06-30
SELECT MIN(date), 
	   MAX(date)
FROM dim_date;

/* checking nulls */

/* city_id as it is foreign key */ 
SELECT COUNT(*) -- no null
FROM dim_repeat_trip_distribution
WHERE city_id IS NULL;

SELECT COUNT(*) -- no null
FROM fact_passenger_summary
WHERE city_id IS NULL;

SELECT COUNT(*) -- no null
FROM fact_trips
WHERE city_id IS NULL;

SELECT COUNT(*) -- no null
FROM fact_trips
WHERE trip_id IS NULL;

/* important for financal analysis */
SELECT COUNT(*) -- no null 
FROM fact_trips
WHERE fare_amount IS NULL;

SELECT COUNT(*) -- no null 
FROM fact_trips
WHERE passenger_type IS NULL;

SELECT COUNT(*) -- no null 
FROM fact_trips
WHERE distance_travelled_km IS NULL;

SELECT COUNT(*) -- no null 
FROM dim_date
WHERE date IS NULL;



-- Fare and trip  summary report


/* Daily avg trips Counts */

SELECT date,
	ROUND(AVG(count))
FROM(
SELECT date, 
	COUNT(trip_id) AS count
FROM fact_trips 
GROUP BY date 
ORDER BY date)
GROUP BY date;

/* total trips */

SELECT
	COUNT(trip_id) AS count
FROM fact_trips;

/* monthly trip count */

SELECT dd.start_of_month,
	  dd.month_name,
      COUNT(ft.trip_id) as monthly_trips
FROM dim_date AS dd
LEFT JOIN fact_trips AS ft 
ON dd.date = ft.date
GROUP BY dd.start_of_month, dd.month_name
ORDER BY dd.start_of_month;

/* trip count for weekend and weekday overall */
SELECT dd.day_type,
	   COUNT(ft.trip_id)
FROM dim_date AS dd
JOIN fact_trips AS ft
ON dd.date = ft.date
GROUP BY dd.day_type;


/* trip count by day_type for each month */
SELECT dd.start_of_month,
	   dd.month_name,
       dd.day_type,
       COUNT(ft.trip_id) AS trip_count
FROM dim_date AS dd
JOIN fact_trips AS ft
ON dd.date = ft.date
GROUP BY dd.start_of_month,dd.month_name, dd.day_type
ORDER BY dd.start_of_month;

/* total trips per city */

SELECT dc.city_name,
       COUNT(ft.trip_id) AS city_trip_count
FROM dim_city AS dc
JOIN fact_trips AS ft
ON dc.city_id = ft.city_id
GROUP BY dc.city_name
ORDER BY city_trip_count DESC;

/* Average fare for each city */
SELECT dc.city_name,
	   ROUND(AVG(ft.fare_amount)) AS avg_city_fare
FROM dim_city AS dc
INNER JOIN fact_trips AS ft
ON dc.city_id = ft.city_id
GROUP BY dc.city_name
ORDER BY avg_city_fare DESC;

/* Average fare per km for each city */
SELECT dc.city_name,
      ROUND(AVG(ft.fare_amount/ NULLIF(distance_travelled_km,0))) AS avg_fare_km
FROM dim_city AS dc
INNER JOIN fact_trips AS ft
ON dc.city_id = ft.city_id
GROUP BY dc.city_name
ORDER BY avg_fare_km DESC;

/* percentage contribution of each city's trip to the overall trips */

SELECT dc.city_name,
	  COUNT(ft.trip_id),
	  ROUND(COUNT(ft.trip_id)* 100.0 / (SELECT COUNT(*) FROM fact_trips),2)  AS percentage_contribution_to_total_trips
FROM dim_city AS dc
LEFT JOIN fact_trips AS ft 
ON dc.city_id = ft.city_id
GROUP BY  dc.city_name 
ORDER BY percentage_contribution_to_total_trips DESC;


/* extension links databases */
CREATE EXTENSION IF NOT EXISTS postgres_fdw;


DROP SERVER IF EXISTS targets_server CASCADE;

SELECT srvname, srvoptions
FROM pg_foreign_server;

/* create the foreign server*/

CREATE SERVER targets_server
FOREIGN DATA WRAPPER postgres_fdw
OPTIONS(host 'localhost', port '5433', dbname 'target_db');


/* Create a USER Mapping */
CREATE USER MAPPING FOR CURRENT_USER
SERVER targets_server
OPTIONS (user 'postgres', password '1234');

/* Import Foreign Schema */

IMPORT FOREIGN SCHEMA public
FROM SERVER targets_server
INTO public;

/* Confirming currentforeign tables */

SELECT srvname, srvoptions
FROM pg_foreign_server
WHERE srvname = 'targets_server';

/* testing*/
SELECT * 
FROM public.city_target_passenger_rating
LIMIT 10;

SELECT * 
FROM public.monthly_target_trips
LIMIT 10;

SELECT * 
FROM public.monthly_target_new_passengers
LIMIT 10;

/* checking which cities met the monhtly target on trips */

WITH counting_trips AS(
 SELECT dc.city_id AS city_id,
        dc.city_name AS city,
        dd.start_of_month AS month_start,
        dd.month_name AS month,
      COUNT(ft.trip_id) AS trip_count
FROM fact_trips AS ft
JOIN dim_date AS dd
ON ft.date = dd.date
JOIN dim_city AS dc
ON dc.city_id = ft.city_id
GROUP BY dc.city_id, dd.month_name, dc.city_name, dd.start_of_month 
),
target_trips AS(
 SELECT mt.month AS month_start,
	    mt.city_id AS city_id,
	    mt.total_target_trips AS target_trip
 FROM public.monthly_target_trips AS mt)
SELECT
  ct.city AS city,
  ct.month AS month,
  ct.trip_count AS total_trips,
  tt.target_trip AS target_trip,
(CASE WHEN ct.trip_count > tt.target_trip THEN 'Above Target' ELSE 'Below Target' END) AS performance_status
FROM counting_trips AS ct
JOIN target_trips AS tt
ON ct.city_id = tt.city_id AND ct.month_start  = tt.month_start;




-- Total repeat passengers from dim_repeat_trip_distribution
SELECT dim_city.city_name AS city, 
	SUM(CASE WHEN fact_trips.passenger_type = 'repeated' then 1 else 0 end) AS total_repeat_passengers
FROM fact_trips
JOIN dim_city
ON fact_trips.city_id = dim_city.city_id
GROUP BY city_name;

-- Total new passengers from dim_repeat_trip_distribution
SELECT dim_city.city_name AS city, 
	SUM(CASE WHEN fact_trips.passenger_type = 'new' then 1 else 0 end) AS total_new_passengers
FROM fact_trips
JOIN dim_city
ON fact_trips.city_id = dim_city.city_id
GROUP BY city_name;

/* total repeat passengers */
(SELECT city_id, 
	COUNT(CASE WHEN passenger_type = 'repeated' THEN 1 ELSE 0 END) AS total_repeat_passengers
FROM fact_trips
GROUP BY city_id);


/* City-Level Repeat Passenger Trip Frequency Report*/

SELECT  
    dc.city_name AS city,
    ROUND(SUM(CASE WHEN drtd.trip_count = '2-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "2-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '3-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "3-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '4-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "4-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '5-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "5-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '6-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "6-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '7-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "7-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '8-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "8-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '9-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "9-Trips_%total",
    ROUND(SUM(CASE WHEN drtd.trip_count = '10-Trips' THEN drtd.repeat_passenger_count ELSE 0 END) * 100.0 / 
          NULLIF(SUM(drtd.repeat_passenger_count), 0), 2) AS "10-Trips_%total"
FROM dim_repeat_trip_distribution AS drtd
JOIN dim_city AS dc
    ON drtd.city_id = dc.city_id
GROUP BY dc.city_name
ORDER BY dc.city_name;


/*Identify Cities with Highest and Lowest total new passengers */

SELECT *
FROM fact_passenger_summary
LIMIT 5;


With new_passengers_aggregate AS
	(SELECT
	dc.city_name AS city,
	SUM(fps.new_passengers) AS total_new_passengers,
	DENSE_RANK() OVER( ORDER BY SUM(fps.new_passengers) DESC) AS ranks
FROM fact_passenger_summary AS fps
JOIN dim_city AS dc
ON fps.city_id = dc.city_id
GROUP BY dc.city_name)
SELECT
	city,
	total_new_passengers,
	ranks
FROM new_passengers_aggregate
WHERE ranks IN(1,2,3,8,9,10)
ORDER BY ranks ASC;

/* Identify Month with Highest Revenue for each city */

WITH revenue_by_month AS
(SELECT
	dc.city_name AS name,
	dd.month_name AS month,
	SUM(ft.fare_amount) as revenue
FROM fact_trips AS ft
JOIN dim_city AS dc
ON ft.city_id = dc.city_id
JOIN dim_date AS dd
ON ft.date = dd.date
GROUP BY dc.city_name, dd.month_name
ORDER BY revenue DESC),
 city_total_revenue AS(
	SELECT 
	name,
    SUM(revenue) AS total_revenue_per_city
FROM revenue_by_month
GROUP BY name),
highest_revenue_in_a_month AS(
  SELECT
	name,
	month,
	revenue,
	DENSE_RANK() OVER(PARTITION BY name ORDER BY revenue DESC) AS ranks
FROM revenue_by_month)	
SELECT hrm.name,
	   hrm.month,
	   hrm.revenue,
 ROUND(hrm.revenue * 100.0 / ctr.total_revenue_per_city,2) AS percentage_contribution
FROM city_total_revenue AS ctr
JOIN highest_revenue_in_a_month AS hrm
	ON hrm.name = ctr.name
WHERE hrm.ranks = 1;


/* City - Monthly Repeat Passenger Rate */
-- city level data
SELECT 
	dc.city_name AS city,
   SUM(fps.total_passengers) AS total_passengers,
   SUM(fps.repeat_passengers) AS repeat_passengers,
   SUM(fps.new_passengers) AS new_passengers
FROM fact_passenger_summary AS fps
JOIN dim_city AS dc
ON dc.city_id = fps.city_id
GROUP BY dc.city_name;

--Observation total_passenger are less than repeat_passengers there seems some discripency
--crosschecking the passengers data using fact_trips


SELECT 
	dc.city_name AS name,
	SUM(CASE WHEN ft.passenger_type = 'repeated' THEN 1 ELSE 0 END) AS repeat_passengers,
	SUM(CASE WHEN ft.passenger_type = 'new' THEN 1 ELSE 0 END) AS new_passengers,
  (SUM(CASE WHEN ft.passenger_type = 'repeated' THEN 1 ELSE 0 END) +
   SUM(CASE WHEN ft.passenger_type = 'new' THEN 1 ELSE 0 END)) AS total_passengers
FROM fact_trips AS ft
JOIN dim_city AS dc
	ON dc.city_id = ft.city_id
GROUP BY dc.city_name;

/* City Level data repeat passenger rate */
SELECT name,
	   repeat_passengers,
	   total_passengers,
	ROUND(repeat_passengers*100.0 / total_passengers,2)
FROM(
  SELECT 
    dc.city_name AS name,
    SUM(CASE WHEN ft.passenger_type = 'repeated' THEN 1 ELSE 0 END) AS repeat_passengers,
    SUM(CASE WHEN ft.passenger_type = 'new' THEN 1 ELSE 0 END) AS new_passengers,
    (SUM(CASE WHEN ft.passenger_type = 'repeated' THEN 1 ELSE 0 END) + 
     SUM(CASE WHEN ft.passenger_type = 'new' THEN 1 ELSE 0 END)) AS total_passengers
FROM fact_trips AS ft
JOIN dim_city AS dc ON ft.city_id = dc.city_id
GROUP BY dc.city_name);


/* city and month level data repeat passenger rate */
SELECT
	name,
    month,
    repeat_passengers,
	total_passengers,
	ROUND(repeat_passengers*100.0 / total_passengers,2)
FROM(
SELECT 
    dc.city_name AS name,
	dd.month_name AS month,
    SUM(CASE WHEN ft.passenger_type = 'repeated' THEN 1 ELSE 0 END) AS repeat_passengers,
    SUM(CASE WHEN ft.passenger_type = 'new' THEN 1 ELSE 0 END) AS new_passengers,
    (SUM(CASE WHEN ft.passenger_type = 'repeated' THEN 1 ELSE 0 END) + 
     SUM(CASE WHEN ft.passenger_type = 'new' THEN 1 ELSE 0 END)) AS total_passengers
FROM fact_trips AS ft
JOIN dim_city AS dc ON ft.city_id = dc.city_id
JOIN dim_date AS dd ON ft.date = dd.date
GROUP BY dc.city_name, dd.month_name);

/* total Passengers*/
SELECT
  (repeat_passengers + new_passengers) AS total_passengers
FROM (
	SELECT
	SUM(CASE WHEN passenger_type = 'repeated' THEN 1 ELSE 0 END) AS repeat_passengers,
    SUM(CASE WHEN passenger_type = 'new' THEN 1 ELSE 0 END) AS new_passengers
    FROM fact_trips);

/* total new and repeat  passengers */

SELECT
	SUM(CASE WHEN passenger_type = 'repeated' THEN 1 ELSE 0 END) AS repeat_passengers,
    SUM(CASE WHEN passenger_type = 'new' THEN 1 ELSE 0 END) AS new_passengers
FROM fact_trips;


/* rating summaries */

/* Avg rating per city */
with avg_rating_per_city AS 
	(SELECT dc.city_id AS city_id,
	dc.city_name AS city,
	ROUND(AVG(ft.passenger_rating),2) AS avg_passenger_rating
FROM fact_trips AS ft 
JOIN dim_city AS dc
ON ft.city_id = dc.city_id
GROUP BY dc.city_name, dc.city_id),
target_passenger_rating AS(
 SELECT ctpr.city_id AS city_id,
        ctpr.target_avg_passenger_rating
 FROM public.city_target_passenger_rating AS ctpr)
SELECT arpc.city AS city,
	   arpc.avg_passenger_rating AS avg_passenger_rating,
	   ttr.target_avg_passenger_rating AS target_avg_passenger_rating,
 (CASE WHEN arpc.avg_passenger_rating > ttr.target_avg_passenger_rating THEN 'Above Target' ELSE 'Below Target' END) AS target
FROM target_passenger_rating AS ttr
JOIN avg_rating_per_city AS arpc
ON ttr.city_id = arpc.city_id;


/* target new passenger for each city */
With new_passenger_count AS
(SELECT dc.city_id,
	    dc.city_name AS city,
        dd.start_of_month,
	    dd.month_name AS month,
  SUM(CASE WHEN ft.passenger_type = 'new' THEN 1 ELSE 0 END) AS total_new_passengers
FROM fact_trips AS ft
JOIN dim_date AS dd ON ft.date = dd.date
JOIN dim_city AS dc ON dc.city_id = ft.city_id
GROUP BY dc.city_id, dd.start_of_month, dd.month_name, dc.city_name),
  target_new_passengers AS(
SELECT city_id,
	   month,
 target_new_passengers
FROM public.monthly_target_new_passengers)
SELECT
	npc.city AS city,
	npc.month AS month,
	npc.total_new_passengers AS new_passengers,
	tnp.target_new_passengers AS target_passengers,
 (CASE WHEN npc.total_new_passengers > tnp.target_new_passengers THEN 'Above Target' ELSE 'Below Target' END) AS target
FROM new_passenger_count AS npc
JOIN target_new_passengers AS tnp
ON npc.city_id = tnp.city_id AND 
npc.start_of_month = tnp.month;

/* revenue per trip_id */
SELECT DISTINCT trip_id,
       SUM(fare_amount)
FROM fact_trips
GROUP BY trip_id;

/* revenue per city */
SELECT dc.city_name AS city,
       ROUND(SUM(fare_amount)) AS revenue
FROM fact_trips AS ft
JOIN  dim_city AS dc ON dc.city_id = ft.city_id
GROUP BY dc.city_name
ORDER BY revenue DESC;

/* avg driver rating*/
SELECT dc.city_name AS city,
	ROUND(AVG(ft.driver_rating),2) AS avg_driver_rating
FROM fact_trips AS ft
JOIN dim_city AS dc ON ft.city_id = dc.city_id
GROUP BY dc.city_name
ORDER BY avg_driver_rating DESC;


