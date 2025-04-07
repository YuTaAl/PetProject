--Тупик
--Deadlock

--session_1
begin transaction isolation level read committed;

--session_2
begin transaction isolation level read committed;

--session_1
update pizzeria set rating = 4 where id = 1;

--session_2
update pizzeria set rating = 4 where id = 2;

--session_1
update pizzeria set rating = 5 where id = 2;
--ожидает коммита первого пользователя из-за параллельного изменения

--session_2
update pizzeria set rating = 5 where id = 1;
--выдаёт ошибку из-за взаимоблокировки

--session_1
commit;
--успешный коммит

--session_2
commit;
--транзакция отменена
