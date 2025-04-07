--Создаем оператор select, который возвращает одно вычисляемое поле person_information в одной строке, как описано в следующем примере:
--Anna (age:16,gender:'female',address:'Moscow')

SELECT name || ' (age:' || age || ',gender:''' 
    || gender || ''',address:''' || address || ''')' 
    AS person_information
FROM person
ORDER BY person_information;


--Создаем SQL-выражение, которое возвращает идентификаторы человека, имя человека и интервал возраста человека.

SELECT id, name,
CASE 
    WHEN age BETWEEN 10 AND 20 THEN 'interval #1'
    WHEN age BETWEEN 21 AND 23 THEN 'interval #2'
    ELSE 'interval #3'  
END AS interval_info
FROM person
ORDER BY interval_info;


--Пишем оператор SQL, который возвращает разницу значений столбца person_id, сохраняя дубликаты, между таблицами person_order и person_visits,
--для order_date и visit_date на 7 января 2022 г.

SELECT person_id FROM person_order
WHERE order_date = '2022-01-07'
EXCEPT ALL
SELECT person_id FROM person_visits
WHERE visit_date = '2022-01-07';


--Пишем два оператора SQL, которые возвращают список пиццерий, которые не посещались людьми.

SELECT name FROM pizzeria
WHERE id NOT IN (SELECT pizzeria_id FROM person_visits);

SELECT name FROM pizzeria p 
WHERE NOT EXISTS (SELECT * FROM person_visits pv
                WHERE p.id = pv.pizzeria_id);


--Пишем SQL-выражение, которое вернет полный список имен людей, которые посетили (или не посетили) пиццерии в период 
--с 1 по 3 января 2022 года с одной стороны, 
--и полный список названий пиццерий, которые были посещены (или не посетили) с другой стороны. 

SELECT COALESCE(per.name, '-') AS person_name, pv.visit_date, 
COALESCE(piz.name, '-') AS pizzeria_name
FROM (SELECT * FROM person_visits 
WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') pv
FULL JOIN person per ON pv.person_id = per.id
FULL JOIN pizzeria piz ON piz.id = pv.pizzeria_id
ORDER BY 1, 2, 3;


--Находим имена всех женщин, которые заказали пиццу пепперони и сыр (в любое время и в любых пиццериях). 

SELECT p.name
FROM person p JOIN person_order po ON p.id = po.person_id
JOIN menu m ON m.id = po.menu_id
WHERE p.gender = 'female' AND m.pizza_name = 'pepperoni pizza'
INTERSECT
SELECT p.name
FROM person p JOIN person_order po ON p.id = po.person_id
JOIN menu m ON m.id = po.menu_id
WHERE p.gender = 'female' AND m.pizza_name = 'cheese pizza'
ORDER BY 1;


--Изменяем цену "греческой пиццы" на -10% от текущего значения.

UPDATE menu
SET price = price * 0.9
WHERE pizza_name = 'greek pizza';


--Регистрируем новые заказы всех лиц на "греческую пиццу" 25 февраля 2022 года.

INSERT INTO person_order
SELECT (SELECT MAX(id) FROM person_order)+gid, 
p.id,
(SELECT id FROM menu WHERE pizza_name = 'greek pizza') AS menu,
'2022-02-25' AS date
FROM person p JOIN generate_series(1, (SELECT COUNT(*) FROM person)) gid ON gid = p.id;


--Удаляем все новые заказы из предыдущего запроса на основе даты заказа. 
--Затем удаляем «греческую пиццу» из меню.

DELETE FROM person_order
WHERE order_date = '2022-02-25';

DELETE FROM menu
WHERE pizza_name = 'greek pizza';
