--Аномалия потерянного обновления 
--Lost Update Anomaly

--session_1
begin transaction isolation level read committed;

--session_2
begin transaction isolation level read committed;

--session_1
select * from pizzeria where name = 'Pizza Hut';

--session_2
select * from pizzeria where name = 'Pizza Hut';

--session_1
update pizzeria set rating = 4 where name = 'Pizza Hut';

--session_2
update pizzeria set rating = 3.6 where name = 'Pizza Hut';
--не завершается, пока не будет выполнен commit у первого пользователя

--session_1
commit; 

--session_2
commit;

--session_1
select * from pizzeria where name = 'Pizza Hut';

--session_2
select * from pizzeria where name = 'Pizza Hut';
--результаты остаются по последнему коммиту
