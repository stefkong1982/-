--=============== МОДУЛЬ 6. POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Напишите SQL-запрос, который выводит всю информацию о фильмах 
--со специальным атрибутом "Behind the Scenes".

SELECT 
    *
FROM 
    film
WHERE 
    'Behind the Scenes' = any(special_features)
-- Выбор всех элементов таблицы film,
-- где элемент 'Behind the Scenes' содержится в поле special_features
-- с использованием функции any

--ЗАДАНИЕ №2
--Напишите еще 2 варианта поиска фильмов с атрибутом "Behind the Scenes",
--используя другие функции или операторы языка SQL для поиска значения в массиве.

SELECT -- 1
    *
FROM 
    film
where 
	special_features @> array['Behind the Scenes']
-- Выбираем все элементы из таблицы film,
-- Оператор включения массивов - проверяет, 
-- содержатся ли все элементы массива-аргумента 
-- в другом массиве (в данном случае проверяем, 
-- есть ли в массиве special_features элемент 'Behind the Scenes')

SELECT -- 2
    *
FROM 
    film
WHERE 
    special_features && array['Behind the Scenes']
-- Выбор всех элементов из таблицы film, 
-- где есть хотя бы один элемент из массива ['Behind the Scenes'], 
-- && - оператор, который позволяет проверять, есть ли в массиве array значение.


--ЗАДАНИЕ №3
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов 
--со специальным атрибутом "Behind the Scenes.

--Обязательное условие для выполнения задания: используйте запрос из задания 1, 
--помещенный в CTE. CTE необходимо использовать для решения задания.

WITH films AS (
SELECT *
FROM film
WHERE 'Behind the Scenes' = ANY(special_features) -- Выбираем фильмы со специальным атрибутом "Behind the Scenes" и сохраняем результат в таблице-выражении films
)
SELECT 
customer_id, COUNT(rental_id) AS num_behind_scenes_rentals -- Выбираем customer_id и число прокатов фильмов со специальным атрибутом
FROM 
rental
WHERE inventory_id IN ( -- Выбираем прокаты с инвентарными номерами, в которых есть фильмы из таблицы-выражения films
        SELECT inventory_id
        FROM inventory
        WHERE film_id IN ( -- Выбираем инвентарные номера фильмов, соответствующих фильмам из CTE-выражения films
            SELECT film_id
            FROM films)
        )
GROUP BY customer_id -- Группируем результаты по customer_id
ORDER BY customer_id ASC; -- Сортируем результаты по customer_id в порядке возрастания.
 
--ЗАДАНИЕ №4
--Для каждого покупателя посчитайте сколько он брал в аренду фильмов
-- со специальным атрибутом "Behind the Scenes".

--Обязательное условие для выполнения задания: используйте запрос из задания 1,
--помещенный в подзапрос, который необходимо использовать для решения задания.

SELECT 
customer.customer_id, 
customer.first_name, 
customer.last_name, 
COALESCE(special_rentals.num_behind_scenes_rentals, 0) AS num_behind_scenes_rentals -- Выводим информацию о покупателях и количестве их прокатов фильмов со специальным атрибутом, используя ключевое слово COALESCE для корректного вывода значения 0, если значение столбца является NULL
FROM customer -- Выбираем данные из таблицы customer
LEFT JOIN ( -- Используем JOIN, чтобы включить всех покупателей, даже если у них нет аренд со специальным атрибутом
        SELECT rental.customer_id, COUNT(*) AS num_behind_scenes_rentals -- Отображаем количество прокатов фильмов со специальным атрибутом для каждого покупателя в полях customer_id и num_behind_scenes_rentals
        FROM rental
        JOIN inventory ON rental.inventory_id = inventory.inventory_id -- Объединяем данные по полю inventory_id из таблиц rental и inventory
        WHERE inventory.film_id IN (-- Выбираем данные из таблицы film, которые соответствуют фильмам со специальным атрибутом 'Behind the Scenes'
            SELECT film_id
            FROM film
            WHERE 'Behind the Scenes' = any(special_features) -- Используем функцию any для поиска фильмов со специальным атрибутом в поле special_features
            )
        GROUP BY rental.customer_id
) AS special_rentals ON customer.customer_id = special_rentals.customer_id -- Объединяем данные по полю customer_id из представления customer и выборки special_rentals
ORDER BY customer.customer_id; -- Сортируем выбранные данные по полю customer_id в порядке возрастания
    
--ЗАДАНИЕ №5
--Создайте материализованное представление с запросом из предыдущего задания
--и напишите запрос для обновления материализованного представления

create materialized view z_5 as
SELECT 
customer.customer_id, 
customer.first_name, 
customer.last_name, 
COALESCE(special_rentals.num_behind_scenes_rentals, 0) AS num_behind_scenes_rentals -- Выводим информацию о покупателях и количестве их прокатов фильмов со специальным атрибутом, используя ключевое слово COALESCE для корректного вывода значения 0, если значение столбца является NULL
FROM customer -- Выбираем данные из таблицы customer
LEFT JOIN ( -- Используем JOIN, чтобы включить всех покупателей, даже если у них нет аренд со специальным атрибутом
        SELECT rental.customer_id, COUNT(*) AS num_behind_scenes_rentals -- Отображаем количество прокатов фильмов со специальным атрибутом для каждого покупателя в полях customer_id и num_behind_scenes_rentals
        FROM rental
        JOIN inventory ON rental.inventory_id = inventory.inventory_id -- Объединяем данные по полю inventory_id из таблиц rental и inventory
        WHERE inventory.film_id IN (-- Выбираем данные из таблицы film, которые соответствуют фильмам со специальным атрибутом 'Behind the Scenes'
            SELECT film_id
            FROM film
            WHERE 'Behind the Scenes' = any(special_features) -- Используем функцию any для поиска фильмов со специальным атрибутом в поле special_features
            )
        GROUP BY rental.customer_id
) AS special_rentals ON customer.customer_id = special_rentals.customer_id -- Объединяем данные по полю customer_id из представления customer и выборки special_rentals
ORDER BY customer.customer_id; -- Сортируем выбранные данные по полю customer_id в порядке возрастания

-- Выводим данные из материализованного представления z_5 для проверки корректности его создания
SELECT *
FROM z_5;

-- Обновляем данные в материализованном представлении z_5
REFRESH MATERIALIZED VIEW z_5;

--ЗАДАНИЕ №6
--С помощью explain analyze проведите анализ стоимости выполнения запросов из предыдущих заданий и ответьте на вопросы:
--1. с каким оператором или функцией языка SQL, используемыми при выполнении домашнего задания: 
--поиск значения в массиве затрачивает меньше ресурсов системы;
--2. какой вариант вычислений затрачивает меньше ресурсов системы: 
--с использованием CTE или с использованием подзапроса.

-- 1-ЧАСТЬ

-- 1 используем @> - оператор
explain ANALYZE -- Seq Scan on film  (cost=0.00..67.50 rows=535 width=386) (actual time=0.016..0.521 rows=535 loops=1)
SELECT -- 1
    *
FROM 
    film
where 
	special_features @> array['Behind the Scenes']

-- 2 используем && - оператор
explain ANALYZE -- Seq Scan on film  (cost=0.00..67.50 rows=538 width=386) (actual time=0.014..0.538 rows=538 loops=1)
SELECT -- 2
    *
FROM 
    film
WHERE 
    special_features && array['Behind the Scenes']

-- 3 с использованием функции any
explain ANALYZE -- Seq Scan on film  (cost=0.00..77.50 rows=538 width=386) (actual time=0.020..0.781 rows=538 loops=1)
SELECT
    *
FROM 
    film
WHERE 
    'Behind the Scenes' = any(special_features)

-- Судя по показникам "Execution Time" на маленьких объемах данных разница несущественна между этими запросами, 
-- однако при увеличении объема данных использование @> оператора гарантирует оптимизацию запроса по индексам. 
-- Следовательно, первый запрос с использованием оператора @> будет самым оптимизированным.
    
-- 2-ЧАСТЬ
    
    -- С CTE
explain ANALYZE -- Sort  (cost=723.31..724.81 rows=599 width=10) (actual time=34.514..34.610 rows=599 loops=1)
WITH films AS (
SELECT *
FROM film
WHERE 'Behind the Scenes' = ANY(special_features) -- Выбираем фильмы со специальным атрибутом "Behind the Scenes" и сохраняем результат в таблице-выражении films
)
SELECT 
customer_id, COUNT(rental_id) AS num_behind_scenes_rentals -- Выбираем customer_id и число прокатов фильмов со специальным атрибутом
FROM 
rental
WHERE inventory_id IN ( -- Выбираем прокаты с инвентарными номерами, в которых есть фильмы из таблицы-выражения films
        SELECT inventory_id
        FROM inventory
        WHERE film_id IN ( -- Выбираем инвентарные номера фильмов, соответствующих фильмам из CTE-выражения films
            SELECT film_id
            FROM films)
        )
GROUP BY customer_id -- Группируем результаты по customer_id
ORDER BY customer_id ASC; -- Сортируем результаты по customer_id в порядке возрастания.
 
    -- Подзапрос
explain ANALYZE -- Sort  (cost=714.03..715.52 rows=599 width=12) (actual time=34.539..34.597 rows=599 loops=1)
SELECT 
customer.customer_id, 
COALESCE(special_rentals.num_behind_scenes_rentals, 0) AS num_behind_scenes_rentals -- Выводим информацию о покупателях и количестве их прокатов фильмов со специальным атрибутом, используя ключевое слово COALESCE для корректного вывода значения 0, если значение столбца является NULL
FROM customer -- Выбираем данные из таблицы customer
LEFT JOIN ( -- Используем JOIN, чтобы включить всех покупателей, даже если у них нет аренд со специальным атрибутом
        SELECT rental.customer_id, COUNT(*) AS num_behind_scenes_rentals -- Отображаем количество прокатов фильмов со специальным атрибутом для каждого покупателя в полях customer_id и num_behind_scenes_rentals
        FROM rental
        JOIN inventory ON rental.inventory_id = inventory.inventory_id -- Объединяем данные по полю inventory_id из таблиц rental и inventory
        WHERE inventory.film_id IN (-- Выбираем данные из таблицы film, которые соответствуют фильмам со специальным атрибутом 'Behind the Scenes'
            SELECT film_id
            FROM film
            WHERE 'Behind the Scenes' = any(special_features) -- Используем функцию any для поиска фильмов со специальным атрибутом в поле special_features
            )
        GROUP BY rental.customer_id
) AS special_rentals ON customer.customer_id = special_rentals.customer_id -- Объединяем данные по полю customer_id из представления customer и выборки special_rentals
ORDER BY customer.customer_id; -- Сортируем выбранные данные по полю customer_id в порядке возрастания

-- вариант с использованием подзапроса вычислений затрачивает меньше ресурсов системы


--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Выполняйте это задание в форме ответа на сайте Нетологии

-- Ниже приведено сравнение двух запросов:

-- Исходный запрос:
-- Используя функцию OVER и оператор PARTITION BY, вычисляем для каждого клиента количество арендованных фильмов.
-- Выполняем полное объединение двух таблиц (обе таблицы содержат информацию о аренде и фильмах),
-- отбираем только те фильмы, которые содержат нужную специальную фичу "Behind the Scenes",
-- затем фильтруем результаты по идентификатору клиента, используя оператор ON.
-- Наконец, сортируем результаты по убыванию количества арендованных фильмов.
explain ANALYZE
select distinct cu.first_name  || ' ' || cu.last_name as name, 
 count(ren.iid) over (partition by cu.customer_id)
from customer cu
full outer join 
 (select *, r.inventory_id as iid, inv.sf_string as sfs, r.customer_id as cid
 from rental r 
 full outer join 
  (select *, unnest(f.special_features) as sf_string
  from inventory i
  full outer join film f on f.film_id = i.film_id) as inv 
  on r.inventory_id = inv.inventory_id) as ren 
 on ren.cid = cu.customer_id 
where ren.sfs like '%Behind the Scenes%'
order by count DESC
-- Использует DISTINCT что может замедлить выполнение запроса, так как серверу базы данных требуется 
-- дополнительное время для проверки результатов на наличие дубликатов и их удаления.
-- Использует полное внешнее соединение, что может приводить к плохой производительности в некоторых случаях.
-- Применяет UNNEST для специальных функций фильма, что усложняет код и может замедлить работу запроса.
-- Использует оконные функции и сортировку с PARTITION BY, что может негативно повлиять на производительность, 
-- особенно при больших объемах данных.
-- Имеет более сложную структуру основного запроса и подзапрос, что затрудняет чтение и оптимизацию запроса.

-- Оптимизированый запрос:
-- Выбираем из таблицы customer имя и фамилию, а также количество арендованных фильмов
-- с помощью функции COUNT, затем делаем левое соединение с таблицами rental, inventory и film,
-- где связь между таблицами осуществляется через соответствующие идентификаторы.
-- Фильтруем фильмы, содержащие специальную фичу "Behind the Scenes" с помощью оператора && и массива.
-- Группируем результаты по идентификатору клиента и его персональным данным,
-- затем сортируем по убыванию количества арендованных фильмов.
explain ANALYZE
SELECT 
  cu.first_name  || ' ' || cu.last_name as name,  
  COUNT(r.inventory_id) as count
FROM 
  customer cu
  LEFT JOIN rental r ON cu.customer_id = r.customer_id
  LEFT JOIN inventory i ON r.inventory_id = i.inventory_id
  LEFT JOIN film f ON i.film_id = f.film_id
  AND special_features && array['Behind the Scenes']
GROUP BY 
  cu.customer_id, 
  cu.first_name, 
  cu.last_name
  ORDER BY 
  count DESC;
-- Не использует DISTINC, так как мы и так работаем с уникальными значениями
-- Использует левое внешнее соединение вместо полного внешнего соединения, что обычно обеспечивает лучшую 
-- производительность и является более предпочтительным вариантом для этой задачи.
-- Применяет оператор && array[...] для фильтрации специальных функций фильма, который более производителен 
-- в PostgreSQL, поскольку он просто проверяет пересечение массивов, не производя UNNEST.
-- Уменьшает сложность запроса, устраняя подзапросы и разделение на окна.
-- Использует простой COUNT(r.inventory_id) для подсчета, что обеспечивает лучшую производительность и простоту кода.

-- Итак, оптимизированный запрос является более предпочтительным, потому что он упрощает структуру запроса, 
-- использует более эффективные операции (такие как левое внешнее соединение и оператор && array[...]) 
-- и обеспечивает лучшую общую производительность.

 -- Построчное описание результатов EXPLAIN ANALYZE на русском языке:

-- 1.  Sort (Сортировка): Сортировка результатов запроса по ключу count(r.inventory_id) в порядке убывания.
   -- Затраты: 492.17..493.67
   -- Реальное время выполнения: 12.97 - 13.027 мс
   -- Используемый метод сортировки: quicksort
   -- Использование памяти: 75 кБ

-- 2.  HashAggregate (Хешированный агрегат): Применение агрегатной функции COUNT() и группировка по cu.customer_id.
   -- Затраты: 455.55..464.54
   -- Реальное время выполнения: 12.555 - 12.777 мс
   -- Количество строк: 599
   -- Количество партиций: 1
   -- Использование памяти: 105 кБ

-- 3.  Hash Right Join (Хешированное правое объединение): Выполнение правого объединения таблиц rental и customer.
   -- Затраты: 22.48..375.33
   -- Реальное время выполнения: 0.292 - 8.204 мс
   -- Количество строк: 16 044

-- 4.  Seq Scan on rental r (Последовательное сканирование таблицы rental): Получение всех строк таблицы rental.
   -- Затраты: 0.00..310.44
   -- Реальное время выполнения: 0.005 - 2.021 мс
   -- Количество строк: 16 044

-- 5.  Hash (Хеширование): Хеширование таблицы customer для быстрого выполнения операции объединения.
   -- Затраты: 14.99
   -- Реальное время выполнения: 0.281 мс
   -- Количество строк: 599
   -- Количество корзин: 1024
   -- Количество партиций: 1
   -- Использование памяти: 39 кБ

-- 6.  Seq Scan on customer cu (Последовательное сканирование таблицы customer): Получение всех строк таблицы customer.
   -- Затраты: 0.00..14.99
   -- Реальное время выполнения: 0.011 - 0.133 мс
   -- Количество строк: 599

-- 7.  Planning Time (Время планирования): Время, затраченное на планирование выполнения запроса.
   -- 0.299 мс

-- 8.  Execution Time (Время выполнения): Общее время, затраченное на выполнение запроса.
   -- 13.152 мс

-- В целом, оптимизированный запрос имеет низкие затраты на выполнение, меньшее использование 
-- памяти и быстрое время выполнения. Это говорит об хорошей производительности запроса.

--ЗАДАНИЕ №2
--Используя оконную функцию выведите для каждого сотрудника
--сведения о самой первой продаже этого сотрудника.

-- Создание временной таблицы (используется WITH) для получения информации о первых платежах каждого сотрудника
WITH first_payment AS (
  SELECT p.staff_id, f.title, p.amount, p.payment_date, 
    c.first_name AS customer_first_name, c.last_name AS customer_last_name,
    ROW_NUMBER() OVER (PARTITION BY p.staff_id ORDER BY p.payment_date) AS payment_num
  -- Присваиваем порядковый номер каждому платежу внутри группы по staff_id, сортируя по дате платежа
  FROM payment p
  JOIN rental r ON p.rental_id = r.rental_id
  JOIN staff s ON p.staff_id = s.staff_id
  JOIN customer c ON p.customer_id = c.customer_id
  JOIN inventory i ON r.inventory_id = i.inventory_id
  JOIN film f ON i.film_id = f.film_id
)
-- Выбираем информацию о первом платеже каждого сотрудника и сортируем результат по staff_id
SELECT staff_id, title, amount, payment_date, customer_first_name, customer_last_name
FROM first_payment
WHERE payment_num = 1
-- Отбираем только записи с первыми платежами каждого сотрудника, используя условие WHERE и значение payment_num, равное 1
ORDER BY staff_id;

--ЗАДАНИЕ №3
--Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
-- 1. день, в который арендовали больше всего фильмов (день в формате год-месяц-день)
-- 2. количество фильмов взятых в аренду в этот день
-- 3. день, в который продали фильмов на наименьшую сумму (день в формате год-месяц-день)
-- 4. сумму продажи в этот день

-- Используем Common Table Expressions (CTE) для создания временных таблиц, которые будут участвовать в итоговом запросе
WITH
-- подсчитываем количество арендованных фильмов для каждого магазина на ежедневной основе
rentals_per_day AS (
  SELECT i.store_id, DATE(r.rental_date) AS rental_day, COUNT(*) AS num_rentals
  FROM rental r
  JOIN inventory i ON r.inventory_id = i.inventory_id
  GROUP BY i.store_id, DATE(r.rental_date)
),
-- подсчитываем сумму продаж для каждого магазина на ежедневной основе
sales_per_day AS (
  SELECT s.store_id, DATE(p.payment_date) AS payment_day, SUM(p.amount) AS total_sales
  FROM payment p
  JOIN staff st ON p.staff_id = st.staff_id
  JOIN store s ON st.store_id = s.store_id
  GROUP BY s.store_id, DATE(p.payment_date)
),
-- определяем день в магазине с максимальным числом арендованных фильмов
day_with_max_rentals AS (
  SELECT store_id, rental_day, num_rentals,
    RANK() OVER (PARTITION BY store_id ORDER BY num_rentals DESC) AS num_rentals_rank
  FROM rentals_per_day
),
-- определяем день в магазине с минимальной суммой продаж
day_with_min_sales AS (
  SELECT store_id, payment_day, total_sales,
    RANK() OVER (PARTITION BY store_id ORDER BY total_sales) AS total_sales_rank
  FROM sales_per_day
)
-- выбираем идентификатор каждого магазина, день с максимальным количеством арендованных фильмов, 
-- день с минимальной суммой продаж и соответствующие значения.
SELECT s.store_id,
  day_with_max_rentals.rental_day AS day_with_max_rentals,
  day_with_max_rentals.num_rentals AS max_daily_rentals_count,
  day_with_min_sales.payment_day AS day_with_min_sales,
  day_with_min_sales.total_sales
FROM store s
JOIN day_with_max_rentals ON s.store_id = day_with_max_rentals.store_id AND num_rentals_rank = 1
JOIN day_with_min_sales ON s.store_id = day_with_min_sales.store_id AND total_sales_rank = 1
ORDER BY s.store_id;












