--Аномалия фантомных показаний
--Phantom Reads Anomaly

--session_1
begin transaction isolation level read committed;

--session_2
begin transaction isolation level read committed;

--session_1
select sum(rating) from pizzeria;

--session_2
insert into pizzeria values(10, 'Kazan Pizza', 5);
commit;

--session_1
select sum(rating) from pizzeria;
--значение изменилось: внутри транзакции заппросы видят актуальную таблицу
commit;
select sum(rating) from pizzeria;

--session_2
select sum(rating) from pizzeria;

