USE restauracja;
GO

INSERT INTO potrawy VALUES 
	('mięsny', 'stek', 63, 400, 1),
	('mięsny', 'hamburger', 30, 270, 1),
	('mięsny', 'schabowy panierowany', 20, 260, 1),
	('mięsny', 'kotlet de voileile', 24, 290, 1),
	('mięsny', 'drobiowy panierowany', 20, 260, 1),
	('mięsny', 'golonka z kością', 6, 100, 0),
	('wege', 'sałatka', 22, 200, 1),
	('wege', 'naleśniki z owocami', 20, 250, 1),
	('wege', 'pierogi z kapustą', 25, 300, 1),
	('dodatki', 'surówka', 10, 100, 1),
	('dodatki', 'frytki', 8, 100, 1),
	('dodatki', 'kluski śląskie', 10, 150, 0),
	('napoje', 'piwo', 10, 500, 1),
	('napoje', 'cola', 8, 500, 1),
	('napoje', 'sok jabłkowy', 7, 200, 1),
	('napoje', 'herbata', 9, 200, 1),
	('napoje', 'kawa', 8, 200, 0),
	('napoje', 'woda', 6, 500, 1),
	('deser', 'deser lodowy', 18, 200, 1),
	('deser', 'szarlotka z bitą śmietaną', 18, 200, 0)
	
INSERT INTO stoliki VALUES 
	(2, 'przód'),
	(2, 'przód'),
	(4, 'przód'),
	(4, 'przód'),
	(6, 'środek'),
	(6, 'środek'),
	(4, 'tył'),
	(4, 'tył'),
	(2, 'tył'),
	(4, 'lewa ściana'),
	(4, 'lewa ściana'),
	(6, 'prawa ściana')
	
DECLARE @cur_date datetime = GETDATE();
INSERT INTO rezerwacje VALUES
	(1, 'Nowak', DATEADD(HOUR, -6, @cur_date), DATEADD(HOUR, -5, @cur_date), 1),
	(5, 'Kowalski', DATEADD(HOUR, -1, @cur_date), DATEADD(HOUR, 1, @cur_date), 5),
	(1, 'Durys', @cur_date, DATEADD(HOUR, 1, @cur_date), 2),
	(3, 'Klewicki', @cur_date, DATEADD(HOUR, 2, @cur_date), 3)


INSERT INTO stanowiska VALUES
	('kelner', 2500, 3000, 1, 3),
	('kucharz', 2800, 3800, 2, 4),
	('szef kuchni', 3500, 4600, 1, 1)

INSERT INTO imprezy VALUES
	('urodziny', DATEADD(day, 1, @cur_date), DATEADD(day, 2, @cur_date), 23, 'jednodniowa impreza')

INSERT INTO pracownicy VALUES
	('Jan', 'Kowalski', 'M', 1, DATEADD(YEAR, -1, @cur_date), NULL, 2800, 100),
	('Maria', 'Wójcik', 'K', 1, DATEADD(YEAR, -1, @cur_date), NULL, 3000, 0),
	('Barbara', 'Wróbel', 'K', 1, DATEADD(YEAR, -1, @cur_date), DATEADD(MONTH, -2, @cur_date), 3000, 0),
	('Henryk', 'Mazur', 'M', 2, DATEADD(YEAR, -1, @cur_date), NULL, 3300, 200),
	('Alicja', 'Dąbrowska', 'K', 2, DATEADD(MONTH, -6, @cur_date), NULL, 3100, 0),
	('Ryszard', 'Zając', 'M', 2, DATEADD(YEAR, -1, @cur_date), DATEADD(MONTH, -5, @cur_date), 3400, 0),
	('Paweł', 'Nowakowski', 'M', 3, DATEADD(YEAR, -1, @cur_date), null, 4500, 0)

INSERT INTO zmiany VALUES
	(1, DATEADD(DAY, -1, @cur_date), DATEADD(HOUR, -14, @cur_date), 'obecny'),
	(2, DATEADD(HOUR, -6, @cur_date), DATEADD(HOUR, 4, @cur_date), 'obecny'),
	(4, DATEADD(DAY, -1, @cur_date), DATEADD(HOUR, -14, @cur_date), 'obecny'),
	(5, DATEADD(HOUR, -6, @cur_date), DATEADD(HOUR, 4, @cur_date), 'obecny'),
	(4, DATEADD(HOUR, -1, @cur_date), DATEADD(HOUR, 7, @cur_date), 'nieobecność nieusprawiedliwiona'),
	(1, DATEADD(DAY, 1, @cur_date), DATEADD(HOUR, 34, @cur_date), 'obecny'),
	(5, DATEADD(DAY, 1, @cur_date), DATEADD(HOUR, 34, @cur_date), 'obecny'),
	(4, DATEADD(DAY, 1, @cur_date), DATEADD(DAY, 5, @cur_date), 'urlop')

INSERT INTO zamowienia VALUES
	(1, 13, 1, DATEADD(HOUR, -6, @cur_date), DATEADD(HOUR, -6, @cur_date), NULL, 2, NULL),
	(5, 1, 2, DATEADD(HOUR, -1, @cur_date), @cur_date, 'medium rare', 2, 5),
	(5, 2, 2, DATEADD(HOUR, -1, @cur_date), @cur_date, NULL, 2, 5),
	(5, 9, 1, DATEADD(HOUR, -1, @cur_date), @cur_date, NULL, 2, 5),
	(1, 15, 1, @cur_date, @cur_date, '', 2, NULL),
	(3, 11, 2, @cur_date, NULL, NULL, 2, 5),
	(3, 3, 2, @cur_date, NULL, NULL, 2, 5)