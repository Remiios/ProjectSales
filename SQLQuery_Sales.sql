
-- Wyświetlenie zaimportowanych tabel

SELECT *
FROM Project_Sales..Przedstawiciel

SELECT *
FROM Project_Sales..Sales

SELECT * 
FROM Project_Sales..Klienci



-- Wyświetlenie połączonych tabel za pomocą ID_Przedstawiciela oraz ID_Klienta

SELECT * 
FROM Project_Sales..Sales sal
LEFT JOIN Project_Sales..Przedstawiciel prz
ON sal.ID_Przedstawiciel = prz.ID_Przedstawiciel
LEFT JOIN Project_Sales..Klienci kli
ON sal.ID_Klienta = kli.ID_Klienta



-- AGREGACJA DANYCH

-- Wybranie poszczególnych danych i podział Imienia i Nazwiska przedstawiciela 

SELECT sal.Kwota_Zakupy AS Kwota_Sprzedaży,
	sal.Data_rozmowy,
	SUBSTRING(prz.Imie_Nazwisko, 1, CHARINDEX(' ', prz.Imie_Nazwisko)-1) AS Imie,
	SUBSTRING(prz.Imie_Nazwisko, CHARINDEX(' ', prz.Imie_Nazwisko), 255) AS Nazwisko,
	prz.Oddział
FROM Project_Sales..Sales sal
LEFT JOIN Project_Sales..Przedstawiciel prz
ON sal.ID_Przedstawiciel = prz.ID_Przedstawiciel
ORDER BY Data_Rozmowy DESC;



-- Łączna kwota sprzedaży w poszczególnych oddziałach

SELECT SUM(sal.Kwota_Zakupy) AS Kwota_Sprzedaży,
	prz.Oddział,
	prz.Region
FROM Project_Sales..Sales sal
LEFT JOIN Project_Sales..Przedstawiciel prz
ON sal.ID_Przedstawiciel = prz.ID_Przedstawiciel
GROUP BY prz.Oddział, prz.Region



-- Wybranie 3 najlepszych sprzedawców wraz z ich oddziałem

WITH Sprzedaz_P (Kwota_Zakupy, Nazwisko_Sprzedawcy, Oddział)
AS
(
	SELECT 
		sal.Kwota_Zakupy,
		SUBSTRING(prz.Imie_Nazwisko,CHARINDEX(' ', prz.Imie_Nazwisko),255) AS Nazwisko_Sprzedawcy, 
		prz.Oddział
	FROM Project_Sales..Sales sal
	LEFT JOIN Project_Sales..Przedstawiciel prz
	ON sal.ID_Przedstawiciel = prz.ID_Przedstawiciel
)
SELECT TOP 3
	SUM(Kwota_Zakupy) AS Kwota_Sprzedaży, 
	Nazwisko_Sprzedawcy, 
	Oddział
FROM Sprzedaz_P
GROUP BY Nazwisko_Sprzedawcy, 
	Oddział
ORDER BY Kwota_Sprzedaży DESC;



-- Tworzenie tabeli tymczasowej do późniejszych obliczeń

DROP TABLE IF EXISTS #Dane_Sales
Create Table #Dane_Sales
(
ID_Przedstawiciel nvarchar(255),
Imie_Nazwisko nvarchar(255),
Oddział nvarchar(255),
Region nvarchar(255),
Data_Rozmowy date,
Czas_Rozmowy numeric,
Kwota_Zakupy numeric,
ID_Klienta float,
Imie nvarchar(255),
Nazwisko nvarchar(255),
Email nvarchar(255),
Miasto nvarchar(255),
Województwo nvarchar(255),
Karta_członkowska nvarchar(255)
)

INSERT INTO #Dane_Sales
SELECT  prz.ID_Przedstawiciel,
	prz.Imie_Nazwisko,
	prz.Oddział,
	prz.Region,
	sal.Data_Rozmowy,
	sal.Czas_Rozmowy,
	sal.Kwota_Zakupy,
	kli.ID_Klienta,
	kli.Imie,
	kli.Nazwisko,
	kli.Email,
	kli.Miasto,
	kli.Województwo,
	kli.Karta_członkowska
FROM Project_Sales..Sales sal
LEFT JOIN Project_Sales..Przedstawiciel prz
ON sal.ID_Przedstawiciel = prz.ID_Przedstawiciel
LEFT JOIN Project_Sales..Klienci kli
ON sal.ID_Klienta = kli.ID_Klienta
ORDER BY Data_Rozmowy DESC;


-- Sprawdzenie działania nowej tabeli tymczasowej

SELECT * 
FROM #Dane_Sales



-- Informacje o unikatowych klientach 

SELECT DISTINCT ID_Klienta,
	(Imie + ' ' + Nazwisko) as Imie_Nazwisko,
	Email,
	Miasto,
	Województwo,
	Karta_członkowska
FROM #Dane_Sales
ORDER BY ID_Klienta ASC;


-- wyświetlenie informacji o adresach email

SELECT DISTINCT (Imie + ' ' + Nazwisko) as Imie_Nazwisko,
	SUBSTRING(Email, 1, CHARINDEX('@', Email) - 1) AS Nazwa_Email,
	SUBSTRING(Email, CHARINDEX('@', Email), 99) AS Domena
FROM #Dane_Sales;



-- Łączny czas rozmowy, łączna kwota zakupu przez danego klienta oraz kwota wydanych środków na każdą minutę rozmowy

SELECT TOP 5 ID_Klienta, 
	Nazwisko,
	SUM(Czas_Rozmowy) AS ŁącznyCzasRozmowy,
	SUM(Kwota_Zakupy) AS ŁącznaKwotaZakupu,
	SUM(Kwota_Zakupy)/SUM(Czas_Rozmowy) AS Zakup_CzasRozmowy
FROM #Dane_Sales
GROUP BY ID_Klienta, Nazwisko
ORDER BY Zakup_CzasRozmowy DESC;


-- Średni czas rozmowy, sprzedaż oraz efektywność pracy danego oddziału
SELECT TOP 3 Oddział, 
	Region,
	AVG(Czas_Rozmowy) AS ŚredniCzasRozmowy,
	AVG(Kwota_Zakupy) AS ŚredniaWartośćSprzedaży,
	AVG(Kwota_Zakupy)/AVG(Czas_Rozmowy) AS Efektywność
FROM #Dane_Sales
GROUP BY Oddział, Region
ORDER BY Efektywność DESC;


-- Liczba telefonów wykonanych przez przedstawicieli
SELECT COUNT(ID_Klienta) as LiczbaTelefonów,
	Imie_Nazwisko,
	Oddział
FROM #Dane_Sales
GROUP BY Imie_Nazwisko, Oddział
ORDER BY LiczbaTelefonów DESC;



-- Liczba połączeń do danego klienta oraz łaczny czas rozmowy z danym klientem
SELECT ID_Klienta,
	Nazwisko,
	COUNT(ID_Przedstawiciel) as LiczbaPołączeń,
	SUM(Czas_Rozmowy) AS ŁącznyCzasRozmowy
FROM #Dane_Sales
GROUP BY ID_Klienta, Nazwisko
ORDER BY LiczbaPołączeń DESC;



-- Liczba połączeń wykonanych przez danego przedstawiciela do danego klienta
WITH T_Ilosc (ID_Klienta, Nazwisko, P_1, P_2, P_3, P_4, P_5, ID_Przedstawiciel)
AS 
(
	SELECT ID_Klienta,
	Nazwisko,
	CASE
		WHEN ID_Przedstawiciel = 'P01' THEN 1 
		ELSE 0
	END AS P_1,
		CASE
		WHEN ID_Przedstawiciel = 'P02' THEN 1 
		ELSE 0
	END AS P_2,
		CASE
		WHEN ID_Przedstawiciel = 'P03' THEN 1 
		ELSE 0
	END AS P_3,
		CASE
		WHEN ID_Przedstawiciel = 'P04' THEN 1 
		ELSE 0
	END AS P_4,
		CASE
		WHEN ID_Przedstawiciel = 'P05' THEN 1 
		ELSE 0
	END AS P_5,
	ID_Przedstawiciel
FROM #Dane_Sales
)
--SELECT * FROM T_Ilosc
SELECT ID_Klienta,
	Nazwisko,
	SUM(P_1) AS Przeds_1,
	SUM(P_2) AS Przeds_2,
	SUM(P_3) AS Przeds_3,
	SUM(P_4) AS Przeds_4,
	SUM(P_5) AS Przeds_5,
	COUNT(ID_Przedstawiciel) AS Liczba_Połączeń
FROM T_Ilosc
GROUP BY ID_Klienta, Nazwisko
ORDER BY ID_Klienta ASC;



-- Wybranie klientów, którzy posiadają kartę członkowską oraz wydali łącznie ponad 9000zł 

WITH Top_zakupy (SumaZakupów, ID_Klienta, Nazwisko, Email, Karta_Członkowska) 
AS
(
SELECT SUM(Kwota_Zakupy) AS SumaZakupów, 
	ID_Klienta,
	Nazwisko,
	Email,
	Karta_członkowska
FROM #Dane_Sales
GROUP BY ID_Klienta, Nazwisko, Email, Karta_członkowska
)
SELECT *
FROM Top_zakupy tz
WHERE Karta_Członkowska = 'Y' AND SumaZakupów >= 9000
ORDER BY SumaZakupów DESC;



-- Liczba wykonanych telefonów w każdym dniu pracy przez przedstawicieli

SELECT COUNT(ID_Przedstawiciel) AS LiczbaRozmów,
	SUM(Czas_Rozmowy) AS CzasRozmów,
	Data_Rozmowy
FROM #Dane_Sales
GROUP BY Data_Rozmowy
--ORDER BY LiczbaRozmów DESC;



-- Kolejne agregacje wkrótce




