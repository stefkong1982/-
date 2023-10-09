--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате платежа
--Пронумеруйте платежи для каждого покупателя, сортировка платежей должна быть по дате платежа
--Посчитайте нарастающим итогом сумму всех платежей для каждого покупателя, сортировка должна 
--быть сперва по дате платежа, а затем по размеру платежа от наименьшей к большей
--Пронумеруйте платежи для каждого покупателя по размеру платежа от наибольшего к
--меньшему так, чтобы платежи с одинаковым значением имели одинаковое значение номера.
--Можно составить на каждый пункт отдельный SQL-запрос, а можно объединить все колонки в одном запросе.

SELECT 
    payment_id, -- идентификатор платежа
    customer_id, -- идентификатор покупателя
    staff_id, -- идентификатор сотрудника
    rental_id, -- идентификатор аренды
    amount, -- сумма платежа
    payment_date, -- дата платежа
    ROW_NUMBER() OVER(ORDER BY payment_date) as payment_number_by_date, -- вычисление номера платежа по дате платежа
    ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date) as payment_number_by_customer, -- вычисление номера платежа для каждого покупателя, сортировка по дате платежа
    SUM(amount) OVER(PARTITION BY customer_id ORDER BY payment_date, amount) as cumulative_amount_by_customer, -- вычисление нарастающего итога суммы всех платежей для каждого покупателя, сортировка по дате платежа, а затем по размеру платежа (от наименьшей к большей)
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY amount DESC) as payment_rank_by_customer -- вычисление номера платежа для каждого покупателя по размеру платежа (от наибольшего к меньшему, платежи с одинаковым значением имеют одинаковый номер)
FROM 
    payment; -- таблица, к которой происходит присоединение новых колонок

--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого покупателя стоимость платежа и стоимость 
--платежа из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате платежа.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,  -- Объединяем first_name и last_name в один столбец customer_name, применяя функцию CONCAT
    c.customer_id, -- идентификатор покупателя
    p.payment_date, -- Выбираем дату платежа
    p.amount, -- Выбираем стоимость платежа
    LAG(p.amount, 1, 0.0) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS prev_payment_amount
    -- Используем параметры LAG для получения значения стоимости платежа из предыдущей строки, 
    -- группируя данные по идентификатору покупателя и сортируя по дате платежа.
FROM 
    payment p -- Выбираем данные из таблицы payment
JOIN 
    customer c -- Выбираем данные из таблицы customer
ON 
    p.customer_id = c.customer_id -- Соединяем данные по идентификатору покупателя
ORDER BY 
    p.payment_date; -- Сортируем по дате платежа в возрастающем порядке.

--ЗАДАНИЕ №3
--С помощью оконной функции определите, на сколько каждый следующий платеж покупателя больше или меньше текущего.

-- Выбираем фамилию и имя покупателя, объединив их в один столбец customer_name с помощью функции CONCAT.
-- Указываем, что выбранный столбец относится к таблице customer.
-- При этом нужно отметить, что ключ customer_id используется в обоих таблицах, поэтому его нужно указывать 
-- при обращении к этому столбцу в запросе, например, как c.customer_id.
SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.customer_id,
    p.payment_id,
    p.payment_date,
    p.amount,
    -- Используем функцию LAG для получения значения стоимости платежа из предыдущей строки сгруппированных данных по идентификатору покупателя 
    -- и отсортированных по дате платежа, чтобы определить разницу между текущим и предыдущим платежами.
    -- Разница может быть как положительной, так и отрицательной.
    p.amount - LAG(p.amount, 1, 0.0) OVER (PARTITION BY p.customer_id ORDER BY p.payment_date) AS difference_amount
FROM 
    payment p -- Выбираем данные из таблицы payment
JOIN 
    customer c -- Выбираем данные из таблицы customer
ON 
    p.customer_id = c.customer_id -- Соединяем данные по идентификатору покупателя
-- Сортируем данные по идентификатору покупателя в возрастающем порядке.
-- Это позволит группировать данные по каждому покупателю, чтобы можно было определить разницу между суммой платежей.
-- Если будут выбраны другие столбцы для сортировки, то это приведет к разбиению на группы по другому принципу, что даст неверные результаты.
ORDER BY 
    c.customer_id;

--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, -- объединяем first_name и last_name в один столбец customer_name с помощью функции CONCAT
    p.customer_id, -- выбираем идентификатор покупателя
    p.payment_id, -- выбираем идентификатор платежа
    p.payment_date, -- выбираем дату платежа
    p.amount -- выбираем сумму платежа
FROM 
    (
        -- Создаем подзапрос, который выбирает данные о платежах.
        -- Используем оконную функцию ROW_NUMBER(), чтобы присвоить каждому платежу номер в рамках группы, 
        -- создаваемой PARTITION BY p.customer_id и упорядочиваемой ORDER BY p.payment_date DESC.
        -- Таким образом, платежи будут нумероваться в порядке убывания даты платежа.
        -- После этого выбираем только те строки, которые имеют номер 1, то есть самые последние платежи.
        SELECT 
            payment_id, 
            customer_id, 
            payment_date,
            amount,
            ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY payment_date DESC) AS row_num
        FROM payment
    ) p -- задаем псевдоним для подзапроса
JOIN 
    customer c -- объединяем данные с таблицей customer
ON 
    p.customer_id = c.customer_id -- соединяем данные по идентификатору покупателя
-- Оставляем только те строки, где номер платежа равен 1 (то есть самый последний платеж), 
-- и группируем по идентификатору покупателя, чтобы получить только одну запись для каждого покупателя.
WHERE 
    p.row_num = 1
GROUP BY 
    customer_name,
    p.customer_id, 
    p.payment_id, 
    p.payment_date, 
    p.amount
ORDER BY 
    p.customer_id ASC; -- сортируем по идентификатору покупателя в возрастающем порядке.



--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

-- Выбираем и объединяем имя и фамилию сотрудника в единый столбец name, указываем id сотрудника, дату платежа и сумму платежа. 
SELECT 
    CONCAT(s.first_name || '' || s.last_name) AS name, -- Объединяем first_name и last_name в один столбец name, используя функцию CONCAT
    p.staff_id, -- Указываем, что столбец staff_id относится к таблице payment
    p.payment_date, -- Выбираем дату платежа и используем приведение типа payment_date к date
    SUM(p.amount) AS amount, -- Рассчитываем сумму платежа и присваиваем ей псевдоним amount
    -- Рассчитываем накопленную сумму платежей для каждого сотрудника для каждой даты платежа. Для этого используем оконную функцию SUM, сгруппированную по id сотрудника и отсортированную по дате платежа.
    SUM(SUM(p.amount)) OVER (PARTITION BY p.staff_id ORDER BY p.payment_date::date) AS running_total
FROM payment p
JOIN staff s ON s.staff_id = p.staff_id -- Присоединяем таблицу staff к таблице payment по id сотрудника
WHERE EXTRACT(YEAR FROM p.payment_date) = 2005 -- Ограничиваем выборку платежей за август 2005 года
    AND EXTRACT(MONTH FROM p.payment_date) = 8
GROUP BY 
    name, -- Группируем данные по имени, чтобы получить информацию о каждом платеже отдельно для каждого сотрудника и даты
    p.staff_id,
    p.payment_date
ORDER BY p.staff_id, payment_date; -- Сортируем данные по id сотрудника и дате платежа в возрастающем порядке.

--ЗАДАНИЕ №2
--20 августа 2005 года в магазинах проходила акция: покупатель каждого сотого платежа получал
--дополнительную скидку на следующую аренду. С помощью оконной функции выведите всех покупателей,
--которые в день проведения акции получили скидку

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name, -- объединяем first_name и last_name в один столбец customer_name, применяя функцию CONCAT
    p.customer_id, -- выбираем идентификатор покупателя
    p.payment_date, -- выбираем дату платежа
    p.amount, -- выбираем сумму платежа
    numbering.row_number -- выбираем номер строки, соответствующей данному платежу
FROM 
    payment p -- выбираем данные из таблицы payment
INNER JOIN 
    (SELECT 
         payment_id, 
         ROW_NUMBER() OVER (ORDER BY payment_date) AS row_number 
         -- генерируем ряд натуральных чисел, соответствующий позициям строк таблицы payment при сортировке по дате платежа, используя оконную функцию ROW_NUMBER()
     FROM 
         payment) AS numbering 
         -- выбираем payment_id и row_number из сгенерированного ряда натуральных чисел
ON 
    p.payment_id = numbering.payment_id -- присоединяем к таблице payment данные из внутреннего запроса с нумерацией строк
JOIN 
    customer c -- выбираем данные из таблицы customer
ON 
    p.customer_id = c.customer_id -- присоединяем данные из таблицы customer по идентификатору покупателя
WHERE 
    numbering.row_number % 100 = 0 AND -- выбираем только строки с номером, который делится на 100 без остатка, соответствующие условию задачи
    p.payment_date >= '2005-08-20 00:00:00' AND p.payment_date < '2005-08-21 00:00:00' -- выбираем только платежи, соответствующие условиям задачи
ORDER BY 
    numbering.row_number; -- сортируем результаты по номеру строки в возрастающем порядке, соответствующем порядку записей в таблице payment, сгенерированному нашей оконной функцией

--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

SELECT 
    co.country AS страна, -- Выбираем столбец страны, используя псевдоним co
    ar.max_rental_customer AS покупатель_макс_аренда, -- Выбираем столбец покупатель_макс_аренда, используя подзапрос ar
    amt.max_amount_customer AS покупатель_макс_потрачено, -- Выбираем столбец покупатель_макс_потрачено, используя подзапрос amt
    lst.last_renter AS последний_арендатор -- Выбираем столбец последний_арендатор, используя подзапрос lst
FROM 
    country co -- Выбираем данные таблицы country, используя псевдоним co
    LEFT JOIN (
        SELECT 
            ci.country_id, -- Выбираем идентификатор страны
            CONCAT(c.first_name, ' ', c.last_name) AS max_rental_customer, -- Объединяем first_name и last_name в один столбец для получения имени покупателя, который сделал максимальный прокат. Псевдоним st_rental_customer
            COUNT(DISTINCT r.rental_id) AS rental_count, -- Выбираем количество уникальных rental_id и используем функцию COUNT. Псевдоним rental_count
            ROW_NUMBER() OVER (PARTITION BY ci.country_id ORDER BY COUNT(DISTINCT r.rental_id) DESC) AS rn -- Нумеруем строки от 1 до ограничения PARTITION по country_id, сортируя по убыванию текущего rental_count. Псевдоним rn
        FROM 
            customer c -- Подключаем таблицу customer
            JOIN address a ON c.address_id = a.address_id -- Соединяем таблицы customer и address по address_id
            JOIN city ci ON a.city_id = ci.city_id -- Соединяем таблицы address и city по city_id
            JOIN country co ON ci.country_id = co.country_id -- Соединяем таблицы city и country по country_id
            JOIN rental r ON c.customer_id = r.customer_id -- Соединяем таблицы customer и rental по customer_id
        GROUP BY 
            ci.country_id, 
            max_rental_customer -- Группируем данные по id стран и максимальному покупателю проката
    ) ar ON co.country_id = ar.country_id AND ar.rn = 1  -- Подключаем podzaprosp ar по общей country_id между главным запросом и подзапросом и добавляем условие на номер строки 
    LEFT JOIN (
        SELECT 
            ci.country_id, 
            CONCAT(c.first_name || ' ' || c.last_name) AS max_amount_customer, -- Объединяем first_name и last_name в один столбец для получения имени покупателя с максимальной потраченной суммой. Псевдоним st_amount_customer
            SUM(p.amount) AS total_amount, -- Выбираем сумму платежей по каждому покупателю, используя функцию SUM. Псевдоним total_amount
            ROW_NUMBER() OVER (PARTITION BY ci.country_id ORDER BY SUM(p.amount) DESC) AS rn -- Нумеруем строки от 1 до ограничения PARTITION по country_id, сортируя по убыванию текущего total_amount. Псевдоним rn
        FROM 
            customer c -- Подключаем таблицу customer
            JOIN address a ON c.address_id = a.address_id -- Соединяем таблицы customer и address по address_id
            JOIN city ci ON a.city_id = ci.city_id -- Соединяем таблицы address и city по city_id
            JOIN country co ON ci.country_id = co.country_id -- Соединяем таблицы city и country по country_id
            JOIN payment p ON c.customer_id = p.customer_id -- Соединяем таблицы customer и payment по customer_id
        GROUP BY 
            ci.country_id, 
            max_amount_customer -- Группируем данные по id стран и покупателям с максимальной потраченной суммой
    ) amt ON co.country_id = amt.country_id AND amt.rn = 1 -- Подключаем подзапрос amt по общей country_id между главным запросом и подзапросом и добавляем условие на номер строки 
    LEFT JOIN (
        SELECT 
            ci.country_id, 
            CONCAT(c.first_name, ' ', c.last_name) AS last_renter, -- Объединяем first_name и last_name в один столбец для получения имени последнего арендатора. Псевдоним last_renter
            MAX(r.rental_date) AS rental_date, -- Выбираем максимальную дату проката, используя функцию MAX. Псевдоним rental_date
            ROW_NUMBER() OVER (PARTITION BY ci.country_id ORDER BY MAX(r.rental_date) DESC) AS rn -- Нумеруем строки от 1 до ограничения PARTITION по country_id, сортируя по убыванию текущей rental_date. Псевдоним rn
        FROM 
            customer c -- Подключаем таблицу customer
            JOIN address a ON c.address_id = a.address_id -- Соединяем таблицы customer и address по address_id
            JOIN city ci ON a.city_id = ci.city_id -- Соединяем таблицы address и city по city_id
            JOIN country co ON ci.country_id = co.country_id -- Соединяем таблицы city и country по country_id
            JOIN rental r ON c.customer_id = r.customer_id -- Соединяем таблицы customer и rental по customer_id
        GROUP BY 
            ci.country_id, 
            last_renter -- Группируем данные по id стран и последнему арендатору
    ) lst ON co.country_id = lst.country_id AND lst.rn = 1 -- Подключаем подзапрос lst по общей country_id между главным запросом и подзапросом и добавляем условие на номер строки 
ORDER BY 
    co.country; -- Сортируем данные по столбцу страны





