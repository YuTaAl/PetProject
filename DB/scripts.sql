--1.	Создать запрос на выборку сувениров по материалу

select s.id, URL, ShortName, s.Name, Description, Rating, sc.name as Category, 
    c.name as Color, Size, m.name as Material, Weight, QTypics, PicsSize, 
    am.name as ApplicMetod, AllCategories, DealerPrice, Price, Comments 
from souvenirs s
join souvenirscategories sc on s.idcategory = sc.id 
join colors c on s.idcolor = c.id 
join souvenirmaterials m on s.idmaterial = m.id 
join applicationmetods am on s.idapplicmetod = am.id
where m.name = 'soft-touch пластик';

--2.	Создать запрос на выборку поставок сувениров за промежуток времени

select sp.id, p.name, p.email, p.contactperson, p.comments, sp.data, ps.name
from souvenirprocurements sp 
join providers p on p.id = sp.idprovider
join procurementstatuses ps on ps.id = sp.idstatus
where data between '2024-07-01' and '2024-08-30';

--3.	Создать запрос на выборку сувениров по категориям и отсортировать по популярности от самого непопулярного

select s.id, URL, ShortName, s.Name, Description, Rating, sc.name as Category, 
    c.name as Color, Size, m.name as Material, Weight, QTypics, PicsSize, 
    am.name as ApplicMetod, AllCategories, DealerPrice, Price, Comments 
from souvenirs s
join souvenirscategories sc on s.idcategory = sc.id 
join colors c on s.idcolor = c.id 
join souvenirmaterials m on s.idmaterial = m.id 
join applicationmetods am on s.idapplicmetod = am.id
where sc.name = 'Чехлы для смартфонов'
order by rating;

--4.	Создать запрос на выборку всех поставщиков, поставляющих категорию товара

select p.id, p.name, p.email, p.contactperson, p.comments
from providers p 
join souvenirprocurements sp on p.id = sp.idprovider 
join procurementsouvenirs ps on sp.id = ps.idprocurement
join souvenirs s on s.id = ps.idsouvenir
join souvenirscategories sc on sc.id = s.idcategory
where sc.name = 'Куртки';

--5.	Создать запрос на выборку поставок сувениров за промежуток времени и отсортировать по статусу

select sp.id, p.name, p.email, p.contactperson, 
    p.comments, sp.data, ps.id as status_id, ps.name status_name
from souvenirprocurements sp 
join providers p on p.id = sp.idprovider
join procurementstatuses ps on ps.id = sp.idstatus
where data between '2024-07-01' and '2024-08-30'
order by ps.id;

--6.	Создать объект для вывода (родительских??) категорий, в зависимости от выбранной

create or replace view ParentsCategories as
with recursive ParCat as (
    select id, idparent, name 
    from souvenirscategories 
    where name = 'Наушники'

    union all 
    select sc.id, sc.idparent, sc.name
    from souvenirscategories sc
    join ParCat on ParCat.idparent = sc.id
)
select * from ParCat;

select * from ParentsCategories;

--7.	Создать объект для проверки правильности занесения данных в таблицу SouvenirsCategories

create or replace function fnc_trg_souvenir_categories() 
returns trigger as $$
begin
    if new.id is null or new.idparent is null 
        then raise exception 'id or idparent can''t be NULL';
    elsif exists (select 1 from souvenirscategories sc where sc.id = new.id)
        then raise exception 'The category with id % already exists', new.id;
    elsif not exists (select 1 from souvenirscategories sc where sc.id = new.idparent) 
        then raise exception 'There is no category with id % (new idparent)', new.idparent;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_souvenir_categories
before insert or update on souvenirscategories
for each row
execute function fnc_trg_souvenir_categories();

insert into souvenirscategories values (NULL, '3204', 'abc');
insert into souvenirscategories values ('5000', NULL, 'abc');
insert into souvenirscategories values ('3033', '3204', 'abc');
insert into souvenirscategories values ('5000', '5001', 'abc');

--8.	Создать объект оповещения пользователя при отсутствии поставок товаров, отсутствующих на складе или количество которых меньше чем 50 шт.

create or replace function fnc_trg_souvenir_stores() 
returns trigger as $$
declare 
    count_product INT;
begin
    select coalesce(sum(amount), 0) into count_product 
        from souvenirstores ss where ss.idsouvenir = new.idsouvenir;
    if count_product < 50 then
        raise notice 'There is no delivery of the product %, the current quantity: %',new.idsouvenir , count_product;
    end if;
    return new;
end;
$$ language plpgsql;

create trigger trg_souvenir_stores
after insert or update on souvenirstores
for each row
execute function fnc_trg_souvenir_stores();

insert into souvenirstores
values('7', '16599', 5, 2, 'abc');

select * from souvenirs
