CREATE TABLE Data
(
    ID BIGSERIAL PRIMARY KEY,
    URL VARCHAR(100) NOT NULL,
    ShortName VARCHAR(150) NOT NULL,
    Name VARCHAR(200) NOT NULL,
    Description VARCHAR(2500) NOT NULL,
    Rating SMALLINT NOT NULL,
    IdCategory BIGINT NOT NULL,
    Color VARCHAR(200) NOT NULL, --!
    Size VARCHAR(150) NOT NULL,
    Material VARCHAR(200) NOT NULL, --!
    Weight DECIMAL(10,3),
    QTypics VARCHAR(10),
    PicsSize VARCHAR(20),
    ApplicMetod VARCHAR(200) NOT NULL, --!
    AllCategories VARCHAR(150) NOT NULL,
    DealerPrice DECIMAL(10,2) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Comments VARCHAR(1000)
);

--импортируем данные в таблицы Data и SouvenirsCategories 
--из data.csv и categories.txt соответственно с помощью pgAdmin

INSERT INTO Colors
SELECT 
    ROW_NUMBER() OVER (ORDER BY color) AS id,
    color AS name
FROM (SELECT DISTINCT color FROM Data) AS unique_color;

INSERT INTO SouvenirMaterials 
SELECT 
    ROW_NUMBER() OVER (ORDER BY Material) AS id,
    Material AS name
FROM (SELECT DISTINCT Material FROM Data) AS unique_material;

INSERT INTO ApplicationMetods
SELECT 
    ROW_NUMBER() OVER (ORDER BY ApplicMetod) AS id,
    ApplicMetod AS name
FROM (SELECT DISTINCT ApplicMetod FROM Data) AS unique_ApplicMetod;

INSERT INTO Souvenirs
SELECT d.id, URL, ShortName, d.Name, Description, Rating, IdCategory, 
    c.id AS IdColor, Size, m.id AS IdMaterial, Weight, QTypics, PicsSize, 
    am.id AS IdApplicMetod, AllCategories, DealerPrice, Price, Comments 
FROM data d  
join Colors c on d.color = c.name 
join SouvenirMaterials m on d.material = m.name 
join ApplicationMetods am on d.ApplicMetod = am.name; 

DROP TABLE data;

--ЗАПОЛНЕНИЕ ОСТАВШИХСЯ ТАБЛИЦ

INSERT INTO Providers 
VALUES
(1, 'Provider_1', 'Provider_1@mail.ru', 'Provider One', 'First provider.'),
(2, 'Provider_2', 'Provider_2@mail.ru', 'Provider Two', 'Second provider.'),
(3, 'Provider_3', 'Provider_3@mail.ru', 'Provider Three', 'Third provider.'),
(4, 'Provider_4', 'Provider_4@mail.ru', 'Provider Four', 'Fourth provider.'),
(5, 'Provider_5', 'Provider_5@mail.ru', 'Provider Five', 'Fifth provider.');

INSERT INTO ProcurementStatuses 
VALUES
(1, 'Planned'),
(2, 'In Process'),
(3, 'Confirmed'),
(4, 'Delivered'),
(5, 'Completed');

INSERT INTO SouvenirProcurements 
VALUES
(1, 1, '2024-06-03', 5),
(2, 5, '2024-07-10', 4),
(3, 3, '2024-08-29', 3),
(4, 2, '2024-09-16', 2),
(5, 4, '2024-10-17', 1);

INSERT INTO SouvenirStores 
VALUES
(1, 8096, 1, 67, 'Position 1.'),
(2, 9097, 4, 34, 'Positin 2.'),
(3, 13098, 3, 58, 'Position 3.'),
(4, 16599, 2, 18, 'Position 4.'),
(5, 17520, 5, 45, 'Position 5.');

INSERT INTO ProcurementSouvenirs 
VALUES
(1, 8096, 1, 130, 70.50),
(2, 9097, 4, 60, 143.00),
(3, 13098, 3, 80, 1325.00),
(4, 16599, 2, 30, 10545.50),
(5, 17520, 5, 50, 2794.75);
