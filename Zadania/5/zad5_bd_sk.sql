-- Autorzy:
-- Bartosz Durys 229869
-- Szymon Klewicki 229911

USE test_pracownicy;

CREATE TABLE dziennik (
tabela VARCHAR(15),
data DATETIME,
l_wierszy INT,
komunikat VARCHAR(300)
)
GO

-- 1.
DECLARE managers cursor for 
	(SELECT nr_akt FROM pracownicy 
	WHERE nr_akt IN (SELECT kierownik FROM pracownicy))
BEGIN
	DECLARE @raise INT=9, @id INT, @iter INT=0
	OPEN managers
	FETCH NEXT FROM managers INTO @id
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE pracownicy
		SET placa += @raise
		WHERE CURRENT OF managers
		SET @iter += 1
		FETCH NEXT FROM managers INTO @id
	END
	CLOSE managers
	DEALLOCATE managers

	INSERT INTO dziennik
	VALUES ('pracownicy', GETDATE(), @iter, 
	'Wprowadzono dodatek funkcyjny w wysokosci ' + CONVERT(VARCHAR, @raise) 
	+ ' dla ' + CONVERT(VARCHAR, @iter) + ' pracownikow')
END
GO

-- 2.
DECLARE @year INT=1989, @employees INT
BEGIN
	SET @employees = (SELECT COUNT(*) FROM pracownicy WHERE DATEPART(year, data_zatr) = @year)
	IF (@employees=0)
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @employees, 
			'Nikogo nie zatrudniono w ' + CONVERT(VARCHAR(4), @year))
	ELSE
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), @employees, 
			'Zatrudniono ' + CONVERT(VARCHAR, @employees) + ' pracowników w roku ' + CONVERT(VARCHAR(4), @year))
END
GO

-- 3.
DECLARE @years INT, @id INT=8902
BEGIN
	SET @years = DATEDIFF(year, (SELECT data_zatr FROM pracownicy WHERE nr_akt=@id), GETDATE())
	IF (@years<15)
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), NULL, 
			'Pracownik ' + CONVERT(VARCHAR, @id) + 'jest zatrudniony krocej niz 15 lat')
	ELSE
		INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), NULL, 
			'Pracownik ' + CONVERT(VARCHAR, @id) + 'jest zatrudniony dluzej niz 15 lat')
END
GO

-- 4.
CREATE PROCEDURE PIERWSZA (@p INT) AS
	PRINT 'Wartosc parametru wynosila: ' + CONVERT(VARCHAR, @p)
GO

BEGIN
	EXEC PIERWSZA 1
END
GO

-- 5.
CREATE PROCEDURE DRUGA
(
	@in VARCHAR(MAX) NULL,
	@out VARCHAR(MAX) OUTPUT,
	@num INT=1
) AS
DECLARE @loc VARCHAR(5)='DRUGA'
SET @out = @loc + @in + CONVERT(VARCHAR, @num)
GO

DECLARE @output VARCHAR(MAX)
EXEC DRUGA 'INPUT ', @output OUTPUT
SELECT @output
GO

-- 6.
CREATE PROCEDURE RAISE
(
	@dep_id INT=0,
	@perc FLOAT=0
) AS
IF (@dep_id=0)
BEGIN
	UPDATE pracownicy SET placa=(1+@perc/100)*placa
	INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), (SELECT COUNT(*) FROM pracownicy), 
		'Podwyzszono place wszystkim pracownikom o ' + CONVERT(VARCHAR, @perc) + ' %')
END
ELSE
BEGIN
	UPDATE pracownicy SET placa=(1+@perc/100)*placa WHERE id_dzialu=@dep_id
	INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), (SELECT COUNT(*) FROM pracownicy WHERE id_dzialu=@dep_id), 
		'Podwyzszono place pracownikom dzialu ' + CONVERT(VARCHAR, @dep_id) + ' o ' + CONVERT(VARCHAR, @perc) + ' %')
END
GO

SELECT id_dzialu, placa FROM pracownicy
EXEC RAISE 40, 10
SELECT id_dzialu, placa FROM pracownicy
SELECT * FROM dziennik
GO

-- 7.
CREATE FUNCTION SHARE (@dep_id INT)
RETURNS FLOAT
AS
BEGIN
	DECLARE @all FLOAT, @dep FLOAT
	SET @all = (SELECT SUM(placa) FROM pracownicy)
	SET @dep = (SELECT SUM(placa) FROM pracownicy WHERE id_dzialu=@dep_id)
	RETURN (100*@dep/@all)
END
GO

SELECT DISTINCT id_dzialu, dbo.SHARE(id_dzialu) FROM pracownicy
GO

-- 8.
CREATE TRIGGER do_archiwum
ON pracownicy
FOR DELETE AS
BEGIN
	INSERT INTO prac_archiw
	SELECT nr_akt, nazwisko, stanowisko, kierownik, data_zatr, data_zwol, placa, dod_funkcyjny, prowizja, id_dzialu 
		FROM deleted
	INSERT INTO dziennik VALUES ('pracownicy', GETDATE(), 1, 
		'Zwolniono pracownika numer: ' + CONVERT(VARCHAR, (SELECT nr_akt FROM deleted)))
END
GO

DELETE FROM pracownicy WHERE nr_akt = 9780
SELECT * FROM prac_archiw WHERE nr_akt = 9780
SELECT * FROM dziennik