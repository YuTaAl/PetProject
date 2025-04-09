CREATE TABLE Colors 
(
    ID BIGSERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL
);

CREATE TABLE SouvenirsCategories 
(
    ID BIGINT PRIMARY KEY,
    IdParent BIGINT,
    Name VARCHAR(100) NOT NULL
);

CREATE TABLE SouvenirMaterials 
(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL
);

CREATE TABLE ApplicationMetods 
(
    ID SERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL
);

CREATE TABLE Souvenirs 
(
    ID BIGSERIAL PRIMARY KEY,
    URL VARCHAR(100) NOT NULL,
    ShortName VARCHAR(150) NOT NULL,
    Name VARCHAR(200) NOT NULL,
    Description VARCHAR(2500) NOT NULL,
    Rating SMALLINT NOT NULL,
    IdCategory BIGINT NOT NULL REFERENCES SouvenirsCategories(ID),
    IdColor BIGINT NOT NULL REFERENCES Colors(ID),
    Size VARCHAR(150) NOT NULL,
    IdMaterial INT NOT NULL REFERENCES SouvenirMaterials(ID),
    Weight DECIMAL(10,3),
    QTypics VARCHAR(10),
    PicsSize VARCHAR(20),
    IdApplicMetod INT NOT NULL REFERENCES ApplicationMetods(ID),
    AllCategories VARCHAR(150) NOT NULL,
    DealerPrice DECIMAL(10,2) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Comments VARCHAR(1000)
);

CREATE TABLE ProcurementStatuses (
    ID BIGSERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL
);

CREATE TABLE Providers (
    ID BIGSERIAL PRIMARY KEY,
    Name VARCHAR(200) NOT NULL,
    Email VARCHAR(200) NOT NULL,
    ContactPerson VARCHAR(200) NOT NULL,
    Comments VARCHAR(1000)
);

CREATE TABLE SouvenirProcurements (
    ID BIGSERIAL PRIMARY KEY,
    IdProvider BIGINT NOT NULL REFERENCES Providers(ID),
    Data DATE NOT NULL,
    IdStatus BIGINT NOT NULL REFERENCES ProcurementStatuses(ID)
);

CREATE TABLE ProcurementSouvenirs (
    ID BIGSERIAL PRIMARY KEY,
    IdSouvenir BIGINT NOT NULL REFERENCES Souvenirs(ID),
    IdProcurement BIGINT NOT NULL REFERENCES SouvenirProcurements(ID),
    Amount INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);

CREATE TABLE SouvenirStores (
    ID BIGSERIAL PRIMARY KEY,
    IdSouvenir BIGINT NOT NULL REFERENCES Souvenirs(ID),
    IdProcurement BIGINT NOT NULL REFERENCES SouvenirProcurements(ID),
    Amount INT NOT NULL,
    Comments VARCHAR(1000)
);







