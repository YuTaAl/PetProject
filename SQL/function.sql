--Создаём таблицу person_audit.
--Обрабатываем INSERT трафик DML и создаём копию новой строки в таблице person_audit.

create table person_audit
( 
    created timestamp with time zone default current_timestamp not null,
    type_event char(1) default 'I' not null,
    row_id bigint not null,
    name varchar,
    age integer,
    gender varchar,
    address varchar
    constraint ch_type_event check (type_event in ('I', 'D', 'U') )
);

create or replace function fnc_trg_person_insert_audit()
returns trigger as $$
begin
    insert into person_audit
    values (current_timestamp, 'I', new.id , new.name , new.age , new.gender , new.address);
    return new;
end;
$$
language plpgsql;

create trigger trg_person_insert_audit
after insert on person
for each row
execute function fnc_trg_person_insert_audit();

insert into person values (10,'Damir', 22, 'male', 'Irkutsk');

select * from person_audit;


--Обрабатываем UPDATE трафик в таблице person. Сохраняем СТАРЫЕ состояния всех значений атрибутов.

create or replace function fnc_trg_person_update_audit()
returns trigger as $$
begin
    insert into person_audit
    values (current_timestamp, 'U', old.id , old.name , old.age , old.gender , old.address);
    return new;
end;
$$
language plpgsql;

create trigger trg_person_update_audit
after update on person
for each row
execute function fnc_trg_person_update_audit();

UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;

select * from person_audit;


--Обрабатываем DELETE и делаем копию СТАРЫХ состояний для всех значений атрибута.

create or replace function fnc_trg_person_delete_audit()
returns trigger as $$
begin
    insert into person_audit
    values (current_timestamp, 'D', old.id , old.name , old.age , old.gender , old.address);
    return new;
end;
$$
language plpgsql;

create trigger trg_person_delete_audit
after delete on person
for each row
execute function fnc_trg_person_delete_audit();

DELETE FROM person WHERE id = 10;

select * from person_audit;


--Объединяем функционал трёх предыдущих триггеров и функций в один

drop trigger trg_person_insert_audit on person;
drop trigger trg_person_update_audit on person;
drop trigger trg_person_delete_audit on person;

drop function fnc_trg_person_insert_audit;
drop function fnc_trg_person_update_audit;
drop function fnc_trg_person_delete_audit;

truncate table person_audit;

create or replace function fnc_trg_person_audit()
returns trigger as $$
begin
    if tg_op = 'INSERT' then
        insert into person_audit
        values (current_timestamp, 'I', new.id , new.name , new.age , new.gender , new.address);
        return new;
    elsif tg_op = 'UPDATE' then
        insert into person_audit
        values (current_timestamp, 'U', old.id , old.name , old.age , old.gender , old.address);
        return new;
    elsif tg_op = 'DELETE' then
        insert into person_audit
        values (current_timestamp, 'D', old.id , old.name , old.age , old.gender , old.address);
        return new;
    end if;
end;
$$
language plpgsql;

create trigger trg_person_audit 
after insert or update or delete on person
for each row
execute function fnc_trg_person_audit();

INSERT INTO person(id, name, age, gender, address)  VALUES (10,'Damir', 22, 'male', 'Irkutsk');
UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;
DELETE FROM person WHERE id = 10;

SELECT * FROM person_audit


--Пишем функции, разделяющие людей по полу.

create or replace function fnc_persons_female() 
returns table (id bigint, name varchar, age integer, gender varchar, address varchar) as $$
    select * from person WHERE gender = 'female';
$$
language SQL;

create or replace function fnc_persons_male() 
returns table (id bigint, name varchar, age integer, gender varchar, address varchar) as $$
    select * from person WHERE gender = 'male';
$$
language SQL;

SELECT *
FROM fnc_persons_male();

SELECT *
FROM fnc_persons_female();


--Более общий подход к двум предыдущим функциям 

drop function fnc_persons_female;
drop function fnc_persons_male;

create or replace function fnc_persons(pgender varchar default 'female') 
returns table (id bigint, name varchar, age integer, gender varchar, address varchar) as $$
    select * from person WHERE gender = pgender;
$$
language SQL;

select *
from fnc_persons(pgender := 'male');

select *
from fnc_persons();


--Создаём функцию fnc_person_visits_and_eats_on_date на основе оператора SQL, 
--которая найдет названия пиццерий, которые посетил человек, 
--и где он мог купить пиццу ниже какой-то цены в опредленную дату. (Так же прописываем значения по умолчанию) 

create or replace function fnc_person_visits_and_eats_on_date
    (pperson varchar default 'Dmitriy', 
    pprice numeric default 500,
    pdate date default '2022-01-08') 
returns table (pizza_name varchar) as $$
begin
return query 
    select piz.name
    from person_visits pv 
    join person p on p.id = pv.person_id
    join pizzeria piz on piz.id = pv.pizzeria_id
    join menu m on m.pizzeria_id = piz.id 
    WHERE p.name = pperson and m.price < pprice and pv.visit_date = pdate;
end;
$$
language plpgsql;

select *
from fnc_person_visits_and_eats_on_date(pprice := 800);

select *
from fnc_person_visits_and_eats_on_date(pperson := 'Anna',pprice := 1300,pdate := '2022-01-01');


--Пишем функцию, которая имеет входной параметр, представляющий собой массив чисел, 
--и возвращает минимальное значение.

create or replace function func_minimum(variadic arr numeric[]) 
returns numeric as $$
    select min(x) from unnest(arr) as x;
$$
language SQL;

SELECT func_minimum(VARIADIC arr => ARRAY[10.0, -1.0, 5.0, 4.4]);


--Пишем функцию, которая имеет входной параметр pstop, 
--а выход представляет собой таблицу всех чисел Фибоначчи, меньших pstop.

CREATE OR REPLACE FUNCTION fnc_fibonacci(pstop INTEGER DEFAULT 10)
RETURNS TABLE(fibonacci INTEGER) AS $$
WITH RECURSIVE Fibonacci(n1, n2) AS (
    SELECT 0, 1  
    UNION ALL
    SELECT n2, n1+n2 
    FROM Fibonacci
    WHERE n2 < pstop
)
SELECT n1 FROM Fibonacci; 
$$
LANGUAGE SQL;

select * from fnc_fibonacci(100);
select * from fnc_fibonacci();

