-- Bartosz Durys 229869, Szymon Klewicki 229911

USE restauracja

-- Wyświetlanie danych

-- Wszytskich tabele
SELECT * FROM potrawy
SELECT * FROM stoliki
SELECT * FROM rezerwacje
SELECT * FROM stanowiska
SELECT * FROM imprezy
SELECT * FROM pracownicy
SELECT * FROM zmiany
SELECT * FROM zamowienia

-- 1. Niedostępne potrawy
SELECT * FROM potrawy WHERE czy_dostepny=0

-- 2. Wszystkie typy potraw
SELECT DISTINCT typ FROM potrawy

-- 3. Najdroższe potrawy
SELECT nazwa FROM potrawy 
WHERE cena = (
	SELECT TOP 1 cena 
	FROM potrawy 
	ORDER BY cena DESC
)

-- 4. Średnia cena wszystkich potraw
SELECT AVG(cena) FROM potrawy

-- 5. Minimalna cena dodatku
SELECT MIN(cena) FROM potrawy WHERE typ='dodatki'

-- 6. Ile dostępnych stolików
SELECT (SELECT COUNT(*) FROM stoliki) - COUNT(*) 
FROM stoliki s, rezerwacje r
WHERE s.id_stolika = r.id_stolika
AND GETDATE() BETWEEN r.data_rozpoczecia AND r.data_zakonczenia

-- 7. Lokalizacje stołów i liczb siedzeń
SELECT lokalizacja, SUM(liczba_miejsc) AS siedzenia 
FROM stoliki GROUP BY lokalizacja 

-- 8. Lokalizacje z najmniejszą liczbą stołów
SELECT lokalizacja FROM stoliki
GROUP BY lokalizacja 
HAVING COUNT(id_stolika) = (
	SELECT TOP 1 COUNT(id_stolika) AS liczba_stolow FROM stoliki
	GROUP BY lokalizacja ORDER BY liczba_stolow ASC
)

-- 9. Obecne rezerwacje
SELECT * FROM rezerwacje
WHERE data_rozpoczecia <= GETDATE() AND
data_zakonczenia >= GETDATE()

-- 10. Liczba wolnych miejsc pracy
SELECT SUM(zatrudnionych_max)-(
	SELECT COUNT(*) FROM pracownicy 
	WHERE data_zwolnienia IS NOT NULL
)
FROM stanowiska

-- 11. Minimalna miesięczna płaca dla pracowników
SELECT SUM(placa_min*zatrudnionych_min) FROM stanowiska

-- 12. Ile godzin do najbliższej imprezy (imprezy nie mogą odbywać się równolegle)
SELECT TOP 1 DATEDIFF(HOUR, GETDATE(), data_rozpoczecia) FROM imprezy 
WHERE data_rozpoczecia > GETDATE()
ORDER BY data_rozpoczecia ASC

-- 13. Przepracowane miesiące przez każdego pracownika
SELECT id_pracownika, imie, nazwisko, 
	DATEDIFF(MONTH, data_zatrudnienia, 
		CASE
			WHEN data_zwolnienia IS NULL THEN GETDATE()
			ELSE data_zwolnienia
		END
	) AS przepracowane_miesiace
FROM pracownicy

-- 14. Liczba obecnych pracowników na poszczególnych stanowiskach
SELECT s.nazwa, COUNT(*) AS liczba_pracownikow
FROM pracownicy AS p, stanowiska AS s
WHERE s.id_stanowiska=p.id_stanowiska AND p.data_zwolnienia IS NULL
GROUP BY s.nazwa

-- 15. Liczba osób pracujących danej płci na danym stanowisku
SELECT
	s.nazwa,
	SUM(CASE WHEN p.plec='K' THEN 1 ELSE 0 END) AS K,
	SUM(CASE WHEN p.plec='M' THEN 1 ELSE 0 END) AS M
FROM pracownicy p, stanowiska s
WHERE p.data_zwolnienia IS NULL
GROUP BY s.nazwa;

-- 16. Kto ma obecnie zmianę i nie jest obecny
SELECT p.id_pracownika, p.imie, p.nazwisko FROM zmiany z, pracownicy p
WHERE p.id_pracownika = z.id_pracownika
AND z.data_rozpoczecia < GETDATE()
AND z.data_zakonczenia > GETDATE()
AND z.obecnosc != 'obecny'

-- 17. Pokaż niezrealizowane zamówienia z dzisiaj
SELECT * FROM zamowienia
WHERE data_realizacji IS NULL
AND DATEPART(DAY, data_zlozenia) = DATEPART(DAY, GETDATE())

-- 18. Kto obecnie jest w restauracji i w jakiej lokalizacji
SELECT r.nazwisko, s.lokalizacja FROM rezerwacje r, stoliki s
WHERE r.id_stolika = s.id_stolika
AND data_rozpoczecia <= GETDATE()
AND data_zakonczenia >= GETDATE() 

-- 19. Pokaż komentarze do potraw o ile istnieją
SELECT p.nazwa, z.komentarz FROM zamowienia z, potrawy p
WHERE z.id_potrawy = p.id_potrawy
AND NULLIF(z.komentarz, '') IS NOT NULL