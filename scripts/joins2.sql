--1. Give the name, release year, and worldwide gross of the lowest grossing movie.
SELECT 	film_title, 
		release_year, 
		worldwide_gross
FROM specs
LEFT JOIN revenue
ON specs.movie_id = revenue.movie_id
ORDER BY worldwide_gross;

-- Semi-Tough, 1977, with 37 million grossing

--2. What year has the highest average imdb rating?
SELECT
	release_year,
	AVG(imdb_rating)
FROM specs AS s
LEFT JOIN rating AS r
ON s.movie_id=r.movie_id
GROUP BY release_year
ORDER BY AVG(imdb_rating) DESC;

--1991 had the highest average imdb rating.

--3. What is the highest grossing G-rated movie? Which company distributed it?
SELECT
	film_title,
	mpaa_rating,
	worldwide_gross,
	company_name
FROM specs AS s
	LEFT JOIN revenue as rev
	ON s.movie_id = rev.movie_id
	LEFT JOIN distributors as d
	ON s.domestic_distributor_id = d.distributor_id
WHERE mpaa_rating = 'G'
ORDER BY worldwide_gross DESC;

--Toy Story 4 is the highest grossing G rated movie. It was distributed by Disney

--4. Write a query that returns, for each distributor in the distributors table, the distributor name and the number of movies associated with that distributor in the movies table. Your result set should include all of the distributors, whether or not they have any movies in the movies table.

SELECT
	company_name,
	COUNT(film_title) AS total
FROM distributors AS d
	FULL JOIN specs AS s
	ON d.distributor_id=s.domestic_distributor_id
GROUP BY company_name
ORDER BY total;

--5. Write a query that returns the five distributors with the highest average movie budget.

SELECT
	company_name,
	AVG(film_budget) AS budget 
FROM distributors AS d
	LEFT JOIN specs AS s
	ON d.distributor_id = s.domestic_distributor_id
	LEFT JOIN revenue AS r
	ON s.movie_id=r.movie_id
WHERE film_budget IS NOT NULL
GROUP BY company_name
ORDER BY budget DESC
LIMIT 5;


--6. How many movies in the dataset are distributed by a company which is not headquartered in California? Which of these movies has the highest imdb rating?

SELECT 
	COUNT(film_title) total,
	film_title,
	imdb_rating,
	company_name
FROM specs AS s
	LEFT JOIN distributors as d
	ON s.domestic_distributor_id=d.distributor_id
	LEFT JOIN rating as r
	ON s.movie_id= r.movie_id
WHERE headquarters NOT LIKE '%CA'
GROUP BY imdb_rating, company_name, film_title
ORDER BY total DESC;

--2 movies were distributed by a company outside CA. The one with the highest imdb rating was Dirty Dancing. 

--7. Which have a higher average rating, movies which are over two hours long or movies which are under two hours?


--This is my 2nd, improved version

SELECT
	(CASE WHEN length_in_min>=121 THEN '2hrs or more'
		 ELSE 'Under 2hrs' END) AS time,
	AVG(imdb_rating) AS avg_rating
FROM specs AS s
	LEFT JOIN rating AS r
	ON s.movie_id=r.movie_id
GROUP BY time
ORDER BY avg_rating DESC;


SELECT
	COUNT(film_title),
	AVG(imdb_rating) AS avg_rating
FROM specs AS s
	LEFT JOIN rating AS r
	ON s.movie_id=r.movie_id
GROUP BY length_in_min>=121
ORDER BY avg_rating DESC;

--Movies that are 121 minutes or more have a higher rating.





SELECT 
'Greater than 120' type,
	COUNT(film_title), 
	AVG(imdb_rating) AS avg_rating
FROM specs AS s
	LEFT JOIN rating AS r
	ON s.movie_id=r.movie_id
WHERE length_in_min >= 121
UNION
SELECT 
'Lesser than 120' type,
	COUNT(film_title), 
	AVG(imdb_rating) AS avg_rating
FROM specs AS s
	LEFT JOIN rating AS r
	ON s.movie_id=r.movie_id
WHERE length_in_min <= 120
ORDER BY avg_rating DESC;

--Movies that are 120 minutes or more have a higher rating.

--Bonus
--1.	Find the total worldwide gross and average imdb rating by decade. Then alter your query so it returns JUST the second highest average imdb rating and its decade. This should result in a table with just one row.

WITH d AS (SELECT
	SUM(worldwide_gross) AS totalgross,
	ROUND(AVG(imdb_rating),2) AS avg_imdb,
	CASE WHEN release_year BETWEEN 1970 AND 1979 THEN '1970s'
	WHEN release_year BETWEEN 1980 AND 1989 THEN '1980s'
	WHEN release_year BETWEEN 1990 AND 1999 THEN '1990s'
	WHEN release_year BETWEEN 2000 AND 2009 THEN '2000s'
	ELSE '2010s' END AS decade,
	RANK() OVER(ORDER BY ROUND(AVG(imdb_rating),2) DESC) AS ranking
FROM specs AS s
	LEFT JOIN revenue AS rev
	ON s.movie_id = rev.movie_id
	LEFT JOIN rating AS rat
	ON s.movie_id = rat.movie_id
GROUP BY decade
ORDER BY avg_imdb DESC)
SELECT 
	d.totalgross,
	d.avg_imdb,
	d.decade
FROM d
WHERE ranking=2;

--2.	Our goal in this question is to compare the worldwide gross for movies compared to their sequels.   
	--a.	Start by finding all movies whose titles end with a space and then the number 2.
SELECT LOWER(TRIM(film_title)) 
FROM specs
WHERE film_title LIKE '%2'
	
	--b.	For each of these movies, create a new column showing the original film’s name by removing the last two characters of the film title. For example, for the film “Cars 2”, the original title would be “Cars”. Hint: You may find the string functions listed in Table 9-10 of https://www.postgresql.org/docs/current/functions-string.html to be helpful for this.
SELECT 
	LOWER(TRIM(film_title)),
	LOWER(rTRIM(film_title, '% 2')), 
		  rTRIM(film_title, POSITION())
FROM specs
WHERE film_title LIKE '%2' OR film_title ILIKE '%: part 2'
	--c.	Bonus: This method will not work for movies like “Harry Potter and the Deathly Hallows: Part 2”, where the original title should be “Harry Potter and the Deathly Hallows: Part 1”. Modify your query to fix these issues.  
	--d.	Now, build off of the query you wrote for the previous part to pull in worldwide revenue for both the original movie and its sequel. Do sequels tend to make more in revenue? Hint: You will likely need to perform a self-join on the specs table in order to get the movie_id values for both the original films and their sequels. Bonus: A common data entry problem is trailing whitespace. In this dataset, it shows up in the film_title field, where the movie “Deadpool” is recorded as “Deadpool “. One way to fix this problem is to use the TRIM function. Incorporate this into your query to ensure that you are matching as many sequels as possible.
	
	