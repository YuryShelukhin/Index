SELECT 
    ROUND((SUM(index_length) / SUM(data_length + index_length)) * 100, 2)
    	AS "Процент индексов от всех таблиц",
    CONCAT(ROUND(SUM(data_length) / 1024 / 1024, 2), ' MB') AS "Размер данных",
    CONCAT(ROUND(SUM(index_length) / 1024 / 1024, 2), ' MB') AS "Размер индексов",
    CONCAT(ROUND(SUM(data_length + index_length) / 1024 / 1024, 2), ' MB') AS "Общий размер данных"
FROM information_schema.TABLES
WHERE table_schema = 'sakila';

EXPLAIN ANALYZE
select distinct concat(c.last_name, ' ', c.first_name),
	sum(p.amount) over (partition by c.customer_id, f.title)
from payment p, rental r, customer c, inventory i, film f
where date(p.payment_date) = '2005-07-30'
	and p.payment_date = r.rental_date
	and r.customer_id = c.customer_id
	and i.inventory_id = r.inventory_id;

-> Table scan on <temporary>  (cost=2.5..2.5 rows=0) (actual time=4953..4953 rows=391 loops=1)
    -> Temporary table with deduplication  (cost=0..0 rows=0) (actual time=4953..4953 rows=391 loops=1)
        -> Window aggregate with buffering: sum(payment.amount) OVER (PARTITION BY c.customer_id,f.title )   (actual time=2317..4795 rows=642000 loops=1)
            -> Sort: c.customer_id, f.title  (actual time=2317..2375 rows=642000 loops=1)
                -> Stream results  (cost=22.1e+6 rows=16.3e+6) (actual time=2.35..1466 rows=642000 loops=1)
                    -> Nested loop inner join  (cost=22.1e+6 rows=16.3e+6) (actual time=2.33..1257 rows=642000 loops=1)
                        -> Nested loop inner join  (cost=20.5e+6 rows=16.3e+6) (actual time=2.32..1114 rows=642000 loops=1)
                            -> Nested loop inner join  (cost=18.8e+6 rows=16.3e+6) (actual time=2.3..960 rows=642000 loops=1)
                                -> Inner hash join (no condition)  (cost=1.61e+6 rows=16.1e+6) (actual time=2.26..41.4 rows=635000 loops=1)
                                    -> Filter: (cast(p.payment_date as date) = '2005-07-30')  (cost=1.68 rows=16086) (actual time=0.172..8.96 rows=635 loops=1)
                                        -> Table scan on p  (cost=1.68 rows=16086) (actual time=0.161..5.86 rows=16049 loops=1)
                                    -> Hash
                                        -> Covering index scan on f using idx_title  (cost=112 rows=1000) (actual time=1.88..2 rows=1000 loops=1)
                                -> Covering index lookup on r using rental_date (rental_date=p.payment_date)  (cost=0.969 rows=1.01) (actual time=930e-6..0.00134 rows=1.01 loops=635000)
                            -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=250e-6 rows=1) (actual time=118e-6..134e-6 rows=1 loops=642000)
                        -> Single-row covering index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=250e-6 rows=1) (actual time=90.5e-6..107e-6 rows=1 loops=642000)



CREATE INDEX idx_payment_date ON payment(payment_date);
CREATE INDEX idx_rental_rental_date ON rental(rental_date);
CREATE INDEX idx_rental_customer_id ON rental(customer_id);
CREATE INDEX idx_inventory_id ON inventory(inventory_id);
CREATE INDEX idx_film_id ON film(film_id);

EXPLAIN ANALYZE
SELECT 
    CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
    f.title AS film_title,
    SUM(p.amount) AS total_payment
FROM 
    payment p
INNER JOIN rental r ON p.rental_id = r.rental_id
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
WHERE 
    p.payment_date >= '2005-07-30' AND p.payment_date < '2005-07-31'
GROUP BY 
    c.customer_id, c.last_name, c.first_name, f.film_id, f.title;

-> Table scan on <temporary>  (actual time=10.4..10.5 rows=634 loops=1)
    -> Aggregate using temporary table  (actual time=10.4..10.4 rows=634 loops=1)
        -> Nested loop inner join  (cost=1175 rows=635) (actual time=2.14..7.79 rows=634 loops=1)
            -> Nested loop inner join  (cost=953 rows=635) (actual time=2.14..7.16 rows=634 loops=1)
                -> Nested loop inner join  (cost=731 rows=635) (actual time=2.13..6.53 rows=634 loops=1)
                    -> Nested loop inner join  (cost=508 rows=635) (actual time=2.13..5.93 rows=634 loops=1)
                        -> Filter: (p.rental_id is not null)  (cost=286 rows=635) (actual time=2.04..5.17 rows=634 loops=1)
                            -> Index range scan on p using idx_payment_date over ('2005-07-30 00:00:00' <= payment_date < '2005-07-31 00:00:00'), with index condition: ((p.payment_date >= TIMESTAMP'2005-07-30 00:00:00') and (p.payment_date < TIMESTAMP'2005-07-31 00:00:00'))  (cost=286 rows=635) (actual time=2.03..5.11 rows=635 loops=1)
                        -> Single-row index lookup on r using PRIMARY (rental_id=p.rental_id)  (cost=0.25 rows=1) (actual time=0.00106..0.00107 rows=1 loops=634)
                    -> Single-row index lookup on c using PRIMARY (customer_id=r.customer_id)  (cost=0.25 rows=1) (actual time=832e-6..846e-6 rows=1 loops=634)
                -> Single-row index lookup on i using PRIMARY (inventory_id=r.inventory_id)  (cost=0.25 rows=1) (actual time=869e-6..884e-6 rows=1 loops=634)
            -> Single-row index lookup on f using PRIMARY (film_id=i.film_id)  (cost=0.25 rows=1) (actual time=836e-6..851e-6 rows=1 loops=634)












