--Создаём простой индекс BTree для каждого внешнего ключа в нашей базе данных. 

CREATE INDEX idx_menu_pizzeria_id ON menu (pizzeria_id);
CREATE INDEX idx_person_order_menu_id ON person_order (menu_id);
CREATE INDEX idx_person_order_person_id ON person_order (person_id);
CREATE INDEX idx_person_visits_pizzeria_id ON person_visits (pizzeria_id);
CREATE INDEX idx_person_visits_person_id ON person_visits (person_id);


--Пишем SQL-выражение, которое возвращает пиццы и соответствующие названия пиццерий. 
--Пример доказательства работы индекса — вывод команды EXPLAIN ANALYZE. 

SET enable_seqscan = OFF;

EXPLAIN ANALYZE
SELECT m.pizza_name, p.name pizzeria_name
FROM menu m JOIN pizzeria p ON m.pizzeria_id = p.id;


--Создаём функциональный индекс B-Tree. Индекс должен содержать имена людей в верхнем регистре.
--Пример доказательства работы индекса — вывод команды EXPLAIN ANALYZE. 

CREATE INDEX idx_person_name ON person (UPPER(name));

SET enable_seqscan = OFF;

EXPLAIN ANALYZE 
SELECT * FROM person WHERE UPPER(name) = 'DENIS';


--Создаём многостолбцовый индекс B-Tree, названный idx_person_order_multi.
--Пример доказательства работы индекса — вывод команды EXPLAIN ANALYZE. 

CREATE INDEX idx_person_order_multi 
ON person_order (person_id, menu_id, order_date);

SET enable_seqscan = OFF;

EXPLAIN ANALYZE
SELECT person_id, menu_id, order_date FROM person_order
WHERE person_id = 8 AND menu_id = 19;


--Создаём уникальный индекс BTree с именем idx_menu_unique в menu таблице для pizzeria_id и pizza_name столбцов.
--Пример доказательства работы индекса — вывод команды EXPLAIN ANALYZE. 

CREATE UNIQUE INDEX idx_menu_unique ON menu (pizzeria_id, pizza_name);

SET enable_seqscan = OFF;

EXPLAIN ANALYZE 
SELECT * FROM menu WHERE pizzeria_id = 5;


--Создаём частично уникальный индекс BTree с именем idx_person_order_order_date 
--в person_order таблице для атрибутов person_id и menu_id с частичной уникальностью для order_date столбца для даты «2022-01-01».

CREATE UNIQUE INDEX idx_person_order_order_date 
ON person_order (person_id, menu_id)
WHERE order_date = '2022-01-01';

SET enable_seqscan = OFF;

EXPLAIN ANALYZE 
SELECT person_id FROM person_order
WHERE order_date = '2022-01-01';


--Создаём новый индекс BTree с именем idx_1, который должен улучшить метрику "Время выполнения". 
--Пример доказательства работы индекса — вывод команды EXPLAIN ANALYZE. 

CREATE INDEX idx_1 ON pizzeria (rating);

SET enable_seqscan = OFF;

EXPLAIN ANALYZE 
SELECT
    m.pizza_name AS pizza_name,
    max(rating) OVER (PARTITION BY rating ORDER BY rating 
    ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1, 2;



