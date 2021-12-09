-- Bartosz Durys 229869, Szymon Klewicki 229911

-- Wyzwalacze

-- After Insert do imprezy, usuwanie wszystkich rezerwacji w tym okresie
GO
DROP TRIGGER IF EXISTS dbo.ZwolnijRezerwacje
GO
CREATE TRIGGER ZwolnijRezerwacje
ON imprezy
AFTER INSERT
AS
BEGIN
	DECLARE @iter INT=0
	DECLARE kolidujace_rezerwacje CURSOR FOR 
	(SELECT id_rezerwacji FROM rezerwacje
		WHERE data_rozpoczecia <= (SELECT data_zakonczenia FROM inserted)
		AND data_zakonczenia >= (SELECT data_rozpoczecia FROM inserted))
	BEGIN
		DECLARE @id INT
		OPEN kolidujace_rezerwacje
		FETCH NEXT FROM kolidujace_rezerwacje INTO @id
		WHILE @@FETCH_STATUS = 0
		BEGIN
			DELETE FROM rezerwacje
			WHERE CURRENT OF kolidujace_rezerwacje
			SET @iter += 1
			FETCH NEXT FROM kolidujace_rezerwacje INTO @id
		END
		CLOSE kolidujace_rezerwacje
		DEALLOCATE kolidujace_rezerwacje
	END
	PRINT 'Usunięto ' + CAST(@iter AS VARCHAR) + ' rezerwacji.'
END
GO

DECLARE @cur_date datetime = GETDATE()
INSERT INTO imprezy VALUES
	('imieniny', DATEADD(DAY, 1, @cur_date), DATEADD(HOUR, 29, @cur_date), 20, '')

SELECT * FROM rezerwacje

-- After Update do płacy i premii pracownika, czy miescie sie w zakresie min-max
GO
DROP TRIGGER IF EXISTS dbo.SprawdzPlace
GO
CREATE TRIGGER SprawdzPlace
ON pracownicy
AFTER UPDATE
AS
BEGIN
	DECLARE @suma smallmoney
	SET @suma = (SELECT placa+premia FROM inserted)
	DECLARE @id_stanowiska tinyint
	SET @id_stanowiska = (SELECT id_stanowiska FROM inserted)
	DECLARE @min smallmoney
	DECLARE @max smallmoney
	SET @min = (SELECT placa_min FROM stanowiska 
		WHERE id_stanowiska=@id_stanowiska
	)
	SET @max = (SELECT placa_max FROM stanowiska
		WHERE id_stanowiska=@id_stanowiska
	)
	IF @suma < @min
	BEGIN
		PRINT 'Suma placy i premii jest za mala'
		PRINT 'Automatycznie zmieniam'
		UPDATE pracownicy SET premia = 0, placa = @min WHERE id_pracownika = (
			SELECT id_pracownika FROM inserted
		)
		RETURN
	END
	IF @suma > @max
	BEGIN
		PRINT 'Suma placy i premii jest za duża'
		PRINT 'Automatycznie zmieniam'
		UPDATE pracownicy SET premia = 0, placa = @max WHERE id_pracownika = (
			SELECT id_pracownika FROM inserted
		)
		RETURN
	END
	PRINT 'Suma placy i premii mieszcza sie w zakresie'
END
GO

-- W zakresie
UPDATE pracownicy SET placa = 2600, premia = 100 WHERE id_pracownika=1

--Poza zakresem
UPDATE pracownicy SET premia = 99999 WHERE id_pracownika=1
UPDATE pracownicy SET placa = 0 WHERE id_pracownika=1

SELECT * FROM pracownicy
SELECT * FROM stanowiska


-- Instead of Delete pracownik jeżeli nie mieścimy się w minimum liczby pracowników 
GO
DROP TRIGGER IF EXISTS dbo.ZwolnijPracownika
GO
CREATE TRIGGER ZwolnijPracownika
ON pracownicy
INSTEAD OF DELETE 
AS
BEGIN
	DECLARE @id_stanowiska tinyint
	SET @id_stanowiska = (SELECT id_stanowiska FROM deleted)
	DECLARE @ile_na_stanowisku tinyint
	SET @ile_na_stanowisku = (
		SELECT COUNT(*) FROM pracownicy
		WHERE id_stanowiska = @id_stanowiska
		AND data_zwolnienia IS NULL
	)
	DECLARE @ile_minimum tinyint
	SET @ile_minimum = (
		SELECT zatrudnionych_min FROM stanowiska
		WHERE id_stanowiska = @id_stanowiska
	)
	IF @ile_na_stanowisku > @ile_minimum
	BEGIN
		UPDATE pracownicy SET data_zwolnienia = GETDATE() 
		WHERE id_pracownika = (SELECT id_pracownika FROM deleted)
		PRINT 'Zwolniono pracownika'
		RETURN
	END
	PRINT 'Osiągnięto już minimalną liczbę pracowników na tym stanowisku!'
END
GO

-- Nie zwolni
DELETE FROM pracownicy WHERE id_pracownika=7
-- Zwolni
DELETE FROM pracownicy WHERE id_pracownika=1

SELECT * FROM pracownicy
SELECT * FROM stanowiska