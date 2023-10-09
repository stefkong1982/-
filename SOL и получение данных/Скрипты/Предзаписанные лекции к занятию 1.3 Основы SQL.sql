SELECT
    film.title AS "Film Title",
    language.name AS "Language"
FROM
    film
JOIN
    language ON film.language_id = language.language_id;


SELECT
    actor.first_name as "first_name",
    actor.last_name as "last_name",
    film.title as "film_title"
FROM
    actor
JOIN
    film_actor ON film_actor.actor_id  = actor.actor_id
JOIN
    film ON film.film_id = film_actor.film_id 
WHERE
    film.title = 'LAMBS CINCINATTI';

select count(film_actor.actor_id)  
from film
join film_actor on film_actor.film_id = film.film_id 
where film_actor.film_id = 384

select count(actor_id)  
from film_actor
where film_actor.film_id = 384

SELECT film.film_id, film.title 
FROM film
JOIN (
    SELECT film_id, COUNT(actor_id) AS actor_count
    FROM film_actor
    GROUP BY film_id
) subq ON film.film_id = subq.film_id
WHERE subq.actor_count > 10;

SELECT film.title, count(film_actor.actor_id), film.description 
FROM film
join film_actor on film_actor.film_id = film.film_id
group by film.film_id 
having count(film_actor.actor_id) > 10;

SELECT film_actor.film_id, COUNT(film_actor.actor_id), film.description, film.title 
FROM film_actor
join film on film.film_id = film_actor.film_id
GROUP BY film_actor.film_id, film.description, film.title 
HAVING COUNT(film_actor.actor_id) > 10;



