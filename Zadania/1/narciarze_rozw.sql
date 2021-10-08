use narciarze

-- #1
SELECT * FROM kraje, skocznie, trenerzy, uczestnictwa_w_zawodach, zawodnicy, zawody;

-- #2
SELECT k.id_kraju FROM kraje AS k 
WHERE k.id_kraju NOT IN (SELECT id_kraju FROM zawodnicy)

-- #3
SELECT k.kraj, COUNT(*) 
FROM zawodnicy AS z, kraje AS k
WHERE z.id_kraju=k.id_kraju GROUP BY k.kraj;

-- #4
SELECT * FROM zawodnicy AS z
WHERE z.id_skoczka NOT IN (SELECT id_skoczka FROM uczestnictwa_w_zawodach);

-- #5
SELECT z.nazwisko, COUNT(*) FROM zawodnicy AS z, uczestnictwa_w_zawodach AS u
WHERE z.id_skoczka=u.id_skoczka GROUP BY z.nazwisko;

-- #6
SELECT zs.nazwisko, s.nazwa FROM zawodnicy AS zs, uczestnictwa_w_zawodach AS u,
zawody AS z, skocznie AS s 
WHERE zs.id_skoczka=u.id_skoczka AND u.id_zawodow=z.id_zawodow
AND z.id_skoczni=s.id_skoczni;

-- #7
SELECT id_skoczka, DATEDIFF(year, data_ur, getdate()) 
FROM zawodnicy;

-- #8
SELECT zs.id_skoczka, MIN(DATEDIFF(year, zs.data_ur, z.DATA))
FROM zawodnicy AS zs, uczestnictwa_w_zawodach AS u, zawody AS z
WHERE zs.id_skoczka=u.id_skoczka AND u.id_zawodow=z.id_zawodow
GROUP BY zs.id_skoczka;
-- #9
SELECT sedz-k FROM skocznie;

-- #10
SELECT nazwa FROM skocznie 
WHERE k=(SELECT MAX(k) FROM skocznie)

-- #11
SELECT DISTINCT s.id_kraju 
FROM zawody AS z, skocznie AS s
WHERE z.id_skoczni=s.id_skoczni;

-- #12
SELECT zs.id_skoczka, COUNT(zs.id_skoczka) FROM zawodnicy AS zs, uczestnictwa_w_zawodach AS u, zawody AS z, skocznie AS s
WHERE zs.id_skoczka=u.id_skoczka AND u.id_zawodow=z.id_zawodow AND z.id_skoczni=s.id_skoczni AND zs.id_kraju=s.id_kraju
GROUP BY zs.id_skoczka;

--13

--Od 13 sobie wygoogluję XD

insert into trenerzy (id_kraju, imie_t, nazwisko_t, data_ur_t)
values (7, 'Corby', 'Fisher', '1975.07.20')

select * from trenerzy
-- Zasada: Jeden trener na jeden kraj

-- #14

alter table zawodnicy
add trener int


-- #15




-- #17
--INSERT JAKIS XD
