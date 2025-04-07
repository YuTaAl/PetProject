--Аномалия неповторяющихся показаний
--Non-Repeatable Reads

--session_1
begin transaction isolation level serializable;

--session_2
begin transaction isolation level serializable;

--session_1
select * from pizzeria where name = 'Pizza Hut';

--session_2
update pizzeria set rating = 3.0 where name = 'Pizza Hut';
commit;

--session_1
select * from pizzeria where name = 'Pizza Hut';
--значение не поменялось, внутри транзакции используется БД на момент начала транзакции
commit; 
select * from pizzeria where name = 'Pizza Hut';
--вне транзакции используется актуальная БД

--session_2
select * from pizzeria where name = 'Pizza Hut';
--сохранилось изменение
