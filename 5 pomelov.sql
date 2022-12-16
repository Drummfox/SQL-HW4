--=============== МОДУЛЬ 5. РАБОТА С POSTGRESQL =======================================
--= ПОМНИТЕ, ЧТО НЕОБХОДИМО УСТАНОВИТЬ ВЕРНОЕ СОЕДИНЕНИЕ И ВЫБРАТЬ СХЕМУ PUBLIC===========
SET search_path TO public;

--======== ОСНОВНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--Сделайте запрос к таблице payment и с помощью оконных функций добавьте вычисляемые колонки согласно условиям:
--Пронумеруйте все платежи от 1 до N по дате


select payment_id, payment_date, row_number () over (order by payment_date)
from payment p 




--ЗАДАНИЕ №2
--Используя оконную функцию, добавьте колонку с порядковым номером продажи для каждого покупателя, 
--сортировка платежей должна быть по дате.

select payment_id, payment_date, customer_id, row_number () over (partition by customer_id  order by payment_date) 
from payment p 




--ЗАДАНИЕ №3
--Задание 3. Для каждого пользователя посчитайте нарастающим итогом сумму всех его платежей, 
--сортировка должна быть по дате платежа.

select  customer_id, payment_id, payment_date,  amount, 
sum (amount) over (partition by customer_id order by payment_date)
from payment p 



--ЗАДАНИЕ №4
--С помощью оконной функции для каждого покупателя выведите данные о его последней оплате аренды.

select t.customer_id, t.payment_date
from 
(
select p.customer_id, p.payment_date, p.amount, row_number () over (partition by customer_id order by payment_date desc)
from payment p 
) t 
where row_number =1




--======== ДОПОЛНИТЕЛЬНАЯ ЧАСТЬ ==============

--ЗАДАНИЕ №1
--С помощью оконной функции выведите для каждого сотрудника магазина стоимость продажи 
--из предыдущей строки со значением по умолчанию 0.0 с сортировкой по дате.

select staff_id, payment_date, amount, lag(amount, 1, 0.0) over (partition by staff_id order by payment_date)
from payment p 




--ЗАДАНИЕ №2
--С помощью оконной функции выведите для каждого сотрудника сумму продаж за август 2005 года 
--с нарастающим итогом по каждому сотруднику и по каждой дате продажи (без учёта времени) 
--с сортировкой по дате.

with cte1 as(
select staff_id as id, (date_trunc('day', payment_date))::date as d, sum(amount) as s
from payment 
group by staff_id, (date_trunc('day', payment_date))::date
)
select *, sum(s) over (partition by id order by d)
from cte1
where d::date between '2005/06/01' and '2005/06/30'


--ЗАДАНИЕ №3
--Для каждой страны определите и выведите одним SQL-запросом покупателей, которые попадают под условия:
-- 1. покупатель, арендовавший наибольшее количество фильмов
-- 2. покупатель, арендовавший фильмов на самую большую сумму
-- 3. покупатель, который последним арендовал фильм

with cte as(
select 
c3.country,
concat(c.first_name, ' ', c.last_name) fl ,
row_number () over (partition by c3.country_id order by count(p.payment_id)desc) qrent,
row_number () over (partition by c3.country_id order by sum(p.amount)desc) samount,
row_number () over (partition by c3.country_id order by max(payment_date)desc) ldate
from payment p 
	join customer c using (customer_id)
	join address a using (address_id)
	join city c2 using (city_id)
	join country c3 using (country_id)
	group by c.customer_id, c3.country_id 
)
select cte1.country "Страна", cte1.fl "Больше всего фильмов", cte2.fl "Больше всего по сумме", cte3.fl "Самая последняя аренда"
from cte cte1
join cte cte2 on cte1.country = cte2.country
join cte cte3 on cte1.country = cte3.country
where cte1.qrent = 1
and cte2.samount = 1
and cte3.ldate = 1




