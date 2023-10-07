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

SELECT 
'Highest' type,
	COUNT(film_title), 
	AVG(imdb_rating) AS avg_rating
FROM specs AS s
	LEFT JOIN rating AS r
	ON s.movie_id=r.movie_id
WHERE length_in_min >= 120
UNION
SELECT 
'Lowest' type,
	COUNT(film_title), 
	AVG(imdb_rating) AS avg_rating
FROM specs AS s
	LEFT JOIN rating AS r
	ON s.movie_id=r.movie_id
WHERE length_in_min < 120
ORDER BY avg_rating DESC;

--Movies that are 120 minutes or more have a higher rating.