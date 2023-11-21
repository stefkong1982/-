Комментарии

--
/*
 * 
 * 
 * 
 */

ывалд/*ьдлывь*/арпд

Отличие ' ' от " "

' ' - берутся значения
" " - названия сущностей

set search_path to "dvd-rental"

Зарезервированные слова

select name
from Language

select "select"
from "from" 

select power(3, 5)

синтаксический порядок инструкции select;

select - в котором выводите все что нужно вывести в результат
from - основную таблицу 
join - указываете остальные таблицы
on - условие п которому присоединяются остальные таблицы
where - фильтрация данных
group by - группировка данных
having - фильтрация результатов агрегации
order by - сортировка результата
offset/limit

логический порядок инструкции select;

from
on
join
where
group by
having
select -- алиасы / псевдонимы
order by 
offset/limit

pg_typeof(), приведение типов

select pg_typeof(100)

select pg_typeof(100.)

select pg_typeof('100.') --unknown

numeric | text 
100.	 '100.'

select pg_typeof(last_name)
from customer 

select pg_typeof('100.'::float::text)

select pg_typeof(cast('100.' as float))

1. Получите атрибуты id фильма, название, описание, год релиза из таблицы фильмы.
Переименуйте поля так, чтобы все они начинались со слова Film (FilmTitle вместо title и тп)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- as - для задания синонимов 

select film_id, title, description, release_year
from film 

select film_id FilmFilm_id, title FilmTitle, description FilmDescription, release_year FilmRelease_Year
from film 

select film_id "FilmFilm_id", title "FilmTitle", description "FilmDescription", release_year "Год выпуска фильма"
from film 

select film_id as "FilmFilm_id", title as "FilmTitle", description as "FilmDescription", release_year as "Год выпуска фильма"
from film 

select 1 as "какой-то ну очень длинный псевдоним для сущности"

64байт
32символа на кириллице

select *
from (
	select lower(c.last_name) as cl, lower(s.last_name) as sl, case when 1 = 1 then 'a' end	x
	from customer c, staff s) t
where x = 'a'

2. В одной из таблиц есть два атрибута:
rental_duration - длина периода аренды в днях  
rental_rate - стоимость аренды фильма на этот промежуток времени. 
Для каждого фильма из данной таблицы получите стоимость его аренды в день,
задайте вычисленному столбцу псевдоним cost_per_day
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- стоимость аренды в день - отношение rental_rate к rental_duration
- as - для задания синонимов 

integer 
numeric - финансы
float

select title, rental_rate / rental_duration,
	rental_rate * rental_duration,
	rental_rate + rental_duration,
	rental_rate - rental_duration,
	power(rental_rate, rental_duration),
	rental_rate ^ rental_duration,
	mod(rental_rate, rental_duration),
	rental_rate % rental_duration,
	cos(rental_rate)	
from film 

2*
- арифметические действия
- оператор round

select title, rental_rate / rental_duration as cost_per_day
from film 

round(numeric, int)
round(float)

select title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 

select title, (rental_rate / rental_duration)::numeric(4, 2) as cost_per_day
from film 

select title, floor(rental_rate / rental_duration) as cost_per_day
from film 

select title, ceiling(rental_rate / rental_duration) as cost_per_day
from film 

select round(89898/1, 3)

3.1 Отсортировать список фильмов по убыванию стоимости за день аренды (п.2)
- используйте order by (по умолчанию сортирует по возрастанию)
- desc - сортировка по убыванию

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by round(rental_rate / rental_duration, 2) --asc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by round(rental_rate / rental_duration, 2) desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by cost_per_day desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc, title, film_id desc

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc, 2, 1 desc

3.1* Отсортируйте таблицу платежей по возрастанию суммы платежа (amount)
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- используйте order by 
- asc - сортировка по возрастанию 

select payment_id, customer_id
from payment 
order by amount

3.2 Вывести топ-10 самых дорогих фильмов по стоимости за день аренды
- используйте limit

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc

INNOCENT USUAL
VELVET TERMINATOR
BEHAVIOR RUNAWAY
TORQUE BOUND
TRAIN BUNCH
TRAP GUYS
TYCOON GATHERING
BILKO ANONYMOUS
MINE TITANS
MISSION ZOOLANDER

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
limit 10

CARIBBEAN LIBERTY
CASPER DRAGONFLY
AUTUMN CROW
BEAST HUNCHBACK
BEHAVIOR RUNAWAY
BILKO ANONYMOUS
ACE GOLDFINGER
AMERICAN CIRCUS
BACKLASH UNDEFEATED
CASUALTIES ENCINO

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc, film_id
limit 10

ACE GOLDFINGER
AMERICAN CIRCUS
AUTUMN CROW
BACKLASH UNDEFEATED
BEAST HUNCHBACK
BEHAVIOR RUNAWAY
BILKO ANONYMOUS
CARIBBEAN LIBERTY
CASPER DRAGONFLY
CASUALTIES ENCINO

1 - 1000
2,3,4 - 990
5-20 - 980

Топ 3 - 

3 квартиры - 1 + два случайных из 2,3,4
N конфет - 1-20

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
limit 10

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 10 rows only

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 10 rows with ties


3.2.1 Вывести топ-1 самых дорогих фильмов по стоимости за день аренды, то есть вывести все 62 фильма
--начиная с 13 версии

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 3 rows with ties

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
fetch first 63 rows with ties

3.3 Вывести топ-10 самых дорогих фильмов по стоимости аренды за день, начиная с 58-ой позиции
- воспользуйтесь Limit и offset

select film_id, title, round(rental_rate / rental_duration, 2) as cost_per_day
from film 
order by 3 desc
offset 57
limit 10

3.3* Вывести топ-15 самых низких платежей, начиная с позиции 14000
- воспользуйтесь Limit и offset

select *
from payment 
order by amount 
offset 13999
limit 15

4. Вывести все уникальные годы выпуска фильмов
- воспользуйтесь distinct

select distinct release_year
from film 

explain analyze --122.33
select distinct release_year, film_id
from film 
order by 2

explain analyze --93.46
select release_year, film_id
from film 
order by 2

4* Вывести уникальные имена покупателей
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- воспользуйтесь distinct

select first_name --599
from customer 

explain analyze --22.40
select distinct first_name --591
from customer 

explain analyze --22.40
select first_name --591
from customer 
group by 1

select distinct last_name, first_name --599
from customer

4.1 нужно получить последний платеж каждого пользователя

select distinct on ()

select distinct * --599
from payment 

select distinct on (customer_id) * ----599
from payment 
order by customer_id, payment_date desc

select distinct on (customer_id) * ----599
from payment 
order by customer_id, amount


5.1. Вывести весь список фильмов, имеющих рейтинг 'PG-13', в виде: "название - год выпуска"
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- "||" - оператор конкатенации, отличие от concat
- where - конструкция фильтрации
- "=" - оператор сравнения

text 
varchar(N) varchar(150)
char(N) char(10) 'xxxxx' -> 'xxxxx      '

select title || ' - ' || release_year, rating --223
from film 
where rating = 'PG-13'

select concat(title, ' - ', release_year), rating --223
from film 
where rating = 'PG-13'

select 'hello' || null

select 2 + null

select concat('hello', null)

select concat(last_name, ' ', first_name, ' ', middle_name)
from person 

select concat_ws(' ', last_name, first_name, middle_name)
from person 

5.2 Вывести весь список фильмов, имеющих рейтинг, начинающийся на 'PG'
- cast(название столбца as тип) - преобразование
- like - поиск по шаблону
- ilike - регистронезависимый поиск
- lower
- upper
- length

% - от 0 до N 
_ - строго один символ

select concat(title, ' - ', release_year), rating --223
from film 
where rating like 'PG%'

SQL Error [42883]: ОШИБКА: оператор не существует: mpaa_rating ~~ unknown

select concat(title, ' - ', release_year), rating --223
from film 
where rating::text like 'PG%'

select concat(title, ' - ', release_year), rating --223
from film 
where rating::text like '%3'

select concat(title, ' - ', release_year), rating --223
from film 
where rating::text like 'N%7'

select concat(title, ' - ', release_year), rating --223
from film 
where rating::text like '%-%'

select concat(title, ' - ', release_year), rating --223
from film 
where not rating::text like '%-%'

select concat(title, ' - ', release_year), rating --223
from film 
where rating::text not like '%-%'

select concat(title, ' - ', release_year), rating --223
from film 
where cast(rating as text) not like '%-%'

select concat(title, ' - ', release_year), rating 
from film 
where title like 'A__N%'

explain analyze --67.50
select concat(title, ' - ', release_year), rating 
from film 
where title like 'A_________'

explain analyze --72.50
select concat(title, ' - ', release_year), rating 
from film 
where title like 'A%' and char_length(title) = 10

select title
from film
where title like '%\%%'
order by 1

select * from film 

select title
from film
where title like '%Y%Y%%' escape 'Y'
order by 1

select concat(title, ' - ', release_year), rating 
from film 
where title ilike 'aC%' 

select concat(title, ' - ', release_year), rating 
from film 
where lower(title) like 'ac%' 

select concat(title, ' - ', release_year), rating 
from film 
where upper(title) like 'AC%' 

в like нельзя написать так '%"%"%'?

select initcap(lower(upper(concat_ws(' ', last_name, first_name, middle_name))))
from person 

select initcap('aaa.bBB,ccc ddd6eee_fff')

Aaa.Bbb,Ccc Ddd6eee~Fff

5.2* Получить информацию по покупателям с именем содержашим подстроку'jam' (независимо от регистра написания),
в виде: "имя фамилия" - одной строкой.
- "||" - оператор конкатенации
- where - конструкция фильтрации
- ilike - регистронезависимый поиск
- strpos
- character_length
- overlay
- substring
- split_part

select *
from customer 
where first_name ilike '%jam%'

select title, left(title, 1), left(title, -1), right(title, 1), right(title, -1)
from film 

select title, character_length(title), char_length(title), length(title), octet_length(title)
from film 

select length('привет мир'), octet_length('привет мир')

select title, strpos(title, 'ADA')
from film 

select title, substring(title, 5, 3), substring(title from 5 for 3), substring(title, 5)
from film 

select concat_ws(' ', last_name, first_name, middle_name),
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 1), 
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 2), 
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 3),
	split_part(concat_ws(' ', last_name, first_name, middle_name), ' ', 30)
from person 

Литвинова 1
Амелия 2 
Егоровна 3

select concat_ws(' ', last_name, first_name, middle_name),
	overlay(concat_ws(' ', last_name, first_name, middle_name) placing 'Nikolay' 
		from strpos(concat_ws(' ', last_name, first_name, middle_name), 'Николай')
		for char_length('Николай'))
from person 
where first_name = 'Николай' -- Nikolay

6. Получить id покупателей, арендовавших фильмы в срок с 27-05-2005 по 28-05-2005 включительно
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- between - задает промежуток (аналог ... >= ... and ... <= ...)
- date_part()
- date_trunc()
- interval

date 
timestamp --datetime
time 
timestamptz
timetz
interval

локаль!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

show lc_collate --Russian_Russia.1251

dd.mm.yyyy
yyyy.mm.dd

select now()

2023-05-29 21:29:21.236092+03

select '2023-05-29 21:29:21.236092+10'::timestamptz

2023-05-29 14:29:21.236092+03
	
--ложный запрос
select customer_id, rental_date
from rental 
where rental_date >= '27-05-2005' and rental_date <= '28-05-2005'
order by rental_date desc

--ложный запрос
select customer_id, rental_date
from rental 
where rental_date between '27-05-2005 00:00:00' and '28-05-2005 00:00:00'
order by rental_date desc

--ложный запрос
select customer_id, rental_date
from rental 
where rental_date between '27-05-2005 00:00:00' and '28-05-2005 23:59:59'
order by rental_date desc

--можно, но не нужно
select customer_id, rental_date
from rental 
where rental_date between '27-05-2005 00:00:00' and '28-05-2005 24:00:00'
order by rental_date desc

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005' and '29-05-2005'
order by rental_date desc

select customer_id, rental_date
from rental 
where rental_date between '27-05-2005' and '28-05-2005'::date + interval '1 day'
order by rental_date desc

--как нужно
select customer_id, rental_date
from rental 
where rental_date::date between '27-05-2005' and '28-05-2005'
order by rental_date desc

6* Вывести платежи поступившие после 2005-07-08
- используйте ER - диаграмму, чтобы найти подходящую таблицу
- > - строгое больше (< - строгое меньше)

select *
from payment 
where payment_date::date > '2005-07-08'

select date_part('year', now()),
	date_part('month', now()),
	date_part('day', now()),
	date_part('hour', now()),
	date_part('minute', now()),
	date_part('second', now()),
	date_part('isodow', now()),
	date_part('week', now()),
	date_part('quarter', now()),
	date_part('epoch', now())
	
select date_trunc('year', now()),
	date_trunc('month', now()),
	date_trunc('day', now()),
	date_trunc('hour', now()),
	date_trunc('minute', now()),
	date_trunc('second', now()),
	date_trunc('week', now()),
	date_trunc('quarter', now())

7. Получить количество дней с '30-04-2007' по сегодняшний день.
Получить количество месяцев с '30-04-2007' по сегодняшний день.
Получить количество лет с '30-04-2007' по сегодняшний день.

select now()

select current_timestamp

select current_time

select current_date

select current_user

select current_schema

timestamp - timestamp = interval 

date - date = integer

--дни:
select current_date - '30-01-2007'::date

--Месяцы:
select date_part('year', age('30-01-2007'::date)) * 12 + date_part('month', age('30-01-2007'::date))

--Года:
select (current_date - '30-01-2007'::date) / 365.25 -- ОЧЕНЬ ПЛОХО!

select (current_timestamp - '30-01-2007'::timestamp)

select age(current_timestamp, '30-01-2007'::timestamp)

select date_part('year', age('30-01-2007'::date))

select date_trunc('month', current_date)::date

select date_trunc('month', current_date)::date + interval '1 month' - interval '1 day'

8. Булев тип

true 1 'yes' 't' 'on'
false 0 'no' 'f' 'off'

select customer_id, activebool
from customer 
where activebool

select customer_id, activebool
from customer 
where activebool is false

select customer_id, activebool
from customer 
where activebool = 'off'

9 Логические операторы and и or

and - * 
or - + 

select customer_id, amount
from payment 
where customer_id = 1 or customer_id = 2 and amount = 2.99 or amount = 4.99

where (a + b) * (c + d)

select customer_id, amount
from payment 
where (customer_id = 1 or customer_id = 2) and (amount = 2.99 or amount = 4.99)

select customer_id, amount
from payment 
where customer_id = 1 and amount = 2.99 or customer_id = 2 and amount = 4.99

select customer_id
	, amount
	, payment_id
from payment 
where 
	customer_id = 1 and (amount = 2.99 or amount = 4.99)


Как правильно в SELECT записать вывод в 1 колонку записи: "За {payment_date} продано - {agg_amount} цветов" ?

--CONCAT_WS(' ', ‘За’, payment_date, ‘продано’, agg_amount, ‘цветов’)

--Нет правильного варианта ответа

CONCAT('За ', payment_date, ’ продано - ‘, agg_amount, ’ цветов’) +

--‘За’ || ’ ’ || payment_date || ‘продано’ || ’ - ’ || agg_amount || ‘цветов’

Какая разница будет между колонками?

В первом случае будет дата без времени, во втором случае только дата

Разница только в названии колонок через алиасы

Нет правильного ответа

Никакой разницы

select p.payment_date as PD1, p.payment_date::date as PD2 from payment p