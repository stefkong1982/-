============= представления =============

4. Создайте view с колонками клиент (ФИО; email) и title фильма, который он брал в прокат последним
+ Создайте представление:
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1

create view task_1 as
	--explain analyze --2148.35 / 12
	select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.title, f.film_id
	from customer c
	join (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
select t.*, p.sum
from task_1 t 
join (
	select customer_id, sum(amount)
	from payment
	group by 1) p on t.customer_id = p.customer_id
	
explain analyze --2148.35 / 12
select *
from task_1 t 

4.1. Создайте представление с 3-мя полями: название фильма, имя актера и количество фильмов, в которых он снимался
+ Создайте представление:
* Используйте таблицу film
* Соедините с film_actor
* Соедините с actor
* count - агрегатная функция подсчета значений
* Задайте окно с использованием предложений over и partition by

create view task_2 as 
	select f.title, concat(a.last_name, ' ', a.first_name), 
		count(f.film_id) over (partition by a.actor_id)
	from film f
	join film_actor fa on f.film_id = fa.film_id
	join actor a on a.actor_id = fa.actor_id
	
select * from task_2
	
============= материализованные представления =============

5. Создайте материализованное представление с колонками клиент (ФИО; email) и title фильма, 
который он брал в прокат последним
Иницилизируйте наполнение и напишите запрос к представлению.
+ Создайте материализованное представление без наполнения (with NO DATA):
* Создайте CTE, 
- возвращает строки из таблицы rental, 
- дополнено результатом row_number() в окне по customer_id
- упорядочено в этом окне по rental_date по убыванию (desc)
* Соеднините customer и полученную cte 
* соедините с inventory
* соедините с film
* отфильтруйте по row_number = 1
+ Обновите представление
+ Выберите данные 

create materialized view task_3 as
	select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.title, f.film_id
	from customer c
	join (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
with no data

select * from task_3

SQL Error [55000]: ОШИБКА: материализованное представление "task_3" не было наполнено

refresh materialized view task_3

explain analyze --2148.35 / 12
select *
from task_1 t 

explain analyze --13.99 / 0.05
select * 
from task_3

select 12 / 0.05

5.1. Содайте наполенное материализованное представление, содержащее:
список категорий фильмов, средняя продолжительность аренды которых более 5 дней
+ Создайте материализованное представление с наполнением (with DATA)
* Используйте таблицу film
* Соедините с таблицей film_category
* Соедините с таблицей category
* Сгруппируйте полученную таблицу по category.name
* Для каждой группы посчитайте средню продолжительность аренды фильмов
* Воспользуйтесь фильтрацией групп, для выбора категории со средней продолжительностью > 5 дней
 + Выберите данные

create materialized view task_4 as
	select c."name"
	from film f
	join film_category fc on f.film_id = fc.film_id
	join category c on c.category_id = fc.category_id
	group by c.category_id
	having avg(f.rental_duration) > 5
--with data
	
select * 
from task_4

--запрос на проверку времени обновления мат представлений

WITH pgdata AS (
    SELECT setting AS path
    FROM pg_settings
    WHERE name = 'data_directory'
),
path AS (
    SELECT
    	CASE
            WHEN pgdata.separator = '/' THEN '/'    -- UNIX
            ELSE '\'                                -- WINDOWS
        END AS separator
    FROM 
        (SELECT SUBSTR(path, 1, 1) AS separator FROM pgdata) AS pgdata
)
SELECT
        ns.nspname||'.'||c.relname AS mview,
        (pg_stat_file(pgdata.path||path.separator||pg_relation_filepath(ns.nspname||'.'||c.relname))).modification AS refresh
FROM pgdata, path, pg_class c
JOIN pg_namespace ns ON c.relnamespace=ns.oid
WHERE c.relkind='m';

explain analyze --1979.76 / 11
select *
from task_1 t 
where lower(left(concat, 1)) = 'a'

explain analyze --18.48 / 0.3
select * 
from task_3
where lower(left(concat, 1)) = 'a'

select 11 / 0.3

create index first_letter_idx on task_3 (lower(left(concat, 1)))

explain analyze --10.71 / 0.03
select * 
from task_3
where lower(left(concat, 1)) = 'a'

select 11 / 0.03

============ Индексы ===========

btree < > = null in between
hash = 
gist 
gin 

select *
from film f

alter table film drop constraint film_pkey cascade

0 индексов - 472кб

select *
from film f

create index title_idx on film (title)

1 индексов - 528кб

select title, film_id, *
from film f
where title = 'AFRICAN EGG'

alter table film add constraint film_pkey primary key (film_id)
 
explain analyze --Seq Scan on film f  (cost=0.00..67.50 rows=1 width=386) (actual time=0.048..0.220
select *
from film f
where film_id = 189

explain analyze --Index Scan using film_pkey on film f  (cost=0.28..8.29 rows=1 width=386) (actual time=0.022..0.022
select *
from film f
where film_id = 189

1-1000
1-500 501-1000
1-250 251-500 501-750 751-1000
1-125 126-250 251-375....

explain analyze 
select *
from film f
where film_id < 650

create index film_id_hash_idx on film using hash (film_id)

explain analyze --Index Scan using film_id_hash_idx on film f  (cost=0.00..8.02 rows=1 width=386) (actual time=0.019..0.020
select *
from film f
where film_id = 189

explain analyze --Index Scan using film_pkey on film f  (cost=0.00..8.02 rows=1 width=386) (actual time=0.019..0.020
select *
from film f
where film_id < 189

3 индекса - 616кб

create index strange_idx on film (rental_rate, rental_duration, length, release_year)

4 индекса - 664кб

explain analyze
select *
from film f
where rental_rate = 4.99 and length > 300

create index strange_2_idx on film (title, description, rental_rate, rental_duration, length, release_year)

5 индексов - 840кб

explain analyze --Seq Scan on payment p  (cost=0.00..319.61 rows=1 width=26) (actual time=1.350..1.350 
select *
from payment p
where payment_date::date = '01.08.2005'

create index payment_date_idx on payment (payment_date)

explain analyze --Seq Scan on payment p  (cost=0.00..359.74 rows=80 width=26) (actual time=0.014..1.615
select *
from payment p
where payment_date::date = '01.08.2005'

create index payment_date_date_idx on payment (cast(payment_date as date))

drop index payment_date_date_idx 

explain analyze --Seq Scan on payment p  (cost=0.00..359.74 rows=80 width=26) (actual time=0.014..1.615
select *
from payment p
where payment_date::date = '01.08.2005'

explain analyze --Index Scan using payment_date_date_idx on payment p   (cost=0.00..359.74 rows=80 width=26) (actual time=0.014..1.615
select *
from payment p
order by payment_date::date 

explain analyze --Index Scan using payment_date_date_idx on payment p  
select *
from payment p
order by payment_date::date 

create index payment_date_date_idx on payment (cast(payment_date as date)) where payment_date::date >= '01.08.2005'

explain analyze --Seq Scan on payment p  (cost=0.00..359.74 rows=80 width=26) (actual time=0.014..1.615
select *
from payment p
where payment_date::date = '18.06.2005'

explain analyze --Seq Scan on payment p  (cost=0.00..359.74 rows=80 width=26) (actual time=0.014..1.615
select *
from payment p
where payment_date::date = '01.08.2005'

============ explain ===========

Ссылка на сервис по анализу плана запроса 
https://explain.depesz.com/ -- открывать через ВПН
https://tatiyants.com/pev/
https://habr.com/ru/post/203320/

explain
select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.title, f.film_id
from customer c
join (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental) r on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

Nested Loop  (cost=1559.72..2148.35 rows=80 width=87)

explain analyze
select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.title, f.film_id
from customer c
join (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental) r on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

Nested Loop  (cost=1559.72..2148.35 rows=80 width=87) (actual time=10.296..19.529 rows=599 loops=1)

explain (format json, analyze)
select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.title, f.film_id
from customer c
join (
	select *, row_number() over (partition by customer_id order by rental_date desc)
	from rental) r on c.customer_id = r.customer_id
join inventory i on i.inventory_id = r.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

======================== json ========================
Создайте таблицу orders

CREATE TABLE orders (
     ID serial PRIMARY KEY,
     info json NOT NULL
);

INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "Beer","qty": 6,"a":345}, "customer": "John Doe"}'
 ),
 (
'{ "customer": "Lily Bush", "items": {"product": "Diaper","qty": 24}}'
 ),
 (
'{ "customer": "Josh William", "items": {"product": "Toy Car","qty": 1}}'
 ),
 (
'{ "customer": "Mary Clark", "items": {"product": "Toy Train","qty": 2}}'
 );
 
INSERT INTO orders (info)
VALUES
 (
'{"items": {"product": "01.01.2023","qty": "fgdfgh"}, "customer": "John Doe"}'
 )

INSERT INTO orders (info)
VALUES
 (
'{ "a": { "a": { "a": { "a": { "a": { "c": "b"}}}}}}'
 )

select  * from orders

|{название_товара: quantity, product_id: quantity, product_id: quantity}|общая сумма заказа|

6. Выведите общее количество заказов:
* CAST ( data AS type) преобразование типов
* SUM - агрегатная функция суммы
* -> возвращает JSON
*->> возвращает текст

select info, pg_typeof(info) 
from orders

select info->'items', pg_typeof(info->'items') 
from orders

select info->'items'->'qty', pg_typeof(info->'items'->'qty') 
from orders

select sum(info->'items'->'qty')--, pg_typeof(info->'items'->'qty') 
from orders

select info->'items'->>'qty', pg_typeof(info->'items'->>'qty') 
from orders

select sum((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'qty' ~ '^[0-9\.]+$'

select info->'items'->'product', char_length((info->'items'->'product')::text), char_length(info->'items'->>'product')
from orders


6*  Выведите среднее количество заказов, продуктов начинающихся на "Toy"

select avg((info->'items'->>'qty')::numeric)
from orders
where info->'items'->>'qty' ~ '^[0-9\.]+$' and info->'items'->>'product' ilike 'toy%'

select info->'items'
from orders
where  info::text ilike '%toy%'

select json_object_keys(info->'items')
from orders

======================== array ========================
7. Выведите сколько раз встречается специальный атрибут (special_features) у
фильма -- сколько элементов содержит атрибут special_features
* array_length(anyarray, int) - возвращает длину указанной размерности массива

int[] [2345,894,12,567,346]
date[]
time[] - ['10:00', '12:00']
text[] ['01.01.2023', 'dfdfhdfh', '65468']

create table a (
	id serial primary key,
	val int[])
	
insert into a (val)
values (array[100])

insert into a (val)
values ('{200}')

select * from a

select val[1] from a

update a 
set val[-10] = 500
where id = 1

{[-10:1]={500,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,100}}

select title, array_length(special_features, 1)
from film 

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 1)

select array_length('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[], 2)

select cardinality('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[])

select array_ndims('{{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3},{1,2,3}}'::text[])

select val[-5:-3]
from a

select id, array_lower(val, 1), array_upper(val, 1)
from a

7* Выведите все фильмы содержащие специальные атрибуты: 'Trailers'
* Используйте операторы:
@> - содержит
<@ - содержится в
*  ARRAY[элементы] - для описания массива

https://postgrespro.ru/docs/postgresql/14/functions-subquery
https://postgrespro.ru/docs/postgrespro/14/functions-array

-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--
-- ТАК НЕЛЬЗЯ (0 БАЛЛОВ В ИТОГОВОЙ)--

-- ЛОЖНЫЙ ЗАПРОС
select title, special_features
from film 
where special_features::text ilike '%Trailers%'

'1Trailers'
'Trailers1'

-- ПЛОХАЯ ПРАКТИКА --
select title, special_features
from film 
where special_features[1] = 'Trailers' or special_features[2] = 'Trailers' or special_features[3] = 'Trailers' or special_features[4] = 'Trailers'

-- ЧТО-ТО СРЕДНЕЕ ПРАКТИКА --

select f.title, f.special_features
from (
	select film_id, title, unnest(special_features)
	from film) t 
join film f on f.film_id = t.film_id
where unnest = 'Trailers'

select title, special_features
from film
where 'Trailers' in (select unnest(special_features))

-- ХОРОШАЯ ПРАКТИКА --
select title, special_features
from film
where special_features && array['Trailers', 'kdjghidkbgikadf']

select title, special_features
from film
where special_features @> array['Trailers']

select title, special_features
from film
where array['Trailers'] <@ special_features 

select title, special_features
from film
where special_features <@ array['Trailers']

select title, special_features
from film
where 'Trailers' = any(special_features) --some

select title, special_features
from film
where 'Trailers' = all(special_features)

select title, array_position(special_features, 'Deleted Scenes')
from film

select title, array_position(special_features, 'Deleted Scenes')
from film
where array_position(special_features, 'Deleted Scenes') is not null

select title, array_positions(special_features, 'Deleted Scenes')
from film
where array_length(array_positions(special_features, 'Deleted Scenes'), 1) > 0 

select title, special_features, array_append(special_features, '123')
from film

create materialized view strange_mat_view as
	select c.customer_id, concat(c.last_name, ' ', c.first_name), c.email, f.title, f.film_id, now()
	from customer c
	join (
		select *, row_number() over (partition by customer_id order by rental_date desc)
		from rental) r on c.customer_id = r.customer_id
	join inventory i on i.inventory_id = r.inventory_id
	join film f on f.film_id = i.film_id
	where row_number = 1
	
create table mat_audit (
	id serial primary key,
	schema_name varchar(64) not null,
	mat_view_name varchar(64) not null,
	refresh_ts timestamp not null default now(),
	refresh_user varchar(64) not null default current_user)
	
SET PGPASSWORD=123
c:\program files\postgresql\15\bin\psql -h localhost -p 5435 -U postgres -d postgres -c "refresh materialized view strange_mat_view;" -c "insert into mat_audit (schema_name, mat_view_name) values ('public', 'strange_mat_view');"

refresh materialized view strange_mat_view;

insert into mat_audit (schema_name, mat_view_name) values ('public', 'strange_mat_view');

select * from mat_audit --2023-06-15 21:39:30.295537

select *
from strange_mat_view --2023-06-15 21:39:30.264879+03