--=============== МОДУЛЬ 2. РАБОТА С БАЗАМИ ДАННЫХ =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите уникальные названия городов из таблицы городов.

SELECT distinct city 
FROM city

--ЗАДАНИЕ №2
--Доработайте запрос из предыдущего задания, чтобы запрос выводил только те города,
--названия которых начинаются на “L” и заканчиваются на “a”, и названия не содержат пробелов.

SELECT distinct city 
FROM city
WHERE city  
LIKE 'L%a' 
AND city  
NOT LIKE '% %';

--ЗАДАНИЕ №3
--Получите из таблицы платежей за прокат фильмов информацию по платежам, которые выполнялись 
--в промежуток с 17 июня 2005 года по 19 июня 2005 года включительно, 
--и стоимость которых превышает 1.00.
--Платежи нужно отсортировать по дате платежа.

SELECT distinct *
FROM payment
WHERE payment_date::date 
BETWEEN '2005-06-17' 
AND '2005-06-19'
AND amount > 1.00
ORDER BY payment_date;

--ЗАДАНИЕ №4
-- Выведите информацию о 10-ти последних платежах за прокат фильмов.

SELECT *
FROM payment
WHERE rental_id 
IS NOT NULL
ORDER BY payment_date 
DESC
LIMIT 10;

--ЗАДАНИЕ №5
--Выведите следующую информацию по покупателям:
--  1. Фамилия и имя (в одной колонке через пробел)
--  2. Электронная почта
--  3. Длину значения поля email
--  4. Дату последнего обновления записи о покупателе (без времени)
--Каждой колонке задайте наименование на русском языке.

SELECT CONCAT(first_name, ' ', last_name) 
AS "ФИО", email 
AS "Электронная почта", LENGTH(email) 
AS "Длина email", DATE(last_update) 
AS "Дата последнего обновления"
FROM customer;

--ЗАДАНИЕ №6
--Выведите одним запросом только активных покупателей, имена которых KELLY или WILLIE.
--Все буквы в фамилии и имени из верхнего регистра должны быть переведены в нижний регистр.

SELECT lower(first_name) as lower_first_name, LOWER(last_name) as lower_last_name, active 
FROM customer
WHERE LOWER(first_name) 
IN ('kelly', 'willie') 
AND active = 1

--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выведите информацию о фильмах, у которых рейтинг “R” и стоимость аренды указана от 
--0.00 до 3.00 включительно, а также фильмы c рейтингом “PG-13” и стоимостью аренды больше или равной 4.00.

select film_id, title, description, rating, rental_rate
from film
WHERE (rating = 'R' 
AND rental_rate 
BETWEEN 0.00 
AND 3.00)
  OR (rating = 'PG-13' 
  AND rental_rate >= 4.00)

--ЗАДАНИЕ №2
--Получите информацию о трёх фильмах с самым длинным описанием фильма.

SELECT film_id, title, description
FROM film
ORDER BY LENGTH(description) 
DESC
LIMIT 3

--ЗАДАНИЕ №3
-- Выведите Email каждого покупателя, разделив значение Email на 2 отдельных колонки:
--в первой колонке должно быть значение, указанное до @, 
--во второй колонке должно быть значение, указанное после @.

SELECT customer_id, email, 
	SPLIT_PART(email, '@', 1) 
AS "Email_before_@", 
	SPLIT_PART(email, '@', 2) 
AS "Email_after_@"
FROM customer;

--ЗАДАНИЕ №4
--Доработайте запрос из предыдущего задания, скорректируйте значения в новых колонках: 
--первая буква строки должна быть заглавной, остальные строчными.


SELECT customer_id, email, 
    UPPER(SUBSTRING(SPLIT_PART(email, '@', 1), 1, 1)) || LOWER(SUBSTRING(SPLIT_PART(email, '@', 1), 2)) AS "Email_before_@", 
    INITCAP(LOWER(SPLIT_PART(email, '@', 2))) AS "Email_after_@"
FROM customer;
order by customer_id

