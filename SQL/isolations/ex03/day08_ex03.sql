--Аномалия неповторяющихся показаний
--Non-Repeatable Reads

--session_1
begin transaction isolation level read committed;

--session_2
begin transaction isolation level read committed;

--session_1
select * from pizzeria where name = 'Pizza Hut';

--session_2
update pizzeria set rating = 3.6 where name = 'Pizza Hut';
commit;

--session_1
select * from pizzeria where name = 'Pizza Hut';
--значение уже изменилось
commit; 
select * from pizzeria where name = 'Pizza Hut';

--session_2
select * from pizzeria where name = 'Pizza Hut';
--сохранилось изменение
