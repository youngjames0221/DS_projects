/* SQL Project - investigate a relational database */

/* Query for first insight */
SELECT category_name,
       SUM(rental_count) AS rental_count
FROM (SELECT f.title AS film_title,
             c.name AS category_name,
             COUNT(*) AS rental_count
      FROM film f
      JOIN inventory i
      ON f.film_id = i.film_id
      JOIN rental r
      ON i.inventory_id = r.inventory_id
      JOIN film_category fc
      ON f.film_id = fc.film_id
      JOIN category c
      ON c.category_id = fc.category_id
      WHERE c.name = 'Animation'
         OR c.name = 'Classics'
         OR c.name = 'Children'
         OR c.name = 'Family'
         OR c.name = 'Music'
         OR c.name = 'Comedy'
      GROUP BY 1, 2) category_count
GROUP BY 1
ORDER BY 2 DESC;

/* Query for second insight */
WITH film_duration AS
      (SELECT f.title AS film_title,
              c.name AS category_name,
              f.rental_duration AS rental_duration,
              NTILE(4) OVER (ORDER BY rental_duration) AS standard_quartile
       FROM film f
       JOIN film_category fc
       ON f.film_id = fc.film_id
       JOIN category c
       ON c.category_id = fc.category_id
       WHERE c.name = 'Animation'
          OR c.name = 'Classics'
          OR c.name = 'Children'
          OR c.name = 'Family'
          OR c.name = 'Music'
          OR c.name = 'Comedy') -- Returns rental duration and corresponding quartiles of family movies
       SELECT category_name, standard_quartile, COUNT(*) AS count_quartile
       FROM film_duration
       GROUP BY 1, 2
       ORDER BY 1, 2; -- Counts the number of each category from film_duration subquery.

/* Query for third insight */
SELECT DATE_TRUNC('month', rental_date) AS Rental_month,
       store_id,
       COUNT(*)
FROM rental r
JOIN inventory i
ON r.inventory_id = i.inventory_id
GROUP BY 2,1
ORDER BY 3 DESC; -- Shows the month, year, and number of rentals from each store.

/* Query for fourth insight */
WITH top10 AS
      (SELECT DISTINCT customer_id,
                       SUM(amount) OVER (PARTITION BY customer_id) AS pay_amount
       FROM payment
       ORDER BY 2 DESC
       LIMIT 10) -- Returns customer_id of the top 10 paying customers.

SELECT DATE_PART('month', p.payment_date) pay_mon,
       CONCAT(first_name, ' ', last_name) AS fullname,
       COUNT(*) AS pay_countpermon,
       SUM(p.amount) AS pay_amount
FROM top10
JOIN payment p
ON top10.customer_id = p.customer_id
JOIN customer c
ON c.customer_id = p.customer_id
GROUP BY 1, 2
ORDER BY 2, 1; -- Returns the monthly payment information (amount, number of payments) of the top 10 paying customers.
