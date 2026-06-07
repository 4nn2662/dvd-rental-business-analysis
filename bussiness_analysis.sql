-- Author: Anna Mazur
--Description
--Collection of bussiness-oriented SQL queries created to analyse customer behaviour, revenue and rental activitiy using the DVD Rental sample database.

-------------------------------------------------------

-- 1. Which customers spent the most money?
SELECT 
	c.customer_id, 
	c.first_name,
	c.last_name,
	SUM(amount) AS total_spent
FROM customer c
INNER JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY 
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY total_spent DESC;

-- 2. Which customers rented the most movies?
SELECT 
	c.customer_id, 
	c.first_name,
	c.last_name,
	COUNT(*) AS total_rentals
FROM customer c
INNER JOIN rental r
  ON c.customer_id = r.customer_id
GROUP BY 
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY total_rentals DESC;

-- 3. Which customers never rented a movie?
SELECT 
	c.customer_id, 
	c.first_name,
	c.last_name
FROM customer c
LEFT JOIN rental r
  ON c.customer_id = r.customer_id
WHERE r.rental_id IS NULL;

-- 4. Which customers never made a payment?
SELECT 
	c.customer_id, 
	c.first_name,
	c.last_name
FROM customer c
LEFT JOIN payment p
  ON c.customer_id = p.customer_id
WHERE p.payment_id IS NULL;

-- 5. Which customers never made a payment?
SELECT 
	c.customer_id, 
	c.first_name,
	c.last_name
FROM customer c
LEFT JOIN payment p
  ON c.customer_id = p.customer_id
WHERE p.payment_id IS NULL;

-- 6. Which movie rating are most common?
SELECT
	rating,
COUNT(*) AS total_movies
FROM film
GROUP BY rating
ORDER BY total_movies DESC;

--7. Classify movies based on their duration.
SELECT 
	title,
	length,
CASE
	WHEN length < 60 THEN 'Short'
	WHEN length BETWEEN 60 and 90 THEN 'Medium'
	ELSE 'Long'
END AS movie_length
FROM film;

-- 8. Clasify customers based on total spending.
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
	SUM(p.amount) AS total_spent,
CASE
	WHEN SUM(p.amount) >= 150 THEN 'High Value'
	WHEN SUM(p.amount) >= 100 THEN 'Medium Value'
	ELSE 'Low Value'
END AS customer_segment
FROM customer c
INNER JOIN payment p
  ON c.customer_id = p.customer_id
GROUP BY
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY total_spent DESC;

-- 9. Clasify customers based on the numbers of rentals.
SELECT
	c.customer_id,
	c.first_name,
	c.last_name,
COUNT(r.rental_id) AS total_rentals,
CASE
	WHEN COUNT(r.rental_id) >= 40 THEN 'Frequent Customer'
	WHEN COUNT(r.rental_id) >= 20 THEN 'Regular Customer'
	ELSE 'Occasional Customer'
END AS customer_type
FROM customer c
INNER JOIN rental r
  ON c.customer_id = r.customer_id
GROUP BY
	c.customer_id,
	c.first_name,
	c.last_name
ORDER BY total_rentals DESC;

-- 10. Which movies have never been rented?
SELECT 
	f.title
FROM film f
LEFT JOIN inventory i
  ON f.film_id = i.film_id
LEFT JOIN rental r
  ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;

-- 11. WHich mocie categories generate the highest revenue?
SELECT
	c.name AS category,
	SUM(p.amount) AS total_revenue
FROM payment p
INNER JOIN rental r
	ON p.rental_id = r.rental_id
INNER JOIN inventory i
	ON r.inventory_id = i.inventory_id
INNER JOIN film_category fc
	ON i.film_id = fc.film_id
INNER JOIN category c
	ON fc.film_id = c.category_id
GROUP BY c.name
ORDER BY total_revenue DESC;

--12. Top 10 movies generating the highest revenue 
SELECT
	f.title,
	SUM(p.amount) AS total_revenue
FROM payment p
INNER JOIN rental r
	ON p.rental_id = r.rental_id
INNER JOIN inventory i
	ON r.inventory_id = i.inventory_id
INNER JOIN film f
	ON i.film_id = f.film_id
GROUP BY f.title
ORDER BY total_revenue DESC
LIMIT 10;

--13. Which customers soent more than average customer?
WITH customer_spending AS (
  SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(p.amount) AS total_spent
  FROM customer c
  INNER JOIN payment p
    ON c.customer_id = p.customer_id
  GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name
)
SELECT
  customer_id,
  first_name,
  last_name,
  total_spent
FROM customer_spending
WHERE total_spent >
  (
  SELECT AVG(total_spent)
  FROM customer_spending
  )
ORDER BY total_spent DESC;

