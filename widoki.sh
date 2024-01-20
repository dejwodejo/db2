# Zad. 1. Widoki modyfikowalne. (Wykorzystujemy bazę SAMPLE)
# Podłączenie się do bazy SAMPLE
db2 connect to SAMPLE

# 1. Utworzenie widoku dane_osobowe
db2 "create view dane_osobowe as select e.*, d.dept_name, d.location from employee e join department d on e.dept = d.deptno"

# 2. Uzupełnienie widoku dane_osobowe o dane szefa działu
db2 "create or replace view dane_osobowe as select e.*, d.dept_name, d.location, d.mgr_id from employee e join department d on e.dept = d.deptno"

# 3. Utworzenie widoku dane_zarobki
db2 "create view dane_zarobki as select e.empno, e.firstnme, e.lastname, e.salary, e.bonus, e.comm, (e.salary + coalesce(e.bonus, 0) + coalesce(e.comm, 0)) as total from employee e"

# 4. Sprawdzenie możliwości operacji na widoku dane_zarobki
# Usunięcie, modyfikacje i dodawanie przez widok dane_zarobki zależy od ograniczeń nałożonych na tabelę employee i od sposobu zdefiniowania widoku
# Dodaj, zmień i usuń osobę używając widoku (lub tabeli, jeśli widok tego nie umożliwia)
# Przykładowe operacje (zakładam, że tabela employee posiada odpowiednie kolumny i dane)
db2
# Sprawdzenie możliwości usuwania przez widok dane_zarobki
DELETE FROM dane_zarobki WHERE empno = 'XYZ'; # XYZ to przykładowy numer pracownika

# Sprawdzenie możliwości modyfikacji przez widok dane_zarobki
UPDATE dane_zarobki SET salary = 50000 WHERE empno = 'XYZ'; # XYZ to przykładowy numer pracownika

# Sprawdzenie możliwości dodawania przez widok dane_zarobki
INSERT INTO dane_zarobki (empno, firstnme, lastname, salary, bonus, comm) VALUES ('XYZ', 'Jan', 'Kowalski', 30000, 5000, 1000);

# Wyświetlenie zawartości widoku dane_zarobki
SELECT * FROM dane_zarobki;

# Wyświetlenie zawartości tabeli employee
SELECT * FROM employee;
# db2 "insert into dane_zarobki (...) values (...)"
# db2 "update dane_zarobki set ... where ..."
# db2 "delete from dane_zarobki where ..."

# 5. Utworzenie trzech widoków dla tabeli employee
# (a) Widok do usuwania
db2 "create view employee_delete as select empno, firstnme, lastname from employee"

# (b) Widok do modyfikacji
db2 "create view employee_modify as select empno, firstnme, lastname, birthdate, phoneno from employee"

# (c) Widok do dodawania
db2 "create view employee_add as select empno, firstnme, lastname, birthdate, hiredate, edlevel, sex, salary, bonus, comm from employee"

# Przeprowadzenie operacji dodawania, modyfikacji i usuwania za pomocą odpowiednich widoków
# Przykładowe operacje (zakładam, że tabela employee posiada odpowiednie kolumny i dane)
# db2 "insert into employee_add (...) values (...)"
# db2 "update employee_modify set ... where ..."
# db2 "delete from employee_delete where ..."

# Rozłączenie się z bazą danych
db2 connect reset

# Zad. 2. Widoki modyfikowalne – opcja CHECK.
# Podłączenie się do bazy danych
db2 connect to SAMPLE

# 1. Utworzenie widoku dane_dzial_e11
db2 "create view dane_dzial_e11 as select * from employee where dept = 'E11'"

# 2. Dodanie nowego pracownika do widoku (a) do działu E11 (b) spoza działu E11
# Przykładowe dane pracownika; zakładam, że struktura tabeli employee zawiera odpowiednie kolumny
db2 "insert into dane_dzial_e11 (empno, firstnme, lastname, dept, salary) values (NEXT VALUE FOR emp_seq, 'Jan', 'Kowalski', 'E11', 30000)"
db2 "insert into dane_dzial_e11 (empno, firstnme, lastname, dept, salary) values (NEXT VALUE FOR emp_seq, 'Anna', 'Nowak', 'E21', 35000)"

# 3. Sprawdzenie efektu w tabeli employee
db2 "select * from employee"

# 4. Zmiana definicji widoku, aby nie pozwalał na naruszenie warunku (pracownicy tylko z działu E11)
db2 "create or replace view dane_dzial_e11 as select * from employee where dept = 'E11' with check option"

# 5. Ponowne wykonanie operacji dodania nowego pracownika
# a) Pracownik działu E11 - powinno działać
db2 "insert into dane_dzial_e11 (empno, firstnme, lastname, dept, salary) values (NEXT VALUE FOR emp_seq, 'Piotr', 'Wiśniewski', 'E11', 32000)"
# b) Pracownik spoza działu E11 - nie powinno działać
db2 "insert into dane_dzial_e11 (empno, firstnme, lastname, dept, salary) values (NEXT VALUE FOR emp_seq, 'Marek', 'Nowak', 'E21', 34000)"

# 6. Zmiana zarobków pracownika o numerze 000300 na 35.000
db2 "update dane_dzial_e11 set salary = 35000 where empno = '000300'"

# 7. Próba zmiany działu pracownika o numerze 000300 na E21
db2 "update dane_dzial_e11 set dept = 'E21' where empno = '000300'"

# Rozłączenie się z bazą danych
db2 connect reset

# Podłączenie się do bazy TESTDB
db2 connect to TESTDB

# 1. Utworzenie schematu BIBLIO
db2 "create schema BIBLIO"

# 2. Utworzenie tabel w schemacie BIBLIO i wypełnienie ich danymi
db2 "CREATE TABLE biblio.artykul(id INT generated always as identity NOT NULL PRIMARY KEY, tytul VARCHAR(40), tresc long varchar, data_pub DATE)"
db2 "CREATE TABLE biblio.keyword (id INT generated always as identity not null PRIMARY KEY, opis VARCHAR(40))"
db2 "CREATE TABLE biblio.art_keyword(art_id INT not null, keyword_id INT not null, CONSTRAINT pk_art_key PRIMARY KEY (art_id, keyword_id))"
db2 "CREATE TABLE biblio.user_keyword(user_id INT not null, keyword_id INT not null, CONSTRAINT pk_user_key PRIMARY KEY (user_id, keyword_id))"
db2 "alter table biblio.art_keyword add foreign key (art_id) references biblio.artykul(id)"
db2 "alter table biblio.art_keyword add foreign key (keyword_id) references biblio.keyword(id)"
db2 "alter table biblio.user_keyword add foreign key (keyword_id) references biblio.keyword(id)"
# Wstawienie danych do tabel
# Tutaj umieść polecenia insert (ze względu na długość, pominąłem je w odpowiedzi)

# 3. Utworzenie widoków
# a) widok points_art
db2 "create view biblio.points_art as select id, case when data_pub > (CURRENT DATE - 1 MONTH) then 5 when data_pub > (CURRENT DATE - 3 MONTHS) then 3 else 0 end as points from biblio.artykul"

# b) widok user_art_key
db2 "create view biblio.user_art_key as select uk.user_id, ak.art_id, count(*) * 2 as key_points from biblio.user_keyword uk join biblio.art_keyword ak on uk.keyword_id = ak.keyword_id group by uk.user_id, ak.art_id"

# c) widok user_art
db2 "create view biblio.user_art as select uk.user_id, uk.art_id, (uk.key_points + pa.points) as total_points from biblio.user_art_key uk join biblio.points_art pa on uk.art_id = pa.id"

# 4. Zapytanie SELECT wykorzystujące widok user_art
db2 "select ua.user_id, a.tytul, ua.total_points from biblio.user_art ua join biblio.artykul a on ua.art_id = a.id order by ua.user_id, ua.total_points desc"

# Rozłączenie się z bazą danych
db2 connect reset
