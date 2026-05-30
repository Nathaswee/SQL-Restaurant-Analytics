CREATE DATABASE CONSUMERDB;
USE CONSUMERDB;  


CREATE TABLE consumers (
    Consumer_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    Latitude DECIMAL(10, 7),
    Longitude DECIMAL(10, 7),
    Smoker VARCHAR(10),
    Drink_Level VARCHAR(20),
    Transportation_Method VARCHAR(20),
    Marital_Status VARCHAR(20),
    Children VARCHAR(20),
    Age INT,
    Occupation VARCHAR(50),
    Budget VARCHAR(20)
);
 SELECT * FROM CONSUMERS;
 
CREATE TABLE restaurants (
    Restaurant_ID INT PRIMARY KEY,
    Name VARCHAR(100),
    City VARCHAR(50),
    State VARCHAR(50),
    Country VARCHAR(50),
    Zip_Code VARCHAR(20),
    Latitude DECIMAL(10, 7),
    Longitude DECIMAL(10, 7),
    Alcohol_Service VARCHAR(20),
    Smoking_Allowed VARCHAR(20),
    Price VARCHAR(10),
    Franchise VARCHAR(5),
    Area VARCHAR(10),
    Parking VARCHAR(20)
);

SELECT*FROM RESTAURANTS;

CREATE TABLE consumer_preferences (
    Consumer_ID VARCHAR(10),
    Preferred_Cuisine VARCHAR(100),
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID)
);

SELECT* FROM consumer_preferences;

CREATE TABLE restaurant_cuisines (
    Restaurant_ID INT,
    Cuisine VARCHAR(100),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)
);

SELECT* FROM restaurant_cuisines;


CREATE TABLE ratings (
    Consumer_ID VARCHAR(10),
    Restaurant_ID INT,
    Overall_Rating INT,
    Food_Rating INT,
    Service_Rating INT,
    FOREIGN KEY (Consumer_ID) REFERENCES consumers(Consumer_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES restaurants(Restaurant_ID)
);

SELECT*FROM ratings;

   -- Using the WHERE clause to filter data based on specific criteria.--
-- List all details of consumers who live in the city of 'Cuernavaca'--
SELECT*FROM CONSUMERS
WHERE CITY ='CUERNAVACA';

-- Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.--
SELECT  Consumer_ID, Age, Occupation FROM consumers
WHERE Occupation = 'STUDENT' AND SMOKER = 'YES';

-- List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.--
SELECT NAME,CITY,ALCOHOL_SERVICE,PRICE FROM RESTAURANTS
WHERE ALCOHOL_SERVICE = 'WINE & BEER' AND PRICE = 'MEDIUM';

-- Find the names and cities of all restaurants that are part of a 'Franchise' --
SELECT NAME,CITY FROM RESTAURANTS
WHERE FRANCHISE = 'YES';

-- Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the data dictionary) --
SELECT Consumer_ID, Restaurant_ID, Overall_Rating FROM RATINGS
WHERE OVERALL_RATING = 2;


         -- Questions JOINs with Subqueries --
-- List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer. --
SELECT restaurants.Name, restaurants.City
from  restaurants
INNER JOIN ratings
ON restaurants.Restaurant_ID = ratings.Restaurant_ID
WHERE ratings.Overall_Rating = 2;

-- Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
SELECT DISTINCT consumers.Consumer_ID, consumers.Age
FROM consumers
INNER JOIN ratings ON consumers.Consumer_ID = ratings.Consumer_ID
INNER JOIN restaurants ON ratings.Restaurant_ID = restaurants.Restaurant_ID
WHERE restaurants.City = 'San Luis Potosi';

-- List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
SELECT distinct restaurants.NAME FROM restaurants
INNER JOIN restaurant_cuisines 
ON restaurants.restaurant_ID = restaurant_cuisines.restaurant_ID
INNER JOIN RATINGS 
ON restaurants.restaurant_ID = RATINGS.restaurant_ID
WHERE restaurant_cuisines.cuisine = 'MEXICAN'
AND RATINGS.CONSUMER_ID = 'U1001';

-- Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget --
SELECT CONSUMERS.* FROM CONSUMERS
INNER JOIN CONSUMER_PREFERENCES 
ON CONSUMERS.CONSUMER_ID = CONSUMER_PREFERENCES.CONSUMER_ID
WHERE CONSUMER_PREFERENCES.Preferred_Cuisine = 'American'
AND CONSUMERS.BUDGET = 'Medium' ;

-- List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
SELECT distinct restaurants.NAME,restaurants.CITY FROM restaurants
INNER JOIN RATINGS 
ON restaurants.restaurant_ID = RATINGS.restaurant_ID
WHERE RATINGS.FOOD_RATING < (SELECT AVG(FOOD_RATING) FROM RATINGS);


-- Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
select distinct CONSUMERS.CONSUMER_ID, CONSUMERS.AGE, CONSUMERS.OCCUPATION FROM CONSUMERS
WHERE consumers.Consumer_ID IN (SELECT Consumer_ID FROM ratings)
AND consumers.Consumer_ID NOT IN (
    SELECT ratings.Consumer_ID 
    FROM ratings
    INNER JOIN restaurant_cuisines ON ratings.Restaurant_ID = restaurant_cuisines.Restaurant_ID
    WHERE restaurant_cuisines.Cuisine = 'Italian'
);


-- List restaurants (Name) that have received ratings from consumers older than 30.
SELECT DISTINCT restaurants.Name
FROM restaurants
INNER JOIN ratings ON restaurants.Restaurant_ID = ratings.Restaurant_ID
INNER JOIN consumers ON ratings.Consumer_ID = consumers.Consumer_ID
WHERE consumers.Age > 30;


-- Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
SELECT DISTINCT consumers.Consumer_ID, consumers.Occupation
FROM consumers
INNER JOIN consumer_preferences ON consumers.Consumer_ID = consumer_preferences.Consumer_ID
INNER JOIN ratings ON consumers.Consumer_ID = ratings.Consumer_ID
WHERE consumer_preferences.Preferred_Cuisine = 'Mexican' 
AND ratings.Overall_Rating = 0;


-- List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
SELECT DISTINCT restaurants.Name, restaurants.City
FROM restaurants
INNER JOIN restaurant_cuisines ON restaurants.Restaurant_ID = restaurant_cuisines.Restaurant_ID
WHERE restaurant_cuisines.Cuisine = 'Pizzeria' 
AND restaurants.City IN (SELECT City FROM consumers WHERE Occupation = 'Student');

-- Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
SELECT DISTINCT consumers.Consumer_ID, consumers.Age
FROM consumers
INNER JOIN ratings ON consumers.Consumer_ID = ratings.Consumer_ID
INNER JOIN restaurants ON ratings.Restaurant_ID = restaurants.Restaurant_ID
WHERE consumers.Drink_Level = 'social drinker' 
AND restaurants.Parking = 'None';

-- Questions Emphasizing WHERE Clause and Order of Execution
SELECT consumers.Consumer_ID, COUNT(ratings.Restaurant_ID) AS Restaurants_Rated
FROM consumers
INNER JOIN ratings ON consumers.Consumer_ID = ratings.Consumer_ID
WHERE consumers.Occupation = 'Student'
GROUP BY consumers.Consumer_ID
HAVING COUNT(ratings.Restaurant_ID) > 2;


-- List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. Show only students who have rated more than 2 restaurants.
SELECT consumer_preferences.Preferred_Cuisine, COUNT(*) AS Preference_Count
FROM consumer_preferences
INNER JOIN consumers ON consumer_preferences.Consumer_ID = consumers.Consumer_ID
WHERE consumers.Budget = 'High'
GROUP BY consumer_preferences.Preferred_Cuisine
ORDER BY Preference_Count DESC
LIMIT 3;