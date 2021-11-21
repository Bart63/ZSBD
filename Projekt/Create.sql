USE master;
GO
IF EXISTS(SELECT 1 FROM master.dbo.sysdatabases WHERE NAME = 'restauracja') DROP DATABASE restauracja
GO
CREATE DATABASE restauracja
GO
USE restauracja
GO

CREATE TABLE potrawy(
	id_potrawy smallint IDENTITY(1,1) PRIMARY KEY,
	typ nvarchar NOT NULL,
	nazwa nvarchar NOT NULL,
	cena smallmoney NOT NULL,
	gramatura smallint NOT NULL,
	czy_dostepny bit NOT NULL DEFAULT 1,
	CONSTRAINT CHK_cena_potrawy CHECK (cena > 0),
	CONSTRAINT CHK_gramatura_potrawy CHECK (gramatura > 0)
);
GO

CREATE TABLE stoliki(
	id_stolika tinyint IDENTITY(1,1) PRIMARY KEY,
	liczba_miejsc tinyint NOT NULL,
	lokalizacja nvarchar NOT NULL,
	czy_wolne bit NOT NULL DEFAULT 1,
	CONSTRAINT CHK_liczba_os_stoliki CHECK (liczba_miejsc > 0)
);
GO

CREATE TABLE rezerwacje(
	id_rezerwacji int IDENTITY(1,1) PRIMARY KEY,
	id_stolika tinyint NOT NULL,
	nazwisko nvarchar NOT NULL,
	data_rozpoczecia datetime NOT NULL DEFAULT GETDATE(),
	data_zakonczenia datetime,
	liczba_osob smallint NOT NULL,
	CONSTRAINT FK_rezerwacje_stoliki FOREIGN KEY(id_stolika) REFERENCES stoliki (id_stolika),
	CONSTRAINT CHK_data_zakonczenia_rezerwacje CHECK (data_zakonczenia > data_rozpoczecia),
	CONSTRAINT CHK_liczba_os_rezerwacje CHECK (liczba_osob > 0)
);
GO

CREATE TABLE stanowiska(
	id_stanowiska tinyint IDENTITY(1,1) PRIMARY KEY,
	nazwa nvarchar NOT NULL,
	placa_min smallmoney NOT NULL,
	placa_max smallmoney NOT NULL,
	zatrudnionych_min tinyint NOT NULL,
	zatrudnionych_max tinyint NOT NULL,
	CONSTRAINT CHK_placa_min_stanowiska CHECK (placa_min >= 0),
	CONSTRAINT CHK_placa_max_stanowiska CHECK (placa_max >= placa_min),
	CONSTRAINT CHK_zatrudnionych_min_stanowiska CHECK (zatrudnionych_min >= 0),
	CONSTRAINT CHK_zatrudnionych_max_stanowiska CHECK (zatrudnionych_max >= zatrudnionych_min)
 );
 GO

 CREATE TABLE imprezy(
	id_imprezy smallint IDENTITY(1,1) PRIMARY KEY,
	nazwa nvarchar NOT NULL,
	data_rozpoczecia datetime NOT NULL DEFAULT GETDATE(),
	data_zakonczenia datetime,
	liczba_osob smallint NOT NULL,
	komentarz nvarchar NOT NULL,
	CONSTRAINT CHK_data_zakonczenia_imprezy CHECK (data_zakonczenia > data_rozpoczecia),
	CONSTRAINT CHK_liczba_os_imprezy CHECK (liczba_osob > 0)
 );
 GO


CREATE TABLE pracownicy(
	id_pracownika int IDENTITY(1,1) PRIMARY KEY,
	imie nvarchar NOT NULL,
	nazwisko nvarchar NOT NULL,
	plec char(1) NOT NULL,
	id_stanowiska tinyint NOT NULL,
	data_zatrudnienia datetime NOT NULL DEFAULT GETDATE(),
	data_zwolnienia datetime,
	placa smallmoney NOT NULL,
	premia smallmoney,
	CONSTRAINT FK_pracownicy_stanowiska FOREIGN KEY(id_stanowiska) REFERENCES stanowiska (id_stanowiska),
	CONSTRAINT CHK_plec_pracownicy CHECK (plec IN ('M', 'F')),
	CONSTRAINT CHK_data_zwolnienia_pracownicy CHECK (data_zwolnienia > data_zatrudnienia),
	CONSTRAINT CHK_placa_pracownicy CHECK (placa >= 0)
);
GO

 CREATE TABLE zmiany(
	id_zmiany int IDENTITY(1,1) PRIMARY KEY,
	id_pracownika int NOT NULL,
	data_rozpoczecia datetime NOT NULL DEFAULT GETDATE(),
	data_zakonczenia datetime,
	obecnosc nvarchar,
	CONSTRAINT FK_zmiany_pracownicy FOREIGN KEY(id_pracownika) REFERENCES pracownicy (id_pracownika),
	CONSTRAINT CHK_data_zakonczenia_zmiany CHECK (data_zakonczenia > data_rozpoczecia),
	CONSTRAINT CHK_obecnosc_zmiany CHECK (obecnosc IN 
		('nieobecność usprawiedliwiona', 'urlop na życzenie', 'urlop', 'nadgodziny', 'chorobowe', 'nieobecny', 'obecny')
	)
);
GO

 CREATE TABLE zamowienia(
	id_zmowienia bigint IDENTITY(1,1) PRIMARY KEY,
	id_stolika tinyint NOT NULL,
	id_potrawy smallint NOT NULL,
	liczba_porcji tinyint NOT NULL DEFAULT 1,
	data_zlozenia datetime NOT NULL DEFAULT GETDATE(),
	data_realizacji datetime,
	komentarz nvarchar,
	id_kelnera int NOT NULL,
	id_kucharza int,
	CONSTRAINT FK_zamowienia_stoliki FOREIGN KEY(id_stolika) REFERENCES stoliki (id_stolika),
	CONSTRAINT FK_zamowienia_potrawy FOREIGN KEY(id_potrawy) REFERENCES potrawy (id_potrawy),
	CONSTRAINT FK_zamowienia_kelnera FOREIGN KEY(id_kelnera) REFERENCES pracownicy (id_pracownika),
	CONSTRAINT FK_zamowienia_kucharza FOREIGN KEY(id_kucharza) REFERENCES pracownicy (id_pracownika),
	CONSTRAINT CHK_liczba_porcji CHECK (liczba_porcji > 0),
	CONSTRAINT CHK_data_realizacji_zamowienia CHECK (data_realizacji > data_zlozenia)
 );
 GO