--Создаём новую реляционную таблицу person_discounts.

create table person_discounts
(id bigint primary key, --Первичный ключ
    person_id bigint,
    pizzeria_id bigint,
    discount numeric,
    constraint fk_person_discounts_person_id foreign key (person_id) references person(id), --Внешний ключ
    constraint fk_person_discounts_pizzeria_id foreign key (pizzeria_id) references pizzeria(id) --Внешний ключ
);


--Пишем оператор DML ( INSERT INTO ... SELECT ...), который вставляет новые записи в person_discounts.

insert into person_discounts(id, person_id, pizzeria_id, discount)
select row_number() over () as id,
    person_id, pizzeria_id,
    case 
        when count(*) = 1 then 10.5
        when count(*) = 2 then 22
        else 30
    end discount
from menu m
join person_order po on m.id = po.menu_id
group by 2, 3;


--Пишем SQL-выражение, которое возвращает заказы с фактической ценой и ценой со скидкой, 
--примененной для каждого человека в соответствующей пиццерии, отсортированные по имени человека и названию пиццы.

select p.name, m.pizza_name, m.price, 
    (m.price*(1 - pd.discount/100)) discount_price, 
    piz.name pizzeria_name
from person_order po
join person p on p.id = po.person_id
join menu m on m.id = po.menu_id
join pizzeria piz on piz.id = m.pizzeria_id
join person_discounts pd on p.id = pd.person_id and piz.id = pd.pizzeria_id
order by 1, 2;


--Создаём уникальный индекс idx_person_discounts_unique с несколькими столбцами, 
--который предотвращает дубликаты пар идентификаторов персоны и пиццерии.
--Используем EXPLAIN ANALYZE для доказательства использования индекса.

create unique index idx_person_discounts_unique 
on person_discounts(person_id, pizzeria_id);

set enable_seqscan = off;

explain analyze 
select pizzeria_id, discount
from person_discounts 
where person_id = 4;


--Добавляем следующие правила ограничений для существующих столбцов таблицы person_discounts:
--Столбец person_id не должен иметь значение NULL;
--Столбец pizzeria_id не должен иметь значение NULL;
--Столбец скидки не должен иметь значение NULL;
--По умолчанию значение столбца скидки должно быть равно 0 процентов;
--Столбец скидки должен содержать значения в диапазоне от 0 до 100 (используйте имя ограничения ch_range_discount).

alter table person_discounts add constraint ch_nn_person_id check (person_id is not null);
alter table person_discounts add constraint ch_nn_pizzeria_id check (pizzeria_id is not null);
alter table person_discounts add constraint ch_nn_discount check (discount is not null);
alter table person_discounts alter column discount set default 0;
alter table person_discounts add constraint ch_range_discount check (discount between 0 and 100);


--Добавляем комментарии для таблицы и столбцов таблицы. 

comment on table person_discounts is 'Table with discounts for persons at some pizzerias';
comment on column person_discounts.id is 'Identification of discounts';
comment on column person_discounts.person_id is 'Who has the discount';
comment on column person_discounts.pizzeria_id is 'Where the person has a discount';
comment on column person_discounts.discount is 'Size of the discount (in %)';


--Создаём последовательность базы данных с именем seq_person_discounts(начинающуюся со значения 1) 
--и устанавливаем значение по умолчанию для атрибута id таблицы person_discounts. 

create sequence seq_person_discounts 
start with 1
increment by 1;

alter table person_discounts
alter column id set default nextval('seq_person_discounts');

select setval('seq_person_discounts', (select max(id) from person_discounts) + 1);

