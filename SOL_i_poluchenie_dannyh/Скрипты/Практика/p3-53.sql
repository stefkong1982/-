	 a 				     b
a_id | a_val	b_id | b_val | a_id

			    c 
a_id | a_val | b_id | b_val | a_id			

============= теория =============

create table table_one (
	name_one varchar(255) not null
);

create table table_two (
	name_two varchar(255) not null
);

insert into table_one (name_one)
values ('one'), ('two'), ('three'), ('four'), ('five');

insert into table_two (name_two)
values ('four'), ('five'), ('six'), ('seven'), ('eight');

select * from table_one;

select * from table_two;

--left, right, inner, full, cross

select table_one.name_one, table_two.name_two
from table_one
inner join table_two on table_one.name_one = table_two.name_two

select t1.name_one, t2.name_two
from table_one as t1
inner join table_two as t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one as t1
join table_two as t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one as t1 
left join table_two as t2 on t1.name_one = t2.name_two

select f.title, i.inventory_id
from film f
left join inventory i on f.film_id = i.film_id
where i.film_id is null

select t1.name_one, t2.name_two
from table_one as t1 
right join table_two as t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one as t1 
full join table_two as t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select t1.name_one, t2.name_two
from table_one as t1 
cross join table_two as t2

select c.first_name, c2.first_name --358 801
from customer c, customer c2

select c.first_name, c2.first_name --358 186
from customer c, customer c2
where c.first_name != c2.first_name

select c.first_name, c2.first_name --179 093
from customer c, customer c2
where c.first_name > c2.first_name

--AARON	ADAM
ADAM	AARON

select t1.name_one, t2.name_two
from table_one as t1, table_two as t2
where t1.name_one = t2.name_two

delete from table_one;
delete from table_two;

insert into table_one (name_one)
select unnest(array[1,1,2]);

insert into table_two (name_two)
select unnest(array[1,1,3]);

select * from table_one

select * from table_two

select t1.name_one, t2.name_two
from table_one as t1
join table_two as t2 on t1.name_one = t2.name_two

1A	1B
1a	1b
2c	3d

1A1B
1A1b
1a1B
1a1b

select t1.name_one, t2.name_two
from table_one as t1 
left join table_two as t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one as t1 
right join table_two as t2 on t1.name_one = t2.name_two

select t1.name_one, t2.name_two
from table_one as t1 
full join table_two as t2 on t1.name_one = t2.name_two
where t1.name_one is null or t2.name_two is null

select t1.name_one, t2.name_two
from table_one as t1 
cross join table_two as t2

select count(*) --599
from customer c

select count(*) --16049
from payment p

select count(*) --16044
from rental r

--ЛОЖНЫЙ ЗАПРОС
select count(*) --445483
from customer c
join payment p on c.customer_id = p.customer_id
join rental r on c.customer_id = r.customer_id

--ВЕРНЫЙ ЗАПРОС
select count(*) --16049
from customer c
join payment p on c.customer_id = p.customer_id
join rental r on p.rental_id = r.rental_id

--union / except

select lower(first_name) --599
from customer 
union --distinct
select lower(first_name) --2
from staff 
--591

select lower(first_name) --599
from customer 
union all
select lower(first_name) --2
from staff 
--601

select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 2 as y) t
except --distinct
select 1 as x, 1 as y

select *
from (
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 1 as y
	union all
	select 1 as x, 2 as y) t
except all
select 1 as x, 1 as y

-- case
< 5 - малый платеж
5 - 10 средний платеж
> 10 большой платеж

select amount_class, count(*)
from (
	select payment_id, amount,
		case
			when amount < 5 then 'малый платеж'
			when amount between 5 and 10 then 'средний платеж'
			--else 'большой платеж'
		end amount_class
	from payment) t 
group by amount_class

============= соединения =============

1. Выведите список названий всех фильмов и их языков
* Используйте таблицу film
* Соедините с language
* Выведите информацию о фильмах:
title, language."name"

select f.title, l."name" --1 000
from film f
join "language" l on f.language_id = l.language_id

select f.title, l."name" --1 000
from film f
left join "language" l on f.language_id = l.language_id

select f.title, l."name" --1 005
from film f
full join "language" l on f.language_id = l.language_id
where f.film_id is null or l.language_id is null

1. Выведите все фильмы и их категории:
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Соедините используя оператор using

--ЛОЖНЫЙ ЗАПРОС
select *
from film f
join film_category fc on f.film_id = fc.category_id
join category c on c.category_id = fc.film_id

select *
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

select f.film_id, fc.film_id
from film f
join film_category fc on f.film_id = fc.film_id
join category c on c.category_id = fc.category_id

select *
from film f
join film_category fc using(film_id)
join category c using(category_id)

select *
from film f
join film_category fc using(film_id) --and fc.category_id = 1
join category c using(category_id)

select *
from customer c
join staff s using(store_id)
join store s2 using(store_id)
join address a on a.address_id = c.address_id

store_id = store_id or / and store_id = store_id

2. Выведите уникальный список фильмов, которые брали в аренду '24-05-2005'. 
* Используйте таблицу film
* Соедините с inventory
* Соедините с rental
* Отфильтруйте, используя where 

select distinct f.title --8
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id and r.rental_date::date = '24-05-2005'

select distinct f.title --8
from film f
join inventory i on i.film_id = f.film_id
join rental r on r.inventory_id = i.inventory_id 
where r.rental_date::date = '24-05-2005'

select distinct f.title, r.rental_date::date --966
from film f
join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id and r.rental_date::date = '24-05-2005'
where r.rental_id is null --r.rental_date::date != '24-05-2005'

select distinct f.title, r.rental_date::date --8
from film f
join inventory i on i.film_id = f.film_id
left join rental r on r.inventory_id = i.inventory_id 
where r.rental_date::date = '24-05-2005'

2.1 Выведите все магазины из города Woodridge (city_id = 576)
* Используйте таблицу store
* Соедините таблицу с address 
* Соедините таблицу с city 
* Соедините таблицу с country 
* отфильтруйте по "city_id"
* Выведите полный адрес искомых магазинов и их id:
store_id, postal_code, country, city, district, address, address2, phone

explain analyze
select s.store_id, a.postal_code, country, city, district, address, address2, phone
from store s
join address a on s.address_id = a.address_id and a.city_id = 576
join city c on c.city_id = a.city_id
join country c2 on c.country_id = c2.country_id

============= агрегатные функции =============

sum 
count 
min 
max 
avg 
string_agg()
array_agg()

3. Подсчитайте количество актеров в фильме Grosse Wonderful (id - 384)
* Используйте таблицу film
* Соедините с film_actor
* Отфильтруйте, используя where и "film_id" 
* Для подсчета используйте функцию count, используйте actor_id в качестве выражения внутри функции
* Примените функцильные зависимости

select count(*), count(1), count('все что угодно')
from film_actor fa
where film_id = 384

select count(*), count(address_id)
from customer 

select count(*), count(distinct customer_id)
from payment 

--ЛОЖНЫЙ ЗАПРОС
select f.title, count(*)--f.title, f.rental_duration, f.rental_rate, f.release_year, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.title--, f.rental_duration, f.rental_rate, f.release_year

select f.title, f.rental_duration, f.rental_rate, f.release_year, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.film_id

group by ФИО
Иванов Иван ~ 100 -> 1

select f.film_id, f.title, f.rental_duration, f.rental_rate, f.release_year, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.film_id, f.title, f.rental_duration, f.rental_rate, f.release_year

select f.rental_duration, f.rental_rate, count(*)
from film_actor fa
join film f on f.film_id = fa.film_id
group by f.rental_duration, f.rental_rate

cust_id amount 
1		5
1		1
1		3
1		7
2		5
2		4
2		6
2		5

sum(amount) group by cust_id 
cust_id sum(amount)
1		16
2		20

3.1 Посчитайте среднюю стоимость аренды за день по всем фильмам
* Используйте таблицу film
* Стоимость аренды за день rental_rate/rental_duration
* avg - функция, вычисляющая среднее значение
--4 агрегации

select avg(rental_rate/rental_duration),
	count(rental_rate/rental_duration),
	sum(rental_rate/rental_duration),
	max(rental_rate/rental_duration),
	min(rental_rate/rental_duration)
from film 

select payment_date::date, string_agg(distinct customer_id::text, ', ')
from payment
group by payment_date::date

select r.customer_id, f.title
from (
	select customer_id, array_agg(rental_id)
	from (
		select *
		from rental
		order by customer_id, rental_date) t
	group by customer_id) t 
join rental r on r.rental_id = t.array_agg[5]
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id

============= группировки =============

4. Выведите месяцы, в которые было сдано в аренду более чем на 10 000 у.е.
* Используйте таблицу payment
* Сгруппируйте данные по месяцу используя date_trunc
* Для каждой группы посчитайте сумму платежей
* Воспользуйтесь фильтрацией групп, для выбора месяцев с суммой продаж более чем на 10 000 у.е.

select date_trunc('month', payment_date), sum(amount)
from payment 
group by date_trunc('month', payment_date)
having sum(amount) > 10000

explain analyze
select date_trunc('month', payment_date), sum(amount)
from payment 
group by date_trunc('month', payment_date)
having sum(amount) > 10000 and date_trunc('month', payment_date) < '01.08.2005'

explain analyze
select date_trunc('month', payment_date), sum(amount)
from payment 
where date_trunc('month', payment_date) < '01.08.2005'
group by date_trunc('month', payment_date)
having sum(amount) > 10000 

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
group by customer_id, staff_id, date_trunc('month', payment_date)
order by 1, 2, 3

select customer_id c, staff_id s, date_trunc('month', payment_date) d, sum(amount)
from payment 
group by c, s, d
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
group by 1, 2, 3
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 3 and date_trunc('month', payment_date) < '01.08.2005'
group by 1, 2, 3
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 3 and date_trunc('month', payment_date) < '01.08.2005'
group by grouping sets(1, 2, 3)
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 3 and date_trunc('month', payment_date) < '01.08.2005'
group by grouping sets(1, 2, 3), grouping sets(1, 2)
order by 1, 2, 3

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 3 and date_trunc('month', payment_date) < '01.08.2005'
group by cube(1, 2, 3)
order by 1, 2, 3

create temporary table temp_agg as (
	explain analyze --11331.44 / 30
	select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
	from payment 
	group by cube(1, 2, 3)
	order by 1, 2, 3)

explain analyze --115 / 0.6

select *
from temp_agg
where customer_id is null and staff_id is not null and date_trunc is not null

select customer_id, staff_id, date_trunc('month', payment_date), sum(amount)
from payment 
where customer_id < 3 and date_trunc('month', payment_date) < '01.08.2005'
group by rollup(1, 2, 3)
order by 1, 2, 3

4.0.1 найти сумму платежей пользователей, где размер платежа меньше 5 у.е и сумму платежей пользователей, 
	где размер платежа больше 5 у.е

select customer_id, 
	sum(case when amount < 5 then amount end),
	sum(case when amount >= 5 then amount end)
from payment 
group by customer_id

select customer_id, 
	sum(amount) filter (where amount < 5),
	sum(amount) filter (where amount >= 5)
from payment 
group by customer_id

4.1 Выведите список категорий фильмов, средняя продолжительность аренды которых более 5 дней
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней

select c."name"
from category c
join film_category fc on c.category_id = fc.category_id
join film f on f.film_id = fc.film_id
group by c.category_id
having avg(f.rental_duration) > 5

============= подзапросы =============

5. Выведите количество фильмов, со стоимостью аренды за день больше, 
чем среднее значение по всем фильмам
* Напишите подзапрос, который будет вычислять среднее значение стоимости 
аренды за день (задание 3.1)
* Используйте таблицу film
* Отфильтруйте строки в результирующей таблице, используя опретаор > (подзапрос)
* count - агрегатная функция подсчета значений

select (select )

скаляр - не имеет алиаса и используется в select, условии и в cross join
одномерный массив - не миеет алиаса используется в условиях
таблицу - обязательно алиас используется во from и join 

select avg(rental_rate / rental_duration) from film 

select count(*)
from film 
where rental_rate / rental_duration > (select avg(rental_rate / rental_duration) from film)

select customer_id, sum(amount),
	sum(amount) * 100 / (select sum(amount) from payment)
from payment 
group by customer_id

select sum(amount) from payment 

select customer_id, rental_date
from rental 
where (customer_id, rental_date) in (
	select customer_id, payment_date
	from payment 
	where payment_date::date = '01.08.2005')

6. Выведите фильмы, с категорией начинающейся с буквы "C"
* Напишите подзапрос:
 - Используйте таблицу category
 - Отфильтруйте строки с помощью оператора like 
* Соедините с таблицей film_category
* Соедините с таблицей film
* Выведите информацию о фильмах:
title, category."name"
* Используйте подзапрос во from, join, where

select category_id, "name"
from category 
where "name" like 'C%'

explain analyse 
select f.title, t.n
from (
	select category_id, "name" n
	from category c
	where "name" like 'C%') t
join film_category fc on fc.category_id = t.category_id
join film f on f.film_id = fc.film_id --175 / 53.54 / 0.38   

explain analyse
select f.title, t.name
from (
	select category_id, "name"
	from category 
	where "name" like 'C%') t 
left join film_category fc on fc.category_id = t.category_id
left join film f on f.film_id = fc.film_id --175 / 53.54 / 0.38   

explain analyse
select f.title, t.name
from film f
join film_category fc on fc.film_id = f.film_id
join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.54 / 0.38 
	
explain analyze
select f.title, t.name
from film f
right join film_category fc on fc.film_id = f.film_id
right join (
	select category_id, "name"
	from category 
	where "name" like 'C%') t on t.category_id = fc.category_id --175 / 53.54 / 0.38	

explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id and  
	fc.category_id in --(3, 4, 5)
		(select category_id
		from category 
		where "name" like 'C%') 
join category c on c.category_id = fc.category_id --175 / 47.36 / 0.34	


explain analyse
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (--3, 4, 5) --(
	select category_id
	from category 
	where "name" like 'C%') --175 / 47.21 / 0.335	
	
explain analyze
select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c."name" like 'C%'  --175 / 53.54	/ 0.38


--ТАК НЕ НАДО
explain analyze
select f.title, c.name
from (
	select film_id, title
	from film) f
join (
	select film_id, category_id 
	from film_category) fc on fc.film_id = f.film_id 
join (
	select category_id, name
	from category) c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%')	--47.21
	

select f.title, c.name
from film f
join film_category fc on fc.film_id = f.film_id 
join category c on c.category_id = fc.category_id
where c.category_id in (
	select category_id
	from category 
	where "name" like 'C%') --175 / 47.21 / 0.337	
	
-- ГРУБАЯ ОШИБКА, СОЗДАЕТ ИЗБЫТОЧНОСТЬ И ВЕШАЕТ БАЗУ. МОГУТ УВОЛИТЬ.
explain analyze --738210 / 675
select distinct customer_id, 
	(select sum(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select count(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select min(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select max(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id),
	(select avg(amount) 
	from payment p1
	where p1.customer_id = p.customer_id
	group by p1.customer_id)
from payment p
order by 1

-- ТАК НУЖНО
explain analyze --518 / 6
select customer_id, sum(amount), count('все что угодно'), min(amount), max(amount), avg(amount)
from payment
group by customer_id
order by 1

select 738210/518

select 675/6