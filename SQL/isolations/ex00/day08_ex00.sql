--второй человек не видит изменения, пока не завершится сессия первого.

--session_1
begin;
update pizzeria set rating = 5 where name = 'Pizza Hut';
select * from pizzeria where name = 'Pizza Hut';

--session_2
select * from pizzeria where name = 'Pizza Hut';

--session_1
commit; 

--session_2
select * from pizzeria where name = 'Pizza Hut';
