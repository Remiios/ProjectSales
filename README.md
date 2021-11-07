# ProjectSales

Jedno z pierwszych podejść do stworzenia własnego projektu związanego z analizą danych z wykorzystaniem różnych narzędzi.
ProjectSales odnosi się do prostej bazy danych wykorzystywanych do nauki na studiach.
Składa się ona z 3 tabel (Przedstawiciele, Sprzedaż oraz Klienci), które przedstawiają sprzedaż telefoniczną.

Początek analizy danych rozpoczął się w programie excel, gdzie dane zostały sprawdzone oraz dodane zostały nowe kolumny w celu małej rozbudowy bazy danych.

Po wgraniu tabel do serwera MS SQL zoistały wykonane podstawowe agregacje danych w celu wyciagnięcia interesujących informacji takich jak np.:
  - Wybranie 3 najlepszych sprzedawców
  - Liczba wykonanych połączeń przez sprzedawców oraz łączny czas rozmowy
  - Wydajność sprzedawców, obliczając zysk na minutę rozmowy

Kolejne agregacje będę dodawał na bieżąco.
                                                                                                                                                                                             
W najbliższym czasie będą wykonywane analizy w języku Python z użyciem JupyterNotebook, w języku R z użyciem RStudio a wizualizacja danych powstanie w programie tableau (oraz poszczególne wykresy w Pythonie i R).



-- Plik Sales_RawData zawiera dane użyte do analizy zapisane w formacie xlsx, plik Sales_Data zawiera wizualne podgląd danych --         
-- Plik SQLQuery_Sales zawiera kod sql użyty podczas agregacji danych -- 
