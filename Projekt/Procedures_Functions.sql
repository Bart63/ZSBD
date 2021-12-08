-- Procedury i funkcje
USE restauracja
GO

-- Procedury:

-- 1. Sprawdź czy trwa jakaś rezerwacja w podanym zakresie przy danym stoliku
GO
DROP PROCEDURE IF EXISTS dbo.CzyRezerwacjaKoliduje
GO
CREATE PROCEDURE CzyRezerwacjaKoliduje
	@IdStolika tinyint,
	@DataRozpoczecia datetime,
	@DataZakonczenia datetime,
	@CzyKoliduje bit output
AS
BEGIN
	IF EXISTS (
		SELECT * FROM rezerwacje
		WHERE id_stolika = @IdStolika
		AND data_rozpoczecia <= @DataZakonczenia
		AND data_zakonczenia >= @DataRozpoczecia
	)
	BEGIN
		SET @CzyKoliduje = 1
		RETURN
	END
	SET @CzyKoliduje = 0
END
GO

DECLARE @czy_koliduje bit
DECLARE @cur_date datetime = GETDATE()
DECLARE @future_date datetime = DATEADD(HOUR, 1, @cur_date)

-- Koliduje
EXEC CzyRezerwacjaKoliduje 5, @cur_date, @future_date, @czy_koliduje OUTPUT
PRINT @czy_koliduje

-- Nie koliduje
EXEC CzyRezerwacjaKoliduje 7, @cur_date, @future_date, @czy_koliduje OUTPUT
PRINT @czy_koliduje


-- 2. Dodaj rezerwację. Warunki: stolik musi istnieć, liczba osób nie przekracza liczby siedzeń,
-- stolik nie może być wtedy zajęty, data rozpoczęcia nie może być z przeszłości,
-- data zakończenia musi być po dacie rozpoczęcia
GO
DROP PROCEDURE IF EXISTS dbo.DodajRezerwacje
GO
CREATE PROCEDURE DodajRezerwacje
	@IdStolika tinyint,
	@Nazwisko nvarchar(max),
	@DataRozpoczecia datetime,
	@DataZakonczenia datetime,
	@LiczbaOsob tinyint
AS
BEGIN
	IF @IdStolika IS NULL OR @Nazwisko IS NULL OR @DataRozpoczecia IS NULL OR @DataZakonczenia IS NULL OR @LiczbaOsob IS NULL
	BEGIN
		PRINT 'Nie wszystkie parametry zostały podane'
		RETURN
	END

	IF @IdStolika NOT IN (SELECT id_stolika FROM stoliki)
	BEGIN
		PRINT 'Nie ma takiego stolika'
		RETURN
	END

	IF @LiczbaOsob > (SELECT liczba_miejsc FROM stoliki WHERE id_stolika=@IdStolika)
	BEGIN
		PRINT 'Przekroczono limit miejsc stolika'
		RETURN
	END
	
	IF @DataRozpoczecia < GETDATE()
	BEGIN
		PRINT 'Data rozpoczęcia nie może być z przeszłości'
		RETURN
	END

	IF @DataZakonczenia <= @DataRozpoczecia
	BEGIN
		PRINT 'Data zakończenia musi być po dacie rozpoczęcia'
		RETURN
	END

	DECLARE @CzyKoliduje BIT
	EXEC CzyRezerwacjaKoliduje @IdStolika, @DataRozpoczecia, @DataZakonczenia, @CzyKoliduje output
	IF @CzyKoliduje = 1
	BEGIN
		PRINT 'Rezerwacja koliduje z innymi'
		RETURN
	END

	INSERT INTO rezerwacje VALUES
		(@IdStolika, @Nazwisko, @DataRozpoczecia, @DataZakonczenia, @LiczbaOsob)
	PRINT 'Dodano nową rezerwację'
END

DECLARE @czy_koliduje bit
DECLARE @cur_date datetime = DATEADD(MINUTE, 1, GETDATE())
DECLARE @future_date datetime = DATEADD(HOUR, 1, @cur_date)
DECLARE @past_date datetime = DATEADD(HOUR, -1, @cur_date)

-- Niepoprawne
EXEC DodajRezerwacje NULL, NULL, NULL, NULL, NULL
EXEC DodajRezerwacje 100, 'Kochanowski', @cur_date, @future_date, 1
EXEC DodajRezerwacje 1, 'Kochanowski', @cur_date, @future_date, 100
EXEC DodajRezerwacje 1, 'Kochanowski', @past_date, @cur_date, 1
EXEC DodajRezerwacje 1, 'Kochanowski', @cur_date, @past_date, 1
EXEC DodajRezerwacje 5, 'Kochanowski', @cur_date, @future_date, 1
-- Poprawne
EXEC DodajRezerwacje 1, 'Kochanowski', @cur_date, @future_date, 1



-- 3. Dodaj nowe zamówienie. Warunki: Stół musi być zerezerwowany
-- potrawa musi istnieć i być dostępna, liczba porcji musi być większa od zera
-- podany kelner i opcjonalny kucharz muszą istnieć i pracować w danej chwili

GO
DROP PROCEDURE IF EXISTS dbo.DodajZamowienie
GO
CREATE PROCEDURE DodajZamowienie
	@IdStolika tinyint,
	@IdPotrawy smallint,
	@IdKelnera int,
	@LiczbaPorcji tinyint = 1,
	@IdKucharza int = NULL,
	@Komentarz nvarchar(max) = NULL
AS
BEGIN
	IF @IdStolika IS NULL OR @IdPotrawy IS NULL OR @IdKelnera IS NULL OR @LiczbaPorcji IS NULL
	BEGIN
		PRINT 'Nie wszystkie parametry zostały podane'
		RETURN
	END

	IF @IdStolika NOT IN (SELECT id_stolika FROM stoliki)
	BEGIN
		PRINT 'Nie ma takiego stolika'
		RETURN
	END
	
	IF @IdPotrawy NOT IN (SELECT id_potrawy FROM potrawy)
	BEGIN
		PRINT 'Nie ma takiej potrawy'
		RETURN
	END

	IF (SELECT czy_dostepny FROM potrawy WHERE id_potrawy = @IdPotrawy) = 0
	BEGIN
		PRINT 'Potrawa jest niedostępna'
		RETURN
	END

	IF @LiczbaPorcji < 1
	BEGIN
		PRINT 'Niepoprawna liczba porcji'
		RETURN
	END
	
	IF NOT EXISTS (
		SELECT * FROM rezerwacje
		WHERE id_stolika = @IdStolika
		AND data_rozpoczecia <= GETDATE()
		AND data_zakonczenia > GETDATE()
	)
	BEGIN
		PRINT 'Stolik nie jest przez nikogo zarezerwowany'
		RETURN
	END

	IF @IdKelnera NOT IN (
		SELECT id_pracownika FROM pracownicy 
		WHERE id_stanowiska = (
			SELECT id_stanowiska FROM stanowiska
			WHERE nazwa='kelner'
		)
	)
	BEGIN
		PRINT 'Podany kelner nie istnieje'
		RETURN
	END

	IF NOT EXISTS (
		SELECT obecnosc FROM zmiany
		WHERE id_pracownika=@IdKelnera
		AND data_rozpoczecia <= GETDATE()
		AND data_zakonczenia >= GETDATE()
		AND obecnosc IN ('obecny', 'nadgodziny')
	)
	BEGIN
		PRINT 'Podany kelner obecnie nie pracuje'
		RETURN
	END

	IF @IdKucharza IS NULL
	BEGIN
		INSERT INTO zamowienia VALUES
			(@IdStolika, @IdPotrawy, @LiczbaPorcji, GETDATE(), NULL, @Komentarz, @IdKelnera, NULL)
		PRINT 'Dodano nowe zamówienie'
		RETURN
	END

	IF @IdKucharza NOT IN (
		SELECT id_pracownika FROM pracownicy 
		WHERE id_stanowiska = (
			SELECT id_stanowiska FROM stanowiska
			WHERE nazwa='kucharz'
		)
	)
	BEGIN
		PRINT 'Podany kucharz nie istnieje'
		RETURN
	END

	IF NOT EXISTS (
		SELECT obecnosc FROM zmiany
		WHERE id_pracownika=@IdKucharza
		AND data_rozpoczecia <= GETDATE()
		AND data_zakonczenia >= GETDATE()
		AND obecnosc IN ('obecny', 'nadgodziny')
	)
	BEGIN
		PRINT 'Podany kucharz obecnie nie pracuje'
		RETURN
	END
	
	INSERT INTO zamowienia VALUES
		(@IdStolika, @IdPotrawy, @LiczbaPorcji, GETDATE(), NULL, @Komentarz, @IdKelnera, @IdKucharza)
	PRINT 'Dodano nowe zamówienie'
END

-- Niepoprawne
EXEC DodajZamowienie NULL, NULL, NULL
EXEC DodajZamowienie 33, 10, 1
EXEC DodajZamowienie 1, 111, 1
EXEC DodajZamowienie 1, 6, 1
EXEC DodajZamowienie 1, 10, 1, 0
EXEC DodajZamowienie 9, 10, 1
EXEC DodajZamowienie 3, 10, 11
EXEC DodajZamowienie 3, 10, 1
EXEC DodajZamowienie 3, 10, 2, 2, 44
EXEC DodajZamowienie 3, 10, 2, 2, 4
-- Poprawne
EXEC DodajZamowienie 3, 13, 2, 1
EXEC DodajZamowienie 3, 7, 2, 1, 5


-- 4. Daj premię pracownikowi. Warunki: Nie może być ujemna, pracownik musi istnieć
-- pracownik musi obecnie pracować, suma zarobków nie może przekraczać maksymalnej kwoty na stanowisku
GO
DROP PROCEDURE IF EXISTS dbo.UstawPremie
GO
CREATE PROCEDURE UstawPremie
	@IdPracownika int,
	@Premia smallmoney = 0
AS
BEGIN
	IF @IdPracownika IS NULL
	BEGIN
		PRINT 'Niepoprawne ID pracownika'
		RETURN
	END

	IF @Premia < 0
	BEGIN
		PRINT 'Premia nie może być ujemna'
		RETURN
	END

	IF @IdPracownika NOT IN (SELECT id_pracownika FROM pracownicy)
	BEGIN
		PRINT 'Pracownik nie istnieje'
		RETURN
	END
	
	IF (SELECT data_zwolnienia FROM pracownicy WHERE id_pracownika=@IdPracownika) IS NOT NULL
	BEGIN
		PRINT 'Pracownik obecnie nie pracuje'
		RETURN
	END

	IF (@Premia + (SELECT placa FROM pracownicy WHERE id_pracownika=@IdPracownika)) > (
		SELECT placa_max FROM stanowiska
		WHERE id_stanowiska = (
			SELECT id_stanowiska FROM pracownicy WHERE id_pracownika = @IdPracownika
		)
	)
	BEGIN
		PRINT 'Przekroczono maksymalną kwotę zarobków na danym stanowisku'
		RETURN
	END
	UPDATE pracownicy SET premia=@Premia WHERE id_pracownika=@IdPracownika
	PRINT 'Zaktualizowano premię pracownika'
END
GO

-- Niepoprawne
EXEC UstawPremie NULL
EXEC UstawPremie 1, -100
EXEC UstawPremie 30, 100
EXEC UstawPremie 3, 100
EXEC UstawPremie 1, 10000
-- Poprawne
EXEC UstawPremie 1
EXEC UstawPremie 1, 100


-- Funkcje

-- Zliczanie ile zapłacono przy każdej rezerwacji
-- Potrawy są połączone z zamówieniem, a zamówienia ze stolikiem
-- który też jest w rezerwacji. Może istnieć tylko jedna rezerwacja stolika 
-- w danym czasie, stąd identyfikacja.
GO
DROP FUNCTION IF EXISTS dbo.IleZaplacono
GO
CREATE FUNCTION	IleZaplacono(@IdRezerwacji int)
RETURNS smallmoney
AS
	BEGIN
		DECLARE @suma smallmoney
		SET @suma = (
			SELECT SUM(p.cena*z.liczba_porcji) FROM potrawy p, rezerwacje r, zamowienia z
			WHERE z.id_potrawy = p.id_potrawy AND r.id_stolika = z.id_stolika
			AND z.data_zlozenia BETWEEN r.data_rozpoczecia AND r.data_zakonczenia
			AND r.id_rezerwacji = @IdRezerwacji
		)
		RETURN @suma
	END
GO

SELECT id_rezerwacji, nazwisko, dbo.IleZaplacono(id_rezerwacji) AS zaplacono FROM rezerwacje

-- Ile pracownik zrealizował zamówień
GO
DROP FUNCTION IF EXISTS dbo.IleZrealizowal
GO
CREATE FUNCTION	IleZrealizowal(@IdPracownika int)
RETURNS bigint
AS
	BEGIN
		DECLARE @ileZamowien bigint
		SET @ileZamowien = (
			SELECT COUNT(*) FROM pracownicy p, zamowienia z
			WHERE data_realizacji IS NOT NULL
			AND p.id_pracownika = @IdPracownika
			AND (
				@IdPracownika IN (id_kelnera, id_kucharza)
			)
		)
		RETURN @ileZamowien
	END
GO

SELECT id_pracownika, imie, nazwisko, dbo.IleZrealizowal(id_pracownika) AS zrealizowane_zamowienia 
FROM pracownicy