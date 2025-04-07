--Аномалия фантомных показаний
--Phantom Reads Anomaly

--session_1
begin transaction isolation level repeatable read;

--session_2
begin transaction isolation level repeatable read;

--session_1
select sum(rating) from pizzeria;

--session_2
insert into pizzeria values(11, 'Kazan Pizza 2', 4);
commit;

--session_1
select sum(rating) from pizzeria;
--значение не изменилось: 
--внутри транзакции запросы видят таблицу на момент начала транзакции
commit;
select sum(rating) from pizzeria;

--session_2
select sum(rating) from pizzeria;

