-- Use database Sakila
USE sakila;

-- 1a - Display Actor first and last name - from table actor
SELECT first_name, last_name
FROM actor;

-- 1b - Concatenated upper case first and last name of actor
SELECT UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM actor;

-- 2a - Find actor with first name Joe
SELECT actor_id, first_name, last_Name
FROM actor
WHERE first_name = "Joe";

-- 2b - Identify all actors whose last name contains GEN
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c - Identify all actors whose last name contains LI - sorted in alphabetic order
SELECT actor_id, last_name, first_name 
FROM actor
WHERE last_name LIKE "%LI%"
ORDER BY last_name ASC, first_name ASC;

-- 3a - Add column "description" to table actor of blob type
ALTER TABLE actor
ADD COLUMN description BLOB
AFTER last_update;

SELECT * 
FROM actor;

-- 3b - Delete column "description"
ALTER TABLE actor
DROP COLUMN description;

SELECT * 
FROM actor;

-- 4a -  list last names and counts by last name of actors
SELECT last_name, COUNT(last_name) AS 'Number of actors w/last name'
FROM actor
GROUP BY last_name;

-- 4b -  list last names and counts by last name of actors with shared last names
SELECT last_name, COUNT(last_name) AS 'Number of actors w/last name'
FROM actor
GROUP BY last_name HAVING COUNT(last_name) > 1;

-- 4c - Update "GROUCHO WILLIAMS" to "HARPO WILLIAMS"
SELECT first_name, last_name
FROM actor
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

UPDATE actor
SET first_name='HARPO'
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

SELECT first_name, last_name
FROM actor
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

-- 4d - identify HARPO WILLIAMS and update back to GROUCHO WILLIAMS
SELECT first_name, last_name
FROM actor
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

UPDATE actor
SET first_name='GROUCHO'
WHERE first_name = "HARPO" AND last_name = "WILLIAMS";

SELECT first_name, last_name
FROM actor
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 5a - schema of address table
SHOW CREATE TABLE address;

-- 6a - first and last names with addresses using staff and address
SELECT s.staff_id, s.first_name, s.last_name, a.address_id, a.address, a.address2, c.city, a.postal_code
FROM staff s
JOIN address a
ON s.address_id=a.address_id
JOIN city c
ON c.city_id=a.city_id;

-- 6b total amount rung up by each staff member in Aug 2005
SELECT s.staff_id, s.first_name, s.last_name, sum(p.amount) AS sales_amount
FROM staff s
JOIN payment p
ON s.staff_id=p.staff_id
GROUP BY staff_id;

-- 6c - films and number of actors listed in film - inner join
SELECT f.film_id, f.title, count(fa.actor_id) as "Number of Actors"
FROM film f
INNER JOIN film_actor fa
ON f.film_id=fa.film_id
GROUP BY f.film_id;

-- 6d - Number of copies of "Hunchback Impossible" in inventory
SELECT f.title, COUNT(*) AS "Number of Copies"
FROM film f
JOIN  inventory i
ON f.film_id = i.film_id
WHERE  f.title = 'Hunchback Impossible';

-- 6e - Total paid by customer alphabetically
SELECT c.first_name, c.last_name, SUM(p.amount) AS "Total Amount Paid"
FROM customer c
JOIN payment p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name ASC, c.first_name ASC;

-- 7a - Movies starting with 'k' or 'q' and language English
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%') AND language_id = 
	(SELECT language_id
    FROM language
    WHERE name = "English");

-- 7b - All actors who appear in "Alone Trip"
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
   SELECT actor_id
   FROM film_actor
   WHERE film_id IN
   (
      SELECT film_id
      FROM film
      WHERE title = 'Alone Trip'
	)
);

-- 7c - Email campaign for Canadian customers
SELECT c.customer_id, c.first_name, c.last_name, c.email
FROM customer c
JOIN address a 
ON c.address_id = a.address_id
JOIN city ct
ON a.city_id = ct.city_id
JOIN country ctry
ON ct.country_id = ctry.country_id
WHERE country = "Canada";

-- 7d - Identify all films tagged as "family"
-- join film to film_category to category and select category of family
SELECT f.film_id, f.title
FROM film f
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category cat
ON fc.category_id = cat.category_id
WHERE name = "Family";

-- 7e - Most frequently rented movies in descending order
-- join film to inventory to rental, group by film ID and count number of rentals by rental_id
SELECT f.film_id, f.title, COUNT(r.rental_id) AS "Number rentals"
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY COUNT(r.rental_id) DESC;

			-- list only the top 10 rentals - sub portion of 7e
SELECT f.film_id, f.title, COUNT(r.rental_id) AS "Number rentals" 
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
GROUP BY f.film_id
ORDER BY COUNT(r.rental_id) DESC
LIMIT 10;

-- 7f - Amount of business in dollars each store brought insert
-- join film to inventory to rental to payment and sum amout by store ID
SELECT i.store_id, SUM(p.amount) AS "Total Store Sales" 
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
GROUP BY i.store_id;

-- 7g - select each store ID, city and country
-- join store, address, city, and country
SELECT s.store_id, a.address, c.city, ctry.country, a.postal_code
FROM store s
JOIN address a
ON s.address_id = a.address_id
JOIN city c
ON a.city_id = c.city_id
JOIN country ctry
ON c.country_id=ctry.country_id;

-- 7h - List top 5 genres in gross revenue in descending order
-- join film, film_category, category, inventory, payment, and rental
SELECT cat.category_id, cat.name, SUM(p.amount) AS "Total Gross Revenue" 
FROM film f
JOIN inventory i
ON f.film_id = i.film_id
JOIN rental r
ON i.inventory_id = r.inventory_id
JOIN payment p
ON p.rental_id = r.rental_id
JOIN film_category fc
ON f.film_id = fc.film_id
JOIN category cat
ON fc.category_id = cat.category_id
GROUP BY cat.category_id
ORDER BY SUM(p.amount) DESC
LIMIT 5;

-- 8a - create view of total gross revenues of top 5 genres
CREATE VIEW vw_genre_top_5_gross_revenue
AS
SELECT cat.category_id, cat.name, SUM(p.amount) AS "Total Gross Revenue" 
	FROM film f
	JOIN inventory i
	ON f.film_id = i.film_id
	JOIN rental r
	ON i.inventory_id = r.inventory_id
	JOIN payment p
	ON p.rental_id = r.rental_id
	JOIN film_category fc
	ON f.film_id = fc.film_id
	JOIN category cat
	ON fc.category_id = cat.category_id
	GROUP BY cat.category_id
	ORDER BY SUM(p.amount) DESC
	LIMIT 5;
    
-- 8b - display view from 8a
SELECT * FROM vw_genre_top_5_gross_revenue;

-- 8c - delete view vwF_genre_top_5_gross_revenue
DROP VIEW IF EXISTS vw_genre_top_5_gross_revenue;

