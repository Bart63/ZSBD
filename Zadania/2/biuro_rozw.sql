-- Autorzy:
-- Bartosz Durys 229869
-- Szymon Klewicki 229911

use biuro;

-- #1
SELECT 
	nieruchomoscnr,
	(SELECT COUNT(*) 
		FROM wynajecia 
		WHERE nieruchomoscNr=n.nieruchomoscnr
	) AS wynajecia,
	(SELECT COUNT(*)
		FROM wizyty
		WHERE nieruchomoscnr=n.nieruchomoscnr
	) AS wizyty
FROM nieruchomosci AS n;

-- #2
-- Możliwe wzrosty cen o wartości wielocyfrowe
SELECT 
	n.nieruchomoscnr,
	(CONVERT(VARCHAR(MAX), 
		(-100 + 100*n.czynsz/(
			SELECT TOP 1 czynsz FROM wynajecia AS w
			WHERE w.nieruchomoscNr=n.nieruchomoscnr
			ORDER BY od_kiedy ASC)))
	) + '%' AS wzrost_ceny
FROM nieruchomosci AS n;

-- #3
-- Możliwa rezerwacja od pierwszego dnia do ostatniego dnia danego miesiąca
SELECT 
	w.nieruchomoscNr, 
	SUM(w.czynsz*(1 + DATEDIFF(mm, w.od_kiedy, w.do_kiedy)))
FROM wynajecia AS w;

-- #4
-- Wliczamy biura bez nieruchomosci i nieruchomosci bez wynajęć
SELECT 
	b.biuroNr, 
	CONVERT(smallmoney, ISNULL(zysk_biur.zysk, 0)) AS zarobek
FROM biura AS b
LEFT JOIN
	(
		SELECT
			n.biuroNr,
			0.3*SUM(w.czynsz*(1+DATEDIFF(mm,od_kiedy,do_kiedy))) AS zysk
		FROM nieruchomosci AS n
		LEFT JOIN wynajecia AS w
		ON n.nieruchomoscnr=w.nieruchomoscNr
		GROUP BY n.biuroNr
	) AS zysk_biur
ON b.biuroNr=zysk_biur.biuroNr;

-- #5a
-- Zwracamy tylko jedno miasto
-- Sprawdzamy czy nieruchomosc jest wynajeta przez biuro
SELECT TOP 1
	miasto,
	COUNT(*) AS ilosc
FROM
	nieruchomosci AS n,
	wynajecia AS w
WHERE
	n.nieruchomoscnr=w.nieruchomoscNr
	AND n.biuroNr IS NOT NULL
GROUP BY n.miasto
ORDER BY ilosc DESC;

-- #5b
-- Zwracamy tylko jedno miasto
SELECT TOP 1
	n.miasto,
	SUM(w.czynsz
		* (1 + DATEDIFF(mm, w.od_kiedy, w.do_kiedy))
	) AS przychod 
FROM 
	nieruchomosci AS n, 
	wynajecia AS w
WHERE n.nieruchomoscnr=w.nieruchomoscNr
GROUP BY miasto
ORDER BY przychod DESC;

-- #6
-- Data wizyty musi być przed datą wynajmu (od_kiedy)
SELECT DISTINCT
	w1.klientnr, 
	w1.nieruchomoscnr
FROM 
	wizyty w1, 
	wynajecia w2
WHERE 
	w1.klientnr=w2.klientnr
	AND w1.nieruchomoscnr=w2.nieruchomoscNr
	AND w1.data_wizyty<w2.od_kiedy;

-- #7
-- Przed datą najmu przez klienta danej nieruchomości, odwiedził on n unikalnych nieruchomości wraz tą wynajętą
-- Sprawdzamy czy mieliśmy wizytę w wynajętej nieruchomości przed datą najmu
-- Rozróżniamy wynajęcia tej samej nieruchomości przez tego samego klienta datą rozpoczęcia najmu
-- Zliczamy wizyty danego klienta w unikalnych nieruchomościach
SELECT 
	w2.klientnr, 
	w2.nieruchomoscNr, 
	COUNT(*) AS liczba_wizyt
FROM
	(
		SELECT 
			klientnr, 
			nieruchomoscnr, 
			MIN(w.data_wizyty) AS min_data_wizyty
		FROM wizyty AS w
		GROUP BY klientnr, nieruchomoscnr
	) AS w1,
	wynajecia AS w2
WHERE 
	w1.klientnr=w2.klientnr
	AND w2.nieruchomoscNr 
	IN (SELECT w.nieruchomoscnr 
		FROM wizyty AS w
		WHERE w.klientnr=w2.klientnr
		AND w.nieruchomoscNr=w2.nieruchomoscNr
		AND w.data_wizyty<w2.od_kiedy)
	AND w1.min_data_wizyty<w2.od_kiedy
GROUP BY w2.klientnr, w2.nieruchomoscNr, w2.od_kiedy;

-- #8
SELECT DISTINCT k.klientnr
FROM
	klienci AS k,
	wynajecia AS w
WHERE
	k.klientnr=w.klientnr
	AND k.max_czynsz<w.czynsz;

-- #9
SELECT b.biuroNr 
FROM biura AS b
WHERE b.biuroNr NOT IN (
	SELECT DISTINCT n.biuroNr 
	FROM nieruchomosci AS n
);

-- #10a
-- Wliczamy, że personel musi należeć do biura
SELECT 
	SUM(CASE WHEN plec='K' THEN 1 ELSE 0 END) AS K,
	SUM(CASE WHEN plec='M' THEN 1 ELSE 0 END) AS M
FROM personel AS p
WHERE p.biuroNr IS NOT NULL;

-- #10b
-- Wliczamy też jak biuro nie zatrudniaja żadnej płci
SELECT 
	b.biuroNr,
	SUM(CASE WHEN plec='K' THEN 1 ELSE 0 END) AS K,
	SUM(CASE WHEN plec='M' THEN 1 ELSE 0 END) AS M
FROM biura AS b
LEFT JOIN personel AS p
ON b.biuroNr=p.biuroNr
GROUP BY b.biuroNr;

-- #10c
-- Wliczony przypadek biur w pewnym mieście, w których nikt nie pracuje
SELECT 
	b.miasto,
	SUM(CASE WHEN plec='K' THEN 1 ELSE 0 END) AS K,
	SUM(CASE WHEN plec='M' THEN 1 ELSE 0 END) AS M
FROM biura AS b
LEFT JOIN personel AS p
ON b.biuroNr=p.biuroNr
GROUP BY b.miasto;

-- #10d
SELECT 
	p.stanowisko,
	SUM(CASE WHEN plec='K' THEN 1 ELSE 0 END) AS K,
	SUM(CASE WHEN plec='M' THEN 1 ELSE 0 END) AS M
FROM personel AS p
GROUP BY p.stanowisko;
