-- Author: Anna Mazur
--Description
--Collection of bussiness-oriented SQL queries created to analyse customer behaviour, revenue and rental activitiy using the DVD Rental sample database.

-------------------------------------------------------

-- 1. Which customers spent the most money?
-- Purpose: 
-- Identify the highest-value customers who could be targeted with loyalty programs os personalized marketing campaigns.
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
-- Purpose: Analyze customer engagement and identify th emost active customers based on rental frequency.
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
-- Purpose: FInd inactive customers who may require re-engagement campaigns or pormotional offers.
SELECT 
	c.customer_id, 
	c.first_name,
	c.last_name
FROM customer c
LEFT JOIN rental r
  ON c.customer_id = r.customer_id
WHERE r.rental_id IS NULL;

-- 4. Which customers never made a payment?
-- Purpose: Detected customers with no recorded payments and verify potential potential data quality issues or inactive accounts.
SELECT 
	c.customer_id, 
	c.first_name,
	c.last_name
FROM customer c
LEFT JOIN payment p
  ON c.customer_id = p.customer_id
WHERE p.payment_id IS NULL;

-- 5. What is the average payment amount per customer?
-- Purpose: Measure customer spending patterns and compare average transaction values across the customer base.
SELECT 
	customer_id, 
	AVG(amount) AS average_payment
FROM payment
GROUP BY customer_id
ORDER BY average_payment DESC;

-- 6. Which movie rating are the most common?
-- Purpose:  Understand the distribution of movie ratings available in the catalog.
SELECT
	rating,
COUNT(*) AS total_movies
FROM film
GROUP BY rating
ORDER BY total_movies DESC;

--7. Classify movies based on their duration.
-- Purpose: Categorize movies into duration groups for reporting and further business analysis.
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
-- Purpose: Divide customers into value segments to support marketing and customer retention strategies.
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

-- 9. How can customers be segmented based on rental activity?
-- Purpose: Classify customers according to their rental frequency to better understand customer behaviour.
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
-- Purpose: Identify underperforming titles that may require promotional actions or catalog review.
SELECT 
	f.title
FROM film f
LEFT JOIN inventory i
  ON f.film_id = i.film_id
LEFT JOIN rental r
  ON i.inventory_id = r.inventory_id
WHERE r.rental_id IS NULL;

-- 11. Which movie categories generate the highest revenue?
--Purpose: Determine the most profitable categories to support content acquisition and business decisions.
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
	ON fc.category_id = c.category_id
GROUP BY c.name
ORDER BY total_revenue DESC;

--12. Top 10 movies generating the highest revenue 
-- Purpose Identify top-performing movies and evaluate their contribution to total revenue.
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

--13.  Which customers spend more than the average customer?
-- Purpose: Identify above-average customers who may represent the company's most valuable customer segment.
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

