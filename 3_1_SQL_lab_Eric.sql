USE sakila;

-- 1. Drop column picture from staff.

SELECT * FROM sakila.staff;
ALTER TABLE staff
DROP COLUMN picture;

-- check
SELECT * FROM sakila.staff;

-- 2. A new person is hired to help Jon. Her name is TAMMY SANDERS, and she is a customer. Update the
-- database accordingly.

SELECT * FROM sakila.staff;
-- we see in the staff table that Jon works in the Store with id number 2
-- we need to get Tammy's personal details from the customer table
SELECT * FROM customer;
SELECT * FROM customer WHERE (first_name = 'tammy' and last_name = 'SANDERS');

-- we see from the data diagram that the last_update is a timestamp, so it should bt put in automatically
-- for the rest, first)name & last_name are obvious, I just appy the same format logiic as for Mike or Jon
-- for the email address, and usernam as well, same logic as Mike & Jon. Address_id comes from the customer table
INSERT INTO staff (staff_id, first_name, last_name, address_id, email, store_id, active, username)
VALUES
(3, 'Tammy', 'Sanders', 79, 'Tammy.Sanders@sakilastaff.com', 2, 1, 'Tammy');

SELECT * FROM STAFF;
-- it worked.alter

-- 3. Add rental for movie "Academy Dinosaur" by Charlotte Hunter from Mike Hillyer at Store 1. You can use
-- current date for the rental_date column in the rental table. Hint: Check the columns in the table rental and
-- see what information you would need to add there. You can query those pieces of information. For eg., you would
-- notice that you need customer_id information as well.

SELECT * FROM sakila.rental;

select customer_id from sakila.customer
where first_name = 'CHARLOTTE' and last_name = 'HUNTER';
-- output --> suctomer id = 130

-- we need the film_id to find the right inventory_id
SELECT film_id FROM sakila.film
WHERE title = 'Academy Dinosaur';
-- output --> film_id = 1

select inventory_id from sakila.inventory
WHERE film_id = 1 and store_id = 1;
-- output shows multiple copies of the movie, with inventory_id's 1, 2, 3 and 4

-- Trial : see if nested loop would work here
select inventory_id from sakila.inventory
WHERE store_id = 1 AND film_id = (SELECT film_id FROM sakila.film WHERE title = 'Academy Dinosaur');
-- IT WORKS !!

-- Let's check if all of the physical copies are available or not :
-- "manual" query first
SELECT * FROM sakila.rental
WHERE inventory_id IN (1, 2, 3, 4)
ORDER BY inventory_id, rental_date DESC;
-- all the rentals have a return date, so all of the four copies are available for rent, so the new rental can
-- be made on any of the 4 copies

-- "automated" query with subqueries
SELECT * FROM sakila.rental
WHERE inventory_id IN (
	SELECT inventory_id
    FROM sakila.inventory
	WHERE store_id = 1 AND film_id = (SELECT film_id FROM sakila.film WHERE title = 'Academy Dinosaur')
	)
ORDER BY inventory_id, rental_date DESC;


INSERT INTO rental (inventory_id, customer_id, staff_id)
VALUES (1, 130, 1);

SELECT * FROM sakila.rental
ORDER BY rental_id DESC
LIMIT 1;
-- seems to have worked !


-- ACTIVITY 2

-- Structural improvement propositions for the Sakila database :

-- 1. get rid of the film_category table. Each film_id has one and only category_id allocated in the 
-- film_category table, so we could directly indicate the category_id in the film table

-- 2. get rid of the film_text table, which only contains data that is already in the film table

-- 3. I feel the store id is present too often and somehow inteferes with the staff_id, customer_id and inventory_id
-- which are all store bounded but all end up in the rental table for example. Maybe there is something there that
-- can be optimized.