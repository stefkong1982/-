Задание 1. Создайте новую таблицу film_new со следующими полями:
· film_name — название фильма — тип данных varchar(255) и ограничение not null;
· film_year — год выпуска фильма — тип данных integer, условие, что значение должно быть больше 0;
· film_rental_rate — стоимость аренды фильма — тип данных numeric(4,2), значение по умолчанию 0.99;
· film_duration — длительность фильма в минутах — тип данных integer, ограничение not null и условие, что значение должно быть больше 0.
Если работаете в облачной базе, то перед названием таблицы задайте наименование вашей схемы.

create table film_new (
	film_id serial primary key,
	film_name varchar(255) not null,
	film_year integer check(film_year > 0),
	film_rental_rate numeric(4,2) default 0.99,
	film_duration integer not null check(film_duration > 0))

Задание 2. Заполните таблицу film_new данными с помощью SQL-запроса, где колонкам соответствуют массивы данных:
· film_name — array[The Shawshank Redemption, The Green Mile, Back to the Future, Forrest Gump, Schindler’s List];
· film_year — array[1994, 1999, 1985, 1994, 1993];
· film_rental_rate — array[2.99, 0.99, 1.99, 2.99, 3.99];
· film_duration — array[142, 189, 116, 142, 195].

select unnest(array[])

from unnest(array1[], array2[], array3[]...)

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
select *
from unnest(
	array['The Shawshank Redemption', 'The Green Mile', 'Back to the Future', 'Forrest Gump', 'Schindler’s List'],
	array[1994, 1999, 1985, 1994, 1993],
	array[2.99, 0.99, 1.99, 2.99, 3.99],
	array[142, 189, 116, 142, 195])
	
select * from film_new

Задание 3. Обновите стоимость аренды фильмов в таблице film_new с учётом информации, что стоимость аренды всех фильмов поднялась на 1.41.

update film_new
set film_rental_rate = film_rental_rate + 1.41

Задание 4. Фильм с названием Back to the Future был снят с аренды, удалите строку с этим фильмом из таблицы film_new.

delete from film_new
where film_id = 3

Задание 5. Добавьте в таблицу film_new запись о любом другом новом фильме.

insert into film_new (film_name, film_year, film_rental_rate, film_duration)
values('dfgdfgdfg', 345, 6, 45)

Задание 6. Напишите SQL-запрос, который выведет все колонки из таблицы film_new, а также новую вычисляемую колонку «длительность 
фильма в часах», округлённую до десятых.

select *, round(film_duration / 60., 1)
from film_new

Задание 7. Удалите таблицу film_new.

drop table film_new

Задание 1. С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года с нарастающим итогом по 
каждому сотруднику и по каждой дате продажи (без учёта времени) с сортировкой по дате.
Ожидаемый результат запроса: letsdocode.ru...in/5-5.png

select staff_id, payment_date::date, sum(amount),
	sum(sum(amount)) over (partition by staff_id order by payment_date::date)
from payment 
where date_trunc('month', payment_date) = '01.08.2005'
group by staff_id, payment_date::date

Задание 2. 20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал дополнительную скидку 
на следующую аренду. С помощью оконной функции выведите всех покупателей, которые в день проведения акции получили скидку.
Ожидаемый результат запроса: letsdocode.ru...in/5-6.png

select *
from (
	select customer_id, row_number() over (order by payment_date)
	from payment 
	where payment_date::date = '20.08.2005') t
--where row_number % 100 = 0
where mod(row_number, 100) = 0

select 535 / 100.

Задание 3. Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
· покупатель, арендовавший наибольшее количество фильмов;
· покупатель, арендовавший фильмов на самую большую сумму;
· покупатель, который последним арендовал фильм.
Ожидаемый результат запроса: letsdocode.ru...in/5-7.png

explain analyze --7000 / 27
with cte1 as (
	select concat(c.last_name, ' ', c.first_name), c2.country_id, count(i.film_id), sum(p.amount), max(r.rental_date)
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id
	join payment p on r.rental_id = p.rental_id
	join customer c on r.customer_id = c.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id
	group by c.customer_id, c2.country_id), 
cte2 as (
	select *,
		row_number() over (partition by country_id order by count desc) rc,
		row_number() over (partition by country_id order by sum desc) rs,
		row_number() over (partition by country_id order by max desc) rm
	from cte1)
select c.country, c1.concat, c2.concat, c3.concat
from country c
left join cte2 c1 on c.country_id = c1.country_id and c1.rc = 1
left join cte2 c2 on c.country_id = c2.country_id and c2.rs = 1
left join cte2 c3 on c.country_id = c3.country_id and c3.rm = 1

explain analyze --6442.61 / 32
select distinct c3.country, 
	first_value(concat(c.last_name, ' ', c.first_name)) over (partition by c3.country_id order by count(i.film_id) desc),
	first_value(concat(c.last_name, ' ', c.first_name)) over (partition by c3.country_id order by sum(p.amount) desc),
	first_value(concat(c.last_name, ' ', c.first_name)) over (partition by c3.country_id order by max(r.rental_date) desc)
from country c3
left join city c2 on c2.country_id = c3.country_id
left join address a on c2.city_id = a.city_id
left join customer c on a.address_id = c.address_id
left join rental r on r.customer_id = c.customer_id
left join inventory i on r.inventory_id = i.inventory_id
left join payment p on r.rental_id = p.rental_id
group by c.customer_id, c3.country_id

explain analyze --1258.89 / 13
with cte1 as (
	select r.customer_id, count, sum, max
	from (
		select r.customer_id, count(i.film_id), max(r.rental_date)
		from rental r 
		join inventory i on i.inventory_id = r.inventory_id
		group by r.customer_id) r
	join (
		select customer_id, sum(amount)
		from payment 
		group by customer_id) p on r.customer_id = p.customer_id),
cte2 as (
	select concat(c.last_name, ' ', c.first_name), count, sum, max, c2.country_id,
		case 
			when count = max(count) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name)
		end cc,
		case 
			when sum = max(sum) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name)
		end cs,
		case 
			when max = max(max) over (partition by c2.country_id) then concat(c.last_name, ' ', c.first_name)
		end cm		
	from cte1 
	join customer c on c.customer_id = cte1.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id)
select c3.country, string_agg(cc, ', '), string_agg(cs, ', '), string_agg(cm, ', ')
from country c3
left join cte2 on cte2.country_id = c3.country_id
group by c3.country_id

explain analyze --7007.54 / 28
with cte1 as (
	select concat(c.last_name, ' ', c.first_name), c2.country_id, count(i.film_id), sum(p.amount), max(r.rental_date)
	from rental r 
	join inventory i on r.inventory_id = i.inventory_id
	join payment p on r.rental_id = p.rental_id
	join customer c on r.customer_id = c.customer_id
	join address a on a.address_id = c.address_id
	join city c2 on c2.city_id = a.city_id
	group by c.customer_id, c2.country_id), 
cte2 as (
	select *,
		rank() over (partition by country_id order by count desc) rc,
		rank() over (partition by country_id order by sum desc) rs,
		rank() over (partition by country_id order by max desc) rm
	from cte1)
select c.country, string_agg(distinct c1.concat, ', '), string_agg(distinct c2.concat, ', '), string_agg(distinct c3.concat, ', ')
from country c
left join cte2 c1 on c.country_id = c1.country_id and c1.rc = 1
left join cte2 c2 on c.country_id = c2.country_id and c2.rs = 1
left join cte2 c3 on c.country_id = c3.country_id and c3.rm = 1
group by c.country_id