		-- Итоговый проект по курсу «SQL и получение данных» - Кондратьев С.П.



	-- Задание №1
-- Выведите названия самолётов, которые имеют менее 50 посадочных мест.

-- Выбираем коды самолетов, подсчитываем количество мест в каждом самолете и модель самолета
SELECT 
seats.aircraft_code, 
count(seats.seat_no) AS count_seat_no,
aircrafts.model 
-- Подключаем таблицу seats и таблицу aircrafts по полю aircraft_code
FROM seats
JOIN aircrafts ON seats.aircraft_code = aircrafts.aircraft_code 
-- Группируем данные по коду самолета и модели самолета
GROUP BY seats.aircraft_code, aircrafts.model
-- Отбираем только те группы, в которых количество мест в самолете меньше 50
HAVING  count(seats.seat_no) < 50;



	-- Задание №2
-- Выведите процентное изменение ежемесячной суммы бронирования билетов, округленной до сотых.

-- Этот SQL-запрос содержит две основные части: подзапрос monthly_totals и общий запрос.
-- В подзапросе monthly_totals сначала выбираем месяц (формат 'YYYY-MM') и общую сумму для каждого месяца на основе данных из таблицы bookings.
WITH monthly_totals AS (
  SELECT 
    TO_CHAR(book_date, 'YYYY-MM') AS month, -- Конвертируем дату бронирования в формат год-месяц
    SUM(total_amount) AS total_amount -- Рассчитываем общую сумму по каждому месяцу
  FROM bookings
  GROUP BY TO_CHAR(book_date, 'YYYY-MM') -- Группируем данные по месяцам
)
-- В основном запросе выбираем месяц, общую сумму и процентное изменение общей суммы по сравнению с предыдущим месяцем.
SELECT 
  month,  -- Выбираем месяц
  total_amount, -- Выбираем общую сумму
  round((total_amount - LAG(total_amount) OVER (ORDER BY month)) / LAG(total_amount) OVER (ORDER BY month) * 100, 2) as percent_change 
  -- Рассчитываем процентное изменение общей суммы по сравнению с предыдущим месяцем и округляем до 2 знаков после запятой
FROM monthly_totals -- Источник данных - подзапрос monthly_totals
ORDER BY MONTH; -- Сортируем данные по месяцам
-- LAG - это оконная функция, которая возвращает значение предыдущей строки в сортированном порядке. 
-- ROUND - функция, которая округляет число до заданного количества десятичных знаков.



	-- Задание №3
-- Выведите названия самолётов без бизнес-класса. Используйте в решении функцию array_agg.

-- Выбираем код самолета и модель из таблицы "aircrafts"
SELECT 
  aircrafts.aircraft_code,
  aircrafts.model 
-- Начинаем подзапрос
FROM (
  -- Выбираем код самолета
  SELECT
    aircraft_code,
    -- Создаем массив из уникальных значений "fare_conditions"
    -- для каждого "aircraft_code"
    array_agg(DISTINCT fare_conditions) as fare_types
  -- Из таблицы "seats"
  FROM seats
  -- Группируем результаты по "aircraft_code"
  GROUP BY aircraft_code
-- Заканчиваем подзапрос и даем ему псевдоним "seats_agg"
) as seats_agg
-- Присоединяем таблицу "aircrafts" по "aircraft_code"
JOIN aircrafts ON seats_agg.aircraft_code = aircrafts.aircraft_code 
-- В условии отбираем строки, в которых 'Business'
-- не входит в массив "fare_types"
WHERE NOT ('Business' = ANY (seats_agg.fare_types));



	-- Задание №4
-- Выведите накопительный итог количества мест в самолётах по каждому аэропорту на каждый день. 
-- Учтите только те самолеты, которые летали пустыми и только те дни, когда из одного аэропорта вылетело более одного такого самолёта.
-- Выведите в результат код аэропорта, дату вылета, количество пустых мест и накопительный итог.

-- Шаг 1: Находим максимальное количество свободных мест для каждой пары аэропорт-дата вылета
WITH max_flight_numbers AS (
    SELECT
        flights_v.departure_airport AS airport_code, -- выбираем код аэропорта отправления
        TO_CHAR(flights_v.actual_departure, 'YYYY-MM-DD HH24:MI') AS flight_date, -- преобразуем фактическую дату вылета в формат "ГГГГ-ММ-ДД ЧЧ:ММ"
        COUNT(seats.seat_no) AS empty_seats, -- подсчитываем количество свободных мест
        SUM(COUNT(seats.seat_no)) OVER (PARTITION BY flights_v.departure_airport ORDER BY TO_CHAR(flights_v.actual_departure, 'YYYY-MM-DD HH24:MI')) AS cumulative_empty_seats 
        -- вычисляем накопительную сумму свободных мест для каждого аэропорта, упорядоченную по дате вылета
    FROM seats
    JOIN flights_v ON flights_v.aircraft_code = seats.aircraft_code -- соединяем таблицы seats и flights_v по коду самолета
    LEFT JOIN boarding_passes ON boarding_passes.flight_id = flights_v.flight_id -- делаем left join с таблицей boarding_passes по id полета
    WHERE
        boarding_passes.boarding_no IS NULL -- фильтруем строки, где номер посадочного талона равен NULL (то есть место не занято пассажиром)
        AND flights_v.actual_departure < bookings.now() -- фильтруем строки, где время вылета меньше текущего времени
    GROUP BY flights_v.departure_airport, TO_CHAR(flights_v.actual_departure, 'YYYY-MM-DD HH24:MI') -- группируем данные по коду аэропорта и дате вылета
)
-- Шаг 2: Выбираем данные из подзапроса, где количество полетов для каждого аэропорта больше 1
SELECT
    airport_code, -- выбираем код аэропорта
    flight_date, -- выбираем дату вылета
    empty_seats, -- выбираем количество свободных мест
    cumulative_empty_seats -- выбираем накопительную сумму свободных мест
FROM (
    -- Добавляем количество полетов для каждого аэропорта
    SELECT
        *,
        COUNT(*) OVER (PARTITION BY airport_code) AS flights_count -- подсчитываем количество полетов для каждого аэропорта
    FROM max_flight_numbers
) subquery
WHERE flights_count > 1 -- фильтруем данные, где количество полетов больше 1
ORDER BY airport_code, flight_date; -- сортируем данные по коду аэропорта и дате вылета



	-- Задание №5
-- Найдите процентное соотношение перелётов по маршрутам от общего количества перелётов. 
-- Выведите в результат названия аэропортов и процентное отношение.
-- Используйте в решении оконную функцию.

-- Шаг 1: Создание временной таблицы t_2, где для каждой пары аэропортов подсчитывается количество полетов и общее количество полетов
WITH t_2 AS (
   SELECT 
    departure_airport_name,
    arrival_airport_name,
    COUNT(*) OVER (PARTITION BY departure_airport_name, arrival_airport_name) AS count_2, -- Подсчет количества полетов для конкретной пары аэропортов
    SUM(COUNT(*)) OVER () AS total_count -- Подсчет общего количества полетов для всех пар аэропортов
FROM 
    flights_v
WHERE
    flights_v.actual_departure < bookings.now() -- Выбираем только полеты, где фактическое время вылета меньше текущего времени
GROUP BY 
    flight_id, 
    departure_airport_name,
    arrival_airport_name
ORDER BY 
    departure_airport_name,
    arrival_airport_name
)
-- Шаг 2: Выбираем из временной таблицы t_2 данные о названиях аэропортов и вычисляем процентное соотношение количества полетов от общего количества
SELECT
    t_2.departure_airport_name,
    t_2.arrival_airport_name, 
    ROUND((count_2*100/total_count), 2) AS percentage_ratio_of_total -- Вычисляем процентное соотношение количества полетов от общего количества, и округляем до 2 знаков после запятой
FROM t_2
ORDER BY 
    t_2.departure_airport_name,
    t_2.arrival_airport_name

    
    
    	-- Задание №6
    -- Выведите количество пассажиров по каждому коду сотового оператора. 
    -- Код оператора – это три символа после +7
    
SELECT 
    -- Извлекаем подстроку из поля "phone" в JSON-структуре "contact_data" начиная с позиции 3 (включительно)
    -- и состоящую из 3 символов. Результат называем "operator_code".
    -- Данная подстрока будет содержать код оператора связи телефона.
    SUBSTRING(contact_data->>'phone', 3, 3) AS operator_code,
    -- Подсчитываем общее количество записей (пассажиров) в таблице "tickets".
    COUNT(*) AS passenger_count
FROM 
    -- Выбираем данные из таблицы "tickets".
    tickets
GROUP BY 
    -- Группируем результаты по значению "operator_code".
    operator_code
ORDER BY 
    -- Сортируем результаты по значению "operator_code".
    operator_code;

   
   
	-- Задание №7
-- Классифицируйте финансовые обороты (сумму стоимости билетов) по маршрутам:
-- до 50 млн – low
-- от 50 млн включительно до 150 млн – middle
-- от 150 млн включительно – high
-- Выведите в результат количество маршрутов в каждом полученном классе.
   
-- Шаг 1: Создаем временную таблицу 't', чтобы рассчитать общую сумму билетов для каждого маршрута
-- В этом шаге мы используем таблицы ticket_flights и flights, объединяем их по идентификатору рейса 
-- и агрегируем общую сумму проданных билетов для каждого маршрута
WITH t AS (
    SELECT departure_airport  || ' ' || arrival_airport AS routes, SUM(ticket_flights.amount) AS total_sum
    FROM ticket_flights
    JOIN flights ON flights.flight_id = ticket_flights.flight_id
    WHERE flights.actual_departure < bookings.now() -- Выбираем только полеты, где фактическое время вылета меньше текущего времени
    GROUP BY routes
)
-- Шаг 2: Создаем подзапрос, чтобы разделить общую сумму на классы
-- В этом шаге мы используем временную таблицу 't' из шага 1. 
-- Затем мы помечаем каждый маршрут соответствующим классом с использованием выражения CASE.
SELECT sum_class, COUNT(*) AS count_routes
FROM (
    SELECT routes, total_sum,
        CASE
            WHEN total_sum < 50000000 THEN 'low - (< 50 mill)'
            WHEN total_sum >= 50000000 AND total_sum <= 150000000 THEN 'middle - (>=50 <=150 mill)'
            WHEN total_sum >= 150000000 THEN 'high - (>= 150 mill)'
        END AS sum_class
    FROM t
) t_2
WHERE sum_class IS NOT NULL
GROUP BY sum_class
ORDER BY count_routes;



	-- Задание №8
-- Вычислите медиану стоимости билетов, медиану стоимости бронирования и отношение медианы 
-- бронирования к медиане стоимости билетов, результат округлите до сотых.

WITH median AS
(
SELECT 
 (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_amount) -- Находим медианное значение общей суммы бронирований 
 FROM  bookings													  -- и сохраняем в median_bookings_amount	
 ) AS median_bookings_amount,
 (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY amount) -- Находим медианное значение суммы билетов и сохраняем в median_ticket_amount
 FROM ticket_flights
 ) AS median_ticket_amount,
 ((SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY total_amount) AS median_bookings_amount 
 FROM bookings)/
 (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY amount) AS median_ticket_amount 
 FROM ticket_flights)) AS ratio -- Вычисляем отношение медианной суммы бронирований к медианной сумме билетов и сохраняем в переменную ratio
 )
 SELECT 
 median_bookings_amount, -- Выводим медианное значение общей суммы бронирований
 median_ticket_amount, -- Выводим медианное значение суммы билетов
 ROUND(ratio::NUMERIC, 2) -- Выводим результат отношения медианной суммы бронирований к медианной сумме билетов, 
 FROM median			  -- округленный до 2 знаков после запятой

 
 
 	-- Задание №9	
 -- Найдите значение минимальной стоимости одного километра полёта для пассажира. 
 -- Для этого определите расстояние между аэропортами и учтите стоимость билетов.

 WITH cost_km AS
(
    SELECT
        airport_name AS D_airport_name,
        longitude AS D_longitude,
        latitude AS D_latitude,
        airport_code AS D_airport_code,
        arrival_airport,
        amount
    FROM
        airports
    JOIN
        flights
        ON airports.airport_code = flights.departure_airport
    JOIN
        ticket_flights
        ON ticket_flights.flight_id = flights.flight_id
    WHERE
        flights.actual_departure < bookings.now()
)
SELECT
longitude,
        latitude,
        airport_name,
    cost_km.*,
    earth_distance(ll_to_earth(cost_km.D_latitude, cost_km.D_longitude), ll_to_earth(airports.latitude, airports.longitude)) / 1000 AS distance,
    cost_km.amount / (earth_distance(ll_to_earth(cost_km.D_latitude, cost_km.D_longitude), ll_to_earth(airports.latitude, airports.longitude)) / 1000) AS cost_of_flight_km
FROM
    cost_km
JOIN
    airports
    ON airports.airport_code = cost_km.arrival_airport
    ORDER BY cost_of_flight_km
    LIMIT 1;


-- Создаем подзапрос с именем cost_km, который будет использован для расчета дальнейших результатов
WITH cost_km AS
(
    -- В подзапросе мы собираем данные от нескольких таблиц, используя оператор JOIN
    SELECT
        airport_name AS D_airport_name,  -- Получаем название аэропорта и переименовываем его с помощью AS для дальнейшего использования
        longitude AS D_longitude,  -- Получаем долготу аэропорта отправления и переименовываем
        latitude AS D_latitude,  -- Получаем широту аэропорта отправления и переименовываем
        airport_code AS D_airport_code,  -- Получаем код аэропорта отправления и переименовываем
        arrival_airport,  -- Получаем аэропорт назначения 
        amount  -- Получаем стоимость билета на рейс
    FROM
        airports  -- Объявляем основную таблицу для запроса 
    JOIN
        flights  -- Соединяем таблицы airports и flights для огогащения широтой и долготой аэропорта отправления
        ON airports.airport_code = flights.departure_airport  -- Условие соединения по коду аэропорта и аэропорту отправления
    JOIN
        ticket_flights  -- Соединяем результат соединения выше таблицы с таблицей ticket_flights
        ON ticket_flights.flight_id = flights.flight_id  -- Условие соединения по идентификатору рейса
    WHERE
        flights.actual_departure < bookings.now()  -- Фильтрация данных, где время фактического вылета меньше текущего времени
)
--  Теперь основной запрос использует данные из подзапроса cost_km
SELECT
    longitude,  -- Включаем долготу аэропорта прибытия 
    latitude,  -- Включаем широту аэропорта прибытия
    airport_name,  -- Название аэропорта прибытия
    cost_km.*,  -- Все данные из подзапроса
    -- Теперь считаем расстояние между аэропортами в километрах, используя географические координаты двух точек и функцию earth_distance
    earth_distance(ll_to_earth(cost_km.D_latitude, cost_km.D_longitude), ll_to_earth(airports.latitude, airports.longitude)) / 1000 AS distance,
    -- Теперь рассчитываем стоимость одного километра полета, поделив стоимость билета на расстояние
    cost_km.amount / (earth_distance(ll_to_earth(cost_km.D_latitude, cost_km.D_longitude), ll_to_earth(airports.latitude, airports.longitude)) / 1000) AS cost_of_flight_km
FROM
    cost_km  -- Используем данные из подзапроса
JOIN
    airports  -- Соединяем данные из подзапроса с таблицей airports для обогащения широтой и долготой аэропорта прибытия
    ON airports.airport_code = cost_km.arrival_airport  -- Условие соединения - код аэропорта и аэропорт прибытия
ORDER BY cost_of_flight_km  -- Сортируем результаты по стоимости одного километра полета
LIMIT 1;  -- ограничиваем результат одним значением (самый дешевый километр полета)
