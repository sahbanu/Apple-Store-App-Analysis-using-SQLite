** IMPORTING DATASETS **
CREATE TABLE appleStore_decription_combined AS
SELECT * FROM appleStore_description1
UNION ALL
SELECT * FROM appleStore_description2
UNION ALL
SELECT * FROM appleStore_description3
UNION ALL
SELECT * FROM appleStore_description4

** EXPLORATORY DATA ANALYSIS **

-- Check the number of unique apps in both tablesAppleStore 
SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM AppleStore

SELECT COUNT(DISTINCT id) AS UniqueAppIDs
FROM appleStore_decription_combined

-- Check for any missing values in key fields
Select Count (*) AS MissingValues
FROM AppleStore
WHERE track_name Is Null OR user_rating IS NULL or prime_genre IS NULL

Select Count (*) AS MissingValues
FROM appleStore_decription_combined
WHERE app_desc Is Null 

-- Find the number of apps per genre
SELECT prime_genre, COUNT(*) As NumApps
FROM AppleStore
GROUP By prime_genre
ORDER BY NumApps DESC

-- Get an overview of the apps ratings
SELECT min(user_rating) AS MinRating,
       max(user_rating) As MaxRating,
       avg(user_rating) AS AvgRating
FROM AppleStore

-- Get the distribution of app prices
SELECT
	(price/2)*2 As PriceBinStart,
    ((price/2)*2)+2 AS PriceBinEnd,
    Count(*) AS NumApps
FROM AppleStore
Group By PriceBinStart
ORDER By PriceBinStart

** DATA ANALYSIS **
-- Determine whether paid apps have higher rating than free apps 
Select Case 
			When price > 0 THEN 'Paid'
            ELSE 'Free'
       END As App_Type,
       avg(user_rating) As Avg_Rating
FROM AppleStore
Group By App_Type

-- Determine whether apps with more supported languages have higher ratings 
SELECT CASE
			When lang_num < 10 THEN '<10 languages'
            When lang_num BETWEEN 10 and 30 THEN '10-30 languages'
            Else '>30 languages'
       End As language_bucket,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
Group By language_bucket
Order BY Avg_Rating DESC

-- Check which genre has low ratings 
SELECT prime_genre,
       avg(user_rating) AS Avg_Rating
FROM AppleStore
GROUP BY prime_genre
Order By Avg_rating ASC 
LIMIT 10 

-- Check if there is a correlation between the app description length and user rating 
SELECT CASE
			WHEN length(b.app_desc) <500 THEN 'Short'
            WHEN length(b.app_desc) BETWEEN 500 AND 1000 THEN 'Medium'
            Else 'Long'
       END As description_length_bucket,
       avg(a.user_rating) AS Avg_rating
FROM
    AppleStore aS a 
JOIN
    appleStore_decription_combined AS b 
on 
   a.id = b.id
Group BY description_length_bucket
Order By Avg_rating DESC

-- Check the top rated app for each genre 
Select 
	prime_genre,
    track_name,
    user_rating
FROM (
  		SELECT
  		prime_genre,
  		track_name,
  		user_rating,
  		RANK() OVER ( PARTITION BY prime_genre ORDER BY user_rating DESC, rating_count_tot DESC) AS rank
  		FROM
  		AppleStore
       ) AS a 
WHERE 
a.rank=1


    