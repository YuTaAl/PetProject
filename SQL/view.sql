--Создаем 2 представления базы данных на основе простой фильтрации по полу лиц. 

CREATE VIEW v_persons_male AS
SELECT * FROM person
WHERE gender = 'male';

CREATE VIEW v_persons_female AS
SELECT * FROM person
WHERE gender = 'female';


--Пишем запрос SQL, чтобы получить женские и мужские имена в одном списке.

SELECT name FROM v_persons_male
UNION
SELECT name FROM v_persons_female
ORDER BY 1;


--Создаём представление базы данных, которое должно "хранить" сгенерированные даты с 1 по 31 января 2022 года. 

CREATE VIEW v_generated_dates AS
SELECT gd::date generated_date 
FROM generate_series('2022-01-01', '2022-01-31', '1 day'::interval) gd
ORDER BY 1;


--Пишем SQL-выражение, которое возвращает пропущенные дни для посещений людей в январе 2022 года. 

SELECT generated_date missing_date FROM v_generated_dates 
EXCEPT 
SELECT visit_date FROM person_visits 
ORDER BY 1;


--Пишем SQL-выражение, удовлетворяющее формуле (R - S)∪(S - R). Где R — person_visits таблица с фильтром на 2 января 2022 г., 
--S — с другим фильтром на 6 января 2022 г. 

CREATE VIEW v_symmetric_union AS
(SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-02'
EXCEPT
SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-06')
UNION
(SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-06'
EXCEPT
SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-02')
ORDER BY 1;


--Создаём представление базы данных, которое возвращает заказы человека (с примененной скидкой 10%). 

CREATE VIEW v_price_with_discount AS
SELECT p.name, m.pizza_name, m.price, 
    ROUND(m.price * 0.9) AS discount_price
FROM person p JOIN person_order po ON p.id = po.person_id
JOIN menu m ON m.id = po.menu_id
ORDER BY 1, 2;


--Создаём материализованное представление mv_dmitriy_visits_and_eats на основе оператора SQL, который находит название пиццерии, 
--которую Дмитрий посетил 8 января 2022 года и где он мог съесть пиццу менее чем за 800 рублей.

CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS
SELECT piz.name
FROM person p JOIN person_visits pv ON p.id = pv.person_id
JOIN pizzeria piz ON pv.pizzeria_id = piz.id
JOIN menu m ON piz.id = m.pizzeria_id
WHERE p.name = 'Dmitriy' AND pv.visit_date = '2022-01-08' 
AND m.price < 800;


--Создаём еще одно посещение Дмитрия и обновляем состояние данных для mv_dmitriy_visits_and_eats.

INSERT INTO person_visits
VALUES ((SELECT MAX(id)+1 FROM person_visits),
    (SELECT id FROM person WHERE name = 'Dmitriy'),
    (SELECT m.pizzeria_id 
    FROM menu m
    FULL JOIN mv_dmitriy_visits_and_eats ve ON m.pizza_name = ve.name
    WHERE price < 800 AND ve.name IS NULL 
    LIMIT 1),
    ('2022-01-08')
);

REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;


--Удаляем виртуальные таблицы и материализованное представление. 

DROP VIEW v_generated_dates;
DROP VIEW v_persons_female;
DROP VIEW v_persons_male;
DROP VIEW v_price_with_discount;
DROP VIEW v_symmetric_union;
DROP MATERIALIZED VIEW mv_dmitriy_visits_and_eats;
