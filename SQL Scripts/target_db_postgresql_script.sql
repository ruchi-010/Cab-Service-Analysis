
-- Create the city_target_passenger_rating table
CREATE TABLE city_target_passenger_rating (
    city_id VARCHAR(50) PRIMARY KEY, -- Alphanumeric unique identifier for each city
    target_avg_passenger_rating NUMERIC(3, 2) NOT NULL -- Target average rating (e.g., 4.50)
);

-- Create the monthly_target_new_passengers table
CREATE TABLE monthly_target_new_passengers (
    month DATE NOT NULL, -- Start date of the target month (formatted as YYYY-MM-DD)
    city_id VARCHAR(50) REFERENCES city_target_passenger_rating(city_id) ON DELETE CASCADE, -- Foreign key linking to city_target_passenger_rating
    target_new_passengers INT NOT NULL, -- Target number of new passengers
    PRIMARY KEY (month, city_id) -- Composite primary key to prevent duplicate entries
);

-- Create the monthly_target_trips table
CREATE TABLE monthly_target_trips (
    month DATE NOT NULL, -- Start date of the target month (formatted as YYYY-MM-DD)
    city_id VARCHAR(50) REFERENCES city_target_passenger_rating(city_id) ON DELETE CASCADE, -- Foreign key linking to city_target_passenger_rating
    total_target_trips INT NOT NULL, -- Target number of total trips
    PRIMARY KEY (month, city_id) -- Composite primary key to prevent duplicate entries
);


-- Exploring data

SELECT * -- small table no null
FROM city_target_passenger_rating;

SELECT * -- small table no null
FROM monthly_target_new_passengers;

SELECT * -- small table no null
FROM monthly_target_trips;

-- Further analysis is conducted in the trips file 






