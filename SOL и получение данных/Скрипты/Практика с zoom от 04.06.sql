--ЗАДАНИЕ №1
--Выведите информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 
--0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.

explain analyze --77.50
select title, rating, rental_rate
from film 
where (rating = 'R' and rental_rate between 0. and 3.) or
	(rating = 'PG-13' and rental_rate >= 4.)
	
select title, rating, rental_rate
from film 
where 
	1 = 1 -> true
	and rating = 'R' 
	and rental_rate between 0. and 3.
	or rating = 'PG-13' 
	and rental_rate >= 4.

explain analyze --87.50
select title, rating, rental_rate
from film 
where (rating::text like 'R' and rental_rate between 0. and 3.) or
	(rating::text like 'PG-13' and rental_rate >= 4.)
	
explain analyze --152.58
select title, rating, rental_rate
from film 
where (rating::text like 'R' and rental_rate between 0. and 3.) 
union all 
select title, rating, rental_rate
from film 
where (rating::text like 'PG-13' and rental_rate >= 4.)

--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

select title, description, char_length(description)
from film 
order by char_length(description) desc
limit 3

select title, description, char_length(description)
from film 
order by char_length(description) desc
fetch first 3 rows with ties

--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.

explain analyze --17.98
select email, split_part(email, '@', 1), split_part(email, '@', 2)
from customer 

explain analyze --23.98
select email, 
	substring(email, 1, strpos(email, '@') - 1), 
	substring(email, strpos(email, '@') + 1)
from customer 

--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква строки должна быть заглавной, остальные строчными.

--ЛОЖНЫЙ ЗАПРОС
select email, 
	left(split_part(email, '@', 1), 1) || lower(right(split_part(email, '@', 1), - 1)),
	upper(left(split_part(email, '@', 2), 1)) || (right(split_part(email, '@', 2), - 1))
from customer 
order by customer_id

explain analyze --58.23
select email, 
	upper(left(split_part(email, '@', 1), 1)) || lower(right(split_part(email, '@', 1), - 1)),
	upper(left(split_part(email, '@', 2), 1)) || lower(right(split_part(email, '@', 2), - 1))
from customer 
order by customer_id

explain analyze --56.73
select email, 
	upper(left(email, 1)) || lower(right(split_part(email, '@', 1), - 1)),
	upper(left(split_part(email, '@', 2), 1)) || lower(right(split_part(email, '@', 2), - 1))
from customer 
order by customer_id

explain analyze --53.73
select email, 
	overlay(lower(split_part(email, '@', 1)) placing upper(left(email, 1)) from 1 for 1), 
	overlay(lower(split_part(email, '@', 2)) placing upper(left(split_part(email, '@', 2), 1)) from 1 for 1)
from customer
order by customer_id

explain analyze --56.73
SELECT customer_id, email,
	concat(upper(substring(email FROM 1 FOR 1)), lower(split_part (substring (email FROM 2), '@', 1))) AS e_name,
	concat(upper (substring(split_part(email, '@', 2), 1, 1)), lower(substring(split_part (email, '@', 2), 2))) AS e_address
FROM customer c
ORDER BY customer_id

explain analyze --52.23
select customer_id , email ,
upper (substring (email from '(.).*')) || lower (substring (email from '.(.*)@')) as email_part1 ,
upper (substring (email from '.*@(.).*')) || lower (substring (email from '.*@.(.*)')) as email_part2
from customer
order by customer_id

select email, 
	initcap(split_part(email, '@', 1)), 
	initcap(split_part(email, '@', 2))
from customer 
order by customer_id

SET search_path TO public

аренде 

01.01.2023 16:00 - 02.01.2023 10:00 

--ЗАДАНИЕ №1
--Посчитайте для каждого фильма сколько раз его брали в аренду и значение общей стоимости аренды фильма за всё время.

explain analyze --1743.69
select f.title, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join "language" l on f.language_id = l.language_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by f.film_id, l.language_id, c.category_id

explain analyze --1276.94
select f.title, l."name", c."name", count, sum
from film f
left join (
	select i.film_id, count(r.rental_id), sum(p.amount)
	from inventory i 
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	group by i.film_id) t on f.film_id = t.film_id
join "language" l on f.language_id = l.language_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

select f.title, string_agg(l."name", ', '), string_agg(c."name", ', '), count, sum
from film f
left join (
	select i.film_id, count(r.rental_id), sum(p.amount)
	from inventory i 
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	group by i.film_id) t on f.film_id = t.film_id
join "language" l on f.language_id = l.language_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by f.film_id, count, sum

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания и выведите с помощью него фильмы, которые отсутствуют на dvd дисках.

select * --1 000
from film f 

select * --42
from film f 
left join inventory i on f.film_id = i.film_id
where i.inventory_id is null

explain analyze --1227.35
select f.title, l."name", c."name", count, sum
from film f
left join (
	select i.film_id, count(r.rental_id), sum(p.amount)
	from inventory i 
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	group by i.film_id) t on f.film_id = t.film_id
join "language" l on f.language_id = l.language_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
where count is null

explain analyze --1783.82
select f.title, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join "language" l on f.language_id = l.language_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
group by f.film_id, l.language_id, c.category_id
having count(r.rental_id) = 0

explain analyze --580.57
select f.title, l."name", c."name", count(r.rental_id), sum(p.amount)
from film f
left join inventory i on f.film_id = i.film_id
left join rental r on r.inventory_id = i.inventory_id
left join payment p on p.rental_id = r.rental_id
join "language" l on f.language_id = l.language_id
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id
where i.inventory_id is null
group by f.film_id, l.language_id, c.category_id


explain analyze --576.39
select t.title, l."name", c."name", count, sum
from (
	select f.film_id, f.title, f.language_id, count(r.rental_id), sum(p.amount)
	from film f
	left join inventory i on f.film_id = i.film_id
	left join rental r on r.inventory_id = i.inventory_id
	left join payment p on p.rental_id = r.rental_id
	where i.inventory_id is null
	group by f.film_id) t 
join "language" l on t.language_id = l.language_id
join film_category fc on t.film_id = fc.film_id
join category c on c.category_id = fc.category_id

nested loop 
merge join 
hash join 

--ЗАДАНИЕ №3
--Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку "Премия".
--Если количество продаж превышает 7300, то значение в колонке будет "Да", иначе должно быть значение "Нет".

explain analyze --492.20
select s.staff_id, count(p.payment_id),
	case 
		when count(p.payment_id) > 7300 then 'da'
		else 'net'
	end
from staff s
left join payment p on s.staff_id = p.staff_id
group by s.staff_id

explain analyze --360.84
select s.staff_id, count,
	case 
		when count > 7300 then 'da'
		else 'net'
	end
from staff s
left join (
	select staff_id, count(payment_id) 
	from payment
	group by staff_id) p on s.staff_id = p.staff_id


select *
from staff s

insert into staff
values (3,	'Mike',	'dfgdfgdfg',	3,	'Mike.Hillyer@sakilastaff.com',	1,	true,	'Mike',	'8cb2237d0679ca88db6464eac60da96345513964',	'2006-02-15 04:57:16',null)	

from film 
join "language" l
join film_actor fa
join actor a

select customer_id, staff_id, payment_date::date, amount, sum(amount)
from payment p
where customer_id < 3 and payment_date::date = '01.08.2005'
group by grouping sets(1, 2, 3, 4)

select customer_id, staff_id, payment_date::date, amount, sum(amount)
from payment p
where customer_id < 3 and payment_date::date = '01.08.2005'
group by cube(1, 2, 3, 4)

select customer_id, staff_id, payment_date::date, amount, sum(amount)
from payment p
where customer_id < 3 and payment_date::date = '01.08.2005'
group by grouping sets(1, 2, 3, 4), grouping sets(1), grouping sets(2), grouping sets(3), grouping sets(4)

select customer_id, staff_id, payment_date::date, amount, sum(amount)
from payment p
where customer_id < 3 and payment_date::date = '01.08.2005'
group by 1, 2, 3, 4

::
cast 
datediff
-