# Tworzenie tabel, używanie DEFAULT i automatyczne generowanie wartości

# 1. Uruchomienie narzędzia linii komend DB2 CLI jest już częścią używania tego skryptu.

# 2. Uruchomienie menadżera bazy danych
db2start

# 3. Połączenie z bazą danych testdb jako aktualnie zalogowany użytkownik
db2 connect to testdb

# 4. Wyświetlenie listy tabel bazy SAMPLE
db2 "list tables"

# 5. Usunięcie tabeli employee, jeśli istnieje
db2 "drop table employee"

# 6. Tworzenie pliku skrypt.sql - najlepiej poza konsola
EOF > skrypt.sql
create table employee (
  ID SMALLINT NOT NULL,
  NAME VARCHAR(9),
  DEPT SMALLINT NOT NULL WITH DEFAULT 10,
  JOB CHAR(5),
  YEARS SMALLINT,
  SALARY DECIMAL(7,2)
);
EOF

# 7. Wczytanie skryptu - przykładowa ścieżka dostępu
db2 -tvf /path/to/skrypt.sql

# 8. Dodanie trzech wierszy do tabeli employee bez podawania wartości dla DEPT
db2
insert into employee (ID, NAME, JOB, YEARS, SALARY) values (1, 'John', 'Clerk', 3, 30000);
insert into employee (ID, NAME, JOB, YEARS, SALARY) values (2, 'Jane', 'Sales', 2, 40000);
insert into employee (ID, NAME, JOB, YEARS, SALARY) values (3, 'Doe', 'Manager', 5, 50000);
insert into employee (ID, NAME, DEPT, JOB, YEARS, SALARY) values (4, 'Smith', 20, 'Exec', 10, 60000);

# 9. Dodanie kolejnego wiersza, podając wartość dla DEPT
insert into employee (ID, NAME, DEPT, JOB, YEARS, SALARY) values (4, 'Name4', 20, 'Job4', 40, 80000)

# 10. Wyświetlenie zawartości tabeli employee
select * from employee;
exit;

# 11. Usunięcie tabeli employee
db2 "drop table employee"

# 12. Tabela z IDENTITY
EOF > skrypt.sql
create table employee (
  ID SMALLINT NOT NULL GENERATED ALWAYS AS IDENTITY (START WITH 1, INCREMENT BY 1),
  NAME VARCHAR(9),
  DEPT SMALLINT NOT NULL WITH DEFAULT 10,
  JOB CHAR(5),
  YEARS SMALLINT,
  SALARY DECIMAL(7,2)
);
EOF;
db -tvf path/to/skrypt.sql

# 13. Dodanie wierszy do tabeli interaktywnie
db2
insert into employee (NAME, JOB, YEARS, SALARY) values ('Alice', 'Clerk', 3, 30000);
insert into employee (NAME, JOB, YEARS, SALARY) values ('Bob', 'Sales', 2, 40000);

# 14. wyświetl zawartość tabeli employee - jakie db2 nadał wartości ID
select * from employee;
exit;

# 15. Wyłączenie opcji autocommit
db2 "update command options using c off"

# 16. Dodanie i wycofanie transakcji
db2 "insert into employee (NAME, JOB, YEARS, SALARY) values ('Carol', 'Manager', 5, 50000)"
db2 "rollback"

# 17. Dodanie i zatwierdzenie transakcji
db2 "insert into employee (NAME, JOB, YEARS, SALARY) values ('Dave', 'Exec', 10, 60000)"
db2 "commit"

# 18. Wyświetlenie zawartości tabeli employee - jakie db2 nadał wartości ID
db2 "select * from employee"

# 19. Usunięcie tabeli employee
db2 "drop table employee"

# 20. utwórz tabelę employee, jak w punkcie 6, ale pole ID utwórz jako IDENTITY, o
      #automatycznie generowanych wartościach, zaczynając od 11, o maksymalnej wartości 15
      #(MAXVALUE) z opcją CYCLE
EOF > skrypt.sql
create table employee (
  ID SMALLINT NOT NULL GENERATED BY DEFAULT AS IDENTITY (START WITH 11, INCREMENT BY 1, MAXVALUE 15, CYCLE),
  NAME VARCHAR(9),
  DEPT SMALLINT NOT NULL WITH DEFAULT 10,
  JOB CHAR(5),
  YEARS SMALLINT,
  SALARY DECIMAL(7,2)
);
EOF
db2 -tvf skrypt.sql

# 21. Dodanie 5 wierszy do tabeli employee i obserwacja generowania ID
db2
insert into employee (NAME, JOB, YEARS, SALARY) values ('Alice', 'Clerk', 3, 30000)
insert into employee (NAME, JOB, YEARS, SALARY) values ('Bob', 'Sales', 2, 40000)
insert into employee (NAME, JOB, YEARS, SALARY) values ('Carol', 'Manager', 5, 50000)
insert into employee (NAME, JOB, YEARS, SALARY) values ('Dave', 'Exec', 10, 60000)
insert into employee (NAME, JOB, YEARS, SALARY) values ('Eve', 'Admin', 1, 20000)
select * from employee;

# 22. Dodanie kolejnych dwóch wierszy i obserwacja ID
insert into employee (NAME, JOB, YEARS, SALARY) values ('Frank', 'Tech', 4, 35000)
insert into employee (NAME, JOB, YEARS, SALARY) values ('Grace', 'HR', 6, 45000)
select * from employee
exit;

# 23. Usunięcie tabeli employee
db2 "drop table employee"

# 24. Utworzenie tabeli sales
cat << EOF > skrypt.sql
create table sales (
  NR int not null,
  VALUE decimal(6,2),
  DISCOUNT decimal(4,2),
  NETTO GENERATED ALWAYS AS (VALUE - DISCOUNT)
);
EOF
db2 -tvf path/to/skrypt.sql

# 25. Dodanie kilku wierszy do tabeli sales
db2 "insert into sales (NR, VALUE, DISCOUNT) values (1, 100.00, 5.00)"
db2 "insert into sales (NR, VALUE, DISCOUNT) values (2, 200.00, 10.00)"
db2 "insert into sales (NR, VALUE, DISCOUNT) values (3, 300.00, 15.00)"

# 26. Wyświetlenie zawartości tabeli sales
db2 "select * from sales"

# 27. Usunięcie tabeli sales i rozłączenie się z bazą danych
db2 "drop table sales"
db2 connect reset


# Podłączenie się do bazy testdb
db2 connect to testdb

# Utworzenie tabeli dzial
db2 "create table dzial (
  NR int not null primary key,
  Nazwa char(10),
  Budzet decimal(8,2)
)"

# Utworzenie tabeli pracownik
db2 "create table pracownik (
  ID int not null primary key,
  Nazwisko varchar(15),
  Zarobki decimal(7,2),
  Nr_dzialu int
)"



# Zad. 2 Ograniczenia tabel
# Nałożenie ograniczenia klucza obcego na pole Nr_dzialu
db2 "alter table pracownik add constraint fk_nr_dzialu foreign key (Nr_dzialu) references dzial (NR) on delete cascade"

# Dodanie działu IT
db2 "insert into dzial (NR, Nazwa, Budzet) values (1, 'IT', 3000)"

# Dodanie trzech pracowników działu IT
db2 "insert into pracownik (ID, Nazwisko, Zarobki, Nr_dzialu) values (1, 'Kowalski', 4500, 1)"
db2 "insert into pracownik (ID, Nazwisko, Zarobki, Nr_dzialu) values (2, 'Nowak', 5000, 1)"
db2 "insert into pracownik (ID, Nazwisko, Zarobki, Nr_dzialu) values (3, 'Wiśniewski', 5500, 1)"

# Próba dodania pracownika działu Marketing - bez wcześniejszego dodania działu
db2 "insert into pracownik (ID, Nazwisko, Zarobki, Nr_dzialu) values (4, 'Marek', 4000, 2)"

# Dodanie działu Marketing
db2 "insert into dzial (NR, Nazwa, Budzet) values (2, 'Marketing', 2000)"

# Dodanie pracownika działu Marketing
db2 "insert into pracownik (ID, Nazwisko, Zarobki, Nr_dzialu) values (5, 'Jankowski', 4000, 2)"

# Usunięcie działu IT
db2 "delete from dzial where NR = 1"

# Nałożenie ograniczenia CHECK na pole budzet w tabeli dzial
db2 "alter table dzial add constraint check_budzet check (Budzet between 0 and 9000)"

# Dodanie do tabeli dzial działu zarząd o budżecie 12000
db2 "insert into dzial (NR, Nazwa, Budzet) values (3, 'Zarzad', 12000)"
