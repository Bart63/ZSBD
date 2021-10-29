-- Autorzy:
-- Bartosz Durys 229869
-- Szymon Klewicki 229911

-- #1
PRINT 'Czesc, to ja'

-- #2 
DECLARE @i INT
SET @i = 2
PRINT 'ZMIENNA = ' + CAST(@i AS VARCHAR)

-- #3
DECLARE @i2 INT
SET @i2 = 3
IF(@i2=3) PRINT 'i=2'
ELSE PRINT 'i<>2'

-- #4
DECLARE @iter INT = 1
WHILE(@iter<5)
BEGIN
	PRINT 'zmienna ma wartosc ' + CAST(@iter AS VARCHAR)
	SET @iter = @iter+1;
END

-- #5
DECLARE @iter2 INT = 3
WHILE(@iter2<=7)
BEGIN
	IF(@iter2=3) PRINT 'poczatek'
	IF(@iter2=5) PRINT 'srodek'
	PRINT @iter2
	IF(@iter2=7) PRINT 'koniec'
	SET @iter2 = @iter2+1
END

-- #6
IF EXISTS(SELECT 1 
	FROM master.dbo.sysdatabases 
	WHERE name='test') DROP DATABASE test
GO
CREATE DATABASE test
GO
CREATE TABLE test.dbo.oddzialy(
	NR_ODD INT,
	NAZWA_ODD VARCHAR(30)
);

-- #7
INSERT INTO test.dbo.oddzialy VALUES
(1, 'KSIEGOWOSC'),
(2, 'IT'),
(3, 'PR'),
(4, 'HR'),
(5, 'FR'),
(6, 'LG')

DECLARE @id INT=1, @nazwa VARCHAR(max)
BEGIN
	SELECT TOP 1 @nazwa=NAZWA_ODD 
	FROM test.dbo.oddzialy
	WHERE NR_ODD=@id
	PRINT 'Nazwa oddzialu to: '+@nazwa
END

-- #8
BEGIN
DECLARE curs CURSOR FOR
SELECT NR_ODD, NAZWA_ODD FROM test.dbo.oddzialy
DECLARE @nr INT, @name VARCHAR(MAX)
OPEN curs
FETCH NEXT FROM curs INTO @nr, @name
WHILE @@FETCH_STATUS=0
BEGIN
	PRINT 'NUMER ODDZIALU TO: ' + CAST(@nr AS VARCHAR(MAX)) + ', NAZWA ODDZIALU TO: ' + @name
	FETCH NEXT FROM curs INTO @nr, @name
END
CLOSE curs
DEALLOCATE curs
END

-- #9
DECLARE @from INT=2
DECLARE curs2 CURSOR FOR
SELECT NR_ODD FROM test.dbo.oddzialy WHERE NR_ODD>@from
DECLARE @nr2 INT, @deleted INT=0
OPEN curs2
FETCH NEXT FROM curs2 INTO @nr2
WHILE @@FETCH_STATUS=0
BEGIN
	IF EXISTS (SELECT * FROM test.dbo.oddzialy
		WHERE @nr2>@from)
		BEGIN
			DELETE FROM test.dbo.oddzialy 
			WHERE CURRENT OF curs2
			SET @deleted = @deleted+1
		END
	FETCH NEXT FROM curs2 INTO @nr2
END
PRINT 'Liczba usuniętych rekordow to: ' + CAST(@deleted AS VARCHAR(MAX))
CLOSE curs2
DEALLOCATE curs2

-- #10
BEGIN
DECLARE @nr_od INT=3;
DECLARE curs3 CURSOR FOR
SELECT NR_ODD FROM test.dbo.oddzialy WHERE NR_ODD=@nr_od;
DECLARE @nr3 INT, @found BIT=0
OPEN curs3
FETCH NEXT FROM curs3 INTO @nr3
WHILE (@@FETCH_STATUS=0)
BEGIN
	UPDATE test.dbo.oddzialy 
	SET NAZWA_ODD='Programmers' 
	WHERE CURRENT OF curs3
	SET @found=1
	FETCH NEXT FROM curs3 INTO @nr3
END
IF (@found=0) INSERT INTO test.dbo.oddzialy VALUES(3, 'Programmers')
CLOSE curs3
DEALLOCATE curs3
END