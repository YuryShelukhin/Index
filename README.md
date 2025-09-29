# Домашнее задание к занятию «SQL. Часть 1» Шелухин Юрий

### Задание 1.

Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите в результат следующую информацию: 
- фамилия и имя сотрудника из этого магазина;
- город нахождения магазина;
- количество пользователей, закреплённых в этом магазине.
 
---

#### Решение 1.

1.1. Запустим MYSQL в контейнере Docker-compose.

`docker-compose up -d`

1.2. Выполним запрос по условию задания.

`SELECT 
    CONCAT(s.last_name, ' ', s.first_name) AS "Фамилия и Имя сотрудника",
    c.city AS "Город",
    COUNT(cu.customer_id) AS "Количество пользователей"
FROM store st
INNER JOIN staff s ON st.manager_staff_id = s.staff_id
INNER JOIN address a ON a.address_id = st.address_id
INNER JOIN city c ON c.city_id = a.city_id
INNER JOIN customer cu ON cu.store_id = st.store_id
GROUP BY 
    s.staff_id, 
    s.last_name, 
    s.first_name, 
    c.city,
    st.store_id
HAVING COUNT(cu.customer_id) > 300;` 

<img src = "img/1-1.png" width = 60%>

---
 

### Задание 2.

Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов..

---

#### Решение 2.

Выполним запрос для по условию задания.

`SELECT COUNT(*) AS "Количество фильмов"
FROM film
WHERE length > (SELECT AVG(length) FROM film);`   

<img src = "img/2-1.png" width = 60%>

---


### Задание 3.

Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

---

#### Решение 3.

Выполним запрос для по условию задания.

`SELECT 
    DATE_FORMAT(payment_date, '%m-%Y') AS payment_month,
    SUM(amount) AS total_payment_amount,
    COUNT(rental_id) AS rental_count
FROM 
    payment
GROUP BY 
    payment_month
ORDER BY 
    total_payment_amount DESC
LIMIT 1;`

<img src = "img/3-1.png" width = 60%>

---


### Задание 4*.

Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 8000, то значение в колонке будет «Да», иначе должно быть значение «Нет»
  
---

#### Решение 4.

Выполним запрос для по условию задания.

`SELECT 
    s.staff_id AS "ID продавца",
    CONCAT(first_name, ' ', last_name) AS "Имя продавца",
    COUNT(payment_id) AS "Количество продаж",
    CASE 
        WHEN COUNT(payment_id) > 8000 THEN 'Да'
        ELSE 'Нет'
    END AS "Премия"
FROM 
    staff s
LEFT JOIN 
    payment p ON s.staff_id = p.staff_id
GROUP BY 
    s.staff_id, s.first_name, s.last_name
ORDER BY 
    "Количество продаж" DESC;`

<img src = "img/4-1.png" width = 60%>

---


### Задание 5*.

Найдите фильмы, которые ни разу не брали в аренду.

#### Решение.

Выполним запрос для по условию задания.

`SELECT 
    f.film_id,
    f.title AS "Название",
    f.description AS "Описание"
FROM 
    film f
LEFT JOIN 
    inventory i ON f.film_id = i.film_id
LEFT JOIN 
    rental r ON i.inventory_id = r.inventory_id
WHERE 
    r.rental_id IS NULL;`

<img src = "img/5-1.png" width = 60%>

---



