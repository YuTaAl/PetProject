--Аномалия потерянного обновления 
--Lost Update Anomaly

--session_1
begin transaction isolation level repeatable read;

--session_2
begin transaction isolation level repeatable read;

--session_1
select * from pizzeria where name = 'Pizza Hut';

--session_2
select * from pizzeria where name = 'Pizza Hut';

--session_1
update pizzeria set rating = 4 where name = 'Pizza Hut';

--session_2
update pizzeria set rating = 3.6 where name = 'Pizza Hut';
--не выполняется до коммита первого пользователя
--после выдаёт ошибку из-за параллельного изменения

--session_1
commit; 

--session_2
commit;
--не коммитит из-за ошибки, транзакция не выполнена

--session_1
select * from pizzeria where name = 'Pizza Hut';

--session_2
select * from pizzeria where name = 'Pizza Hut';
--результаты остаются по первому (единственному выполненному коммиту)
