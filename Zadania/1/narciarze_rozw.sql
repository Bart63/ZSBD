-- Autorzy:
-- Bartosz Durys 229869
-- Szymon Klewicki 229911

use narciarze;

-- #1 
SELECT * FROM kraje; 
SELECT * FROM skocznie; 
SELECT * FROM trenerzy;
SELECT * FROM uczestnictwa_w_zawodach;
SELECT * FROM zawodnicy;
SELECT * FROM zawody;

-- #2 
-- Sprawdzamy czy istnieje kraj, który nie ma zawodników
SELECT k.kraj FROM kraje AS k 
WHERE k.id_kraju NOT IN (
	SELECT DISTINCT id_kraju FROM zawodnicy
);

-- #3
-- Używamy LEFT JOINa, żeby uwzględnić kraje bez zawodników
SELECT k.kraj, COUNT(z.id_skoczka) AS ile_zawodnikow
FROM kraje AS k
LEFT JOIN zawodnicy AS z
ON k.id_kraju=z.id_kraju
GROUP BY k.kraj;

-- #4
SELECT * FROM zawodnicy AS z
WHERE z.id_skoczka NOT IN (
	SELECT DISTINCT id_skoczka FROM uczestnictwa_w_zawodach
);

-- #5
-- Używamy LEFT JOINa na przyszłość gdyby istniaj zawodnik bez zawodów
SELECT z.nazwisko, COUNT(u.id_zawodow) AS ile_zawodow
FROM zawodnicy AS z
LEFT JOIN uczestnictwa_w_zawodach AS u
ON z.id_skoczka=u.id_skoczka
GROUP BY z.nazwisko;

-- #6
SELECT zs.nazwisko, s.nazwa 
FROM zawodnicy AS zs, uczestnictwa_w_zawodach AS u, zawody AS z, skocznie AS s 
WHERE zs.id_skoczka=u.id_skoczka AND u.id_zawodow=z.id_zawodow
AND z.id_skoczni=s.id_skoczni;

-- #7
SELECT id_skoczka, DATEDIFF(year, data_ur, getdate()) AS wiek
FROM zawodnicy
ORDER BY wiek DESC;

-- #8
SELECT zs.id_skoczka, MIN(DATEDIFF(year, zs.data_ur, z.DATA)) AS wiek
FROM zawodnicy AS zs, uczestnictwa_w_zawodach AS u, zawody AS z
WHERE zs.id_skoczka=u.id_skoczka AND u.id_zawodow=z.id_zawodow
GROUP BY zs.id_skoczka;

-- #9
SELECT sedz-k AS roznica FROM skocznie;

-- #10
-- Gdyby wiele skoczni miało najdłuższy punkt konstrukcyjny
SELECT nazwa FROM skocznie 
WHERE k=(SELECT MAX(k) FROM skocznie);

-- #11
SELECT DISTINCT s.id_kraju 
FROM zawody AS z, skocznie AS s
WHERE z.id_skoczni=s.id_skoczni;

-- #12
-- Uwzględniamy postępowanie #3 i #5
SELECT zs.id_skoczka, COUNT(u.id_zawodow+z.id_zawodow) AS skoki
FROM uczestnictwa_w_zawodach AS u
RIGHT JOIN zawodnicy AS zs
ON u.id_skoczka=zs.id_skoczka
LEFT JOIN skocznie AS s
ON zs.id_kraju=s.id_kraju
LEFT JOIN zawody AS z
ON s.id_skoczni=z.id_skoczni
WHERE ISNULL(z.id_zawodow, u.id_zawodow)=ISNULL(u.id_zawodow, z.id_zawodow)
GROUP BY zs.id_skoczka;

-- #13
INSERT INTO trenerzy (id_kraju, imie_t, nazwisko_t, data_ur_t)
SELECT id_kraju, 'Corby', 'Fisher', '1975.07.20'
FROM kraje
WHERE kraj='USA';

-- #14
ALTER TABLE zawodnicy
ADD trener INT;

-- #15 
UPDATE zawodnicy
SET trener = (
	SELECT
		id_trenera
	FROM
		trenerzy AS t
	WHERE
		zawodnicy.id_kraju = t.id_kraju
);

-- #16 
ALTER TABLE zawodnicy
ADD CONSTRAINT FKZawodnicyTrenerzy FOREIGN KEY (trener)
REFERENCES trenerzy (id_trenera);

-- #17
-- Zakładamy, że o 5 lat starszą datę, dodajemy -5
UPDATE trenerzy
SET data_ur_t = (
	SELECT
		DATEADD(year, -5, MIN(data_ur))
	FROM
		zawodnicy AS z
	WHERE
		trenerzy.id_trenera = z.trener
)
WHERE data_ur_t IS NULL;
-- Nie wszyscy trenerzy mają zawodników