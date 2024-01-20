# Łączenie się z bazą danych SAMPLE
db2start # Uruchom menadżera bazy danych
db2 # Wejdź w tryb interaktywny
connect to sample user <id użytkownika> # Połącz się z bazą
list tablespaces show detail # Informacje o przestrzeniach tabel
list tables # Lista tabel bazy
values current user # Aktualny użytkownik
get connection state # Stan połączenia
list applications # Kto jest podłączony do SAMPLE
values application_id # Identyfikator swojej sesji
force application (id) # Rozłącz aplikację
terminate # Wyjdź z trybu interaktywnego

# Praca z obiektami bazy danych: tabele.sh
# Wyświetlenie dostępnych baz danych i sprawdzenie połączenia
db2 list db directory

# Rozłączenie z bieżącą bazą danych, jeśli jesteśmy połączeni
db2 connect reset

# Utworzenie bazy danych testdb
db2 create database testdb

# Wyświetlenie dostępnych baz danych
db2 list db directory

# Połączenie z bazą testdb
db2 connect to testdb

# Sprawdzenie przestrzeni tabel i rozmiaru strony
db2 "select tbname, pagesize from syscat.tables"

# Utworzenie tabeli employee
db2 "create table employee (empid integer, name varchar(50), dept integer)"

# Wyświetlenie informacji o tabeli employee
db2 "describe table employee"

# Zmiana typu pola dept
db2 "alter table employee alter column dept set data type char(9)"

# Ponowne wyświetlenie informacji o tabeli employee
db2 "describe table employee"

# Dodanie wiersza do tabeli - przykładowe dane
db2 "insert into employee (empid, name, dept) values (1, 'John Doe', 'HR')"

# Dodanie kilku wierszy do tabeli employee
db2 "insert into employee (empid, name, dept) values (2, 'Jane Smith', 'IT'), (3, 'Alice Johnson', 'Finance')"

# Zmiana danych działu w jednym z wierszy
db2 "update employee set dept='Marketing' where empid=2"

# Usunięcie jednego z wierszy
db2 "delete from employee where empid=3"

# Wyświetlenie zawartości tabeli
db2 "select * from employee"

# Usunięcie całej zawartości tabeli
db2 "truncate table employee immediate"

# Ponowne wyświetlenie zawartości tabeli
db2 "select * from employee"

# Praca z obiektami bazy danych: schematy

# 1. Sprawdzenie, do jakiego schematu należy tabela employee w bazie testdb.
db2 connect to testdb
db2 "select tabschema from syscat.tables where tabname = 'EMPLOYEE'"

# 2. Odpowiedź, czy schemat był stworzony w sposób jawny czy niejawny, nie jest możliwa do wykonania bezpośrednio przy użyciu DB2.
#    Sprawdź, czy użytkownik, którego nazwa odpowiada nazwie schematu, posiadał uprawnienia do tworzenia schematów w momencie,
#    gdy powstały pierwsze obiekty w tym schemacie. Jeśli tak, jest możliwe, że schemat został utworzony niejawnie.
#    Przejrzyj historię poleceń wykonanych przez tego użytkownika, jeśli jest dostępna.
#    Jeśli znajdziesz polecenie CREATE SCHEMA, oznacza to, że schemat został utworzony jawnie.

# 3. Sprawdzenie, jakie schematy są aktualnie utworzone w bazie testdb.
db2 "select schemaname from syscat.schemata"

# 4. Utworzenie nowego schematu o nazwie myschema i tabeli department w tym schemacie.
db2 "create schema myschema authorization USER_NAME" # Zastąp USER_NAME odpowiednim identyfikatorem użytkownika.
db2 "create table myschema.department (dept char(9), dept_name varchar(30), budget numeric(9,2))"

# 5. Wyświetlenie tabel w schemacie myschema.
db2 "list tables for schema myschema"

# 6. Sprawdzenie, jakie schematy są utworzone w bazie testdb i wyświetlenie informacji o właścicielach i twórcach.
db2 "select schemaname, definer, create_time from syscat.schemata"

# 7. Utworzenie tabeli employee w schemacie myschema o tej samej strukturze, co tabela utworzona wcześniej.
db2 "create table myschema.employee (empid integer, name varchar(50), dept char(9))"

# 8. Sprawdzenie, jakie tabele.sh są w bazie testdb, uwzględniając wszystkie schematy.
db2 "select tabname, tabschema from syscat.tables"

