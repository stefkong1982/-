Задание 1. Откройте по ссылке SQL-запрос.

explain analyze
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
order by count desc

explain analyze --625.09 / 7 
select c.first_name || ' ' || c.last_name, count(r.rental_id)
from rental r
right join inventory i on 
	r.inventory_id = i.inventory_id and 
	i.film_id in (
		select film_id
		from film
		where special_features && array['Behind the Scenes'])
join customer c on c.customer_id = r.customer_id
group by c.customer_id

explain analyze -- 646.34 / 8 
select r.customer_id, count(r.rental_id)
from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
where f.special_features && array['Behind the Scenes']
group by 1


--ЛОЖНЫЙ ЗАПРОС
explain analyze -- 158.76 / 10 
select r.customer_id, count(r.rental_id)
from rental r
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
where special_features::text like '%Behind the Scenes%'
group by 1

explain analyze --733 / 7
select c.first_name || ' ' || c.last_name, count(r.rental_id)
from rental r
join customer c on c.customer_id = r.customer_id
where r.inventory_id in (
	select inventory_id
	from inventory   
	where film_id in (
		select film_id
		from film
		where special_features && array['Behind the Scenes']))
group by c.customer_id

Сделайте explain analyze этого запроса.
Основываясь на описании запроса, найдите узкие места и опишите их.
Сравните с вашим запросом из основной части (если ваш запрос изначально укладывается в 15мс — отлично!).
Сделайте построчное описание explain analyze на русском языке оптимизированного запроса. Описание строк в explain можно посмотреть по ссылке.

Задание 2. Используя оконную функцию, выведите для каждого сотрудника сведения о первой его продаже.
Ожидаемый результат запроса: letsdocode.ru...in/6-5.png

explain analyze --2426
select p.*, f.title
from (
	select staff_id, rental_id, row_number() over (partition by staff_id order by payment_date)
	from payment) p 
join rental r on r.rental_id = p.rental_id
join inventory i on r.inventory_id = i.inventory_id
join film f on f.film_id = i.film_id
where row_number = 1

Задание 3. Для каждого магазина определите и выведите одним SQL-запросом следующие аналитические показатели:
день, в который арендовали больше всего фильмов (в формате год-месяц-день);
количество фильмов, взятых в аренду в этот день;
день, в который продали фильмов на наименьшую сумму (в формате год-месяц-день);
сумму продажи в этот день.
Ожидаемый результат запроса: letsdocode.ru...in/6-6.png

explain analyze --5020.68 / 15
select *
from (
	select i.store_id, count(r.rental_id), r.rental_date::date,
		row_number() over (partition by i.store_id order by count(r.rental_id) desc)
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	group by 1, 3) r 
join (
	select s.store_id, p.payment_date::date, sum(amount),
		row_number() over (partition by s.store_id order by sum(amount))
	from payment p 
	join staff s on p.staff_id = s.staff_id
	group by 1, 2) p on p.store_id = r.store_id
where p.row_number = 1 and r.row_number = 1

платеж 			аренда
сотруднику		сотруднику
диску			диску
пользователю	пользователю
сотруднику		диску
сотруднику		пользователю
диску			сотруднику
диску			пользователю
пользователю	сотруднику
пользователю	диску	

explain analyze --5611.62 / 22
select *
from (
	select i.store_id, count(r.rental_id), r.rental_date::date,
		row_number() over (partition by i.store_id order by count(r.rental_id) desc)
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	group by 1, 3) r 
join (
	select i.store_id, p.payment_date::date, sum(amount),
		row_number() over (partition by i.store_id order by sum(amount))
	from payment p 
	left join rental r on r.rental_id = p.rental_id
	left join inventory i on i.inventory_id = r.inventory_id
	group by 1, 2) p on p.store_id = r.store_id
where p.row_number = 1 and r.row_number = 1

explain analyze --3283.81 / 15
with cte1 as (
	select i.store_id, count(r.rental_id), r.rental_date::date
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	group by 1, 3), 
cte2 as (
	select s.store_id, p.payment_date::date, sum(amount)
	from payment p 
	join staff s on p.staff_id = s.staff_id
	group by 1, 2)
select *
from cte1
join cte2 on cte1.store_id = cte2.store_id
where (cte1.store_id, count) in (select store_id, max(count) from cte1 group by store_id) and 
	(cte1.store_id, sum) in (select store_id, min(sum) from cte2 group by store_id)
	
explain analyze --3308.88 / 35
with cte1 as (
	select i.store_id, r.rental_date::date, p.payment_date::date, p.amount, r.rental_id
	from rental r
	join inventory i on i.inventory_id = r.inventory_id
	full join payment p on r.rental_id = p.rental_id),
cte2 as (
	select store_id, rental_date, count(rental_id)
	from cte1 
	group by store_id, rental_date
	having (store_id, count(rental_id)) in (
		select store_id, max(count) 
		from (
			select store_id, count(rental_id)
			from cte1 
			group by store_id, rental_date) t
		group by store_id)),
cte3 as (
	select store_id, payment_date, sum(amount)
	from cte1 
	group by store_id, payment_date
	having (store_id, sum(amount)) in (
		select store_id, min(sum) 
		from (
			select store_id, sum(amount)
			from cte1 
			group by store_id, payment_date) t
		group by store_id))
select *
from cte2
join cte3 on cte2.store_id = cte3.store_id
	