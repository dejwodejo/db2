db2start

# 3. Odczytanie parametrów konfiguracyjnych bazy TESTDB
db2 "get db cfg for testdb"

# 4. Połączenie z bazą TESTDB i wyświetlenie listy tabel
db2 connect to TESTDB
db2 "list tables"

# 5. Utworzenie tabeli pracownik w bazie TESTDB
db2 "drop table if exists pracownik"
db2 "create table pracownik (ID int not null primary key, Nazwisko varchar(15), Zarobki decimal(10,2))"
db2 "insert into pracownik values (1, 'Kowalski', 30000), (2, 'Nowak', 40000)"

# 6. Utworzenie katalogu backups na dysku C (musi być wykonane poza skryptem DB2)

# 7. Wykonanie pełnego backupu bazy TESTDB
db2 "force applications all" # To może być konieczne do zamknięcia wszystkich aktywnych połączeń
db2 "backup db testdb to /backups" # Uwaga: uaktualnij ścieżkę dostępu do katalogu zgodnie z systemem operacyjnym
db2 "list history backup all for db testdb"

# 8. Sprawdzenie, czy połączenie z bazą nadal jest aktywne
db2 "connect to TESTDB"

# 9. Dodanie kolejnych dwóch wierszy do tabeli pracownik
db2 "insert into pracownik values (3, 'Wiśniewski', 50000), (4, 'Lewandowski', 60000)"

# 10. Usunięcie bazy TESTDB
db2 "drop database testdb"

# 11. Odtworzenie bazy TESTDB z kopii zapasowej
# Uwaga: Wartość t1 należy zastąpić rzeczywistym znacznikiem czasu zapisanym po wykonaniu backupu
# db2 "restore db testdb from /backups taken at t1"

# 12. Połączenie z bazą TESTDB i wyświetlenie zawartości tabeli pracownik
db2 connect to TESTDB
db2 "select * from pracownik"


# Zad. 2. Odtwarzanie bazy po awarii z backupu i plików dziennika
# 1. Utworzenie katalogu logarch na dysku C (musi być wykonane poza skryptem DB2)

# 2. Zmiana parametrów konfiguracyjnych bazy testdb
db2start
db2 "update db cfg for testdb using LOGARCHMETH1 disk:/logarch"

# 3. Połączenie z bazą testdb (będzie wymagało wykonania pełnego backupu)
db2 connect to TESTDB

# Wykonanie pełnego backupu bazy TESTDB
db2 "backup db testdb to /backups" # Uwaga: Zaktualizuj ścieżkę zgodnie z systemem operacyjnym
db2 "list history backup all for db testdb"

# 4. Dodanie wierszy do tabeli employee
db2 "insert into employee values (3, 'Wiśniewski', 50000), (4, 'Lewandowski', 60000)"

# 5. Rozłączenie się z bazą testdb i usunięcie bazy
db2 connect reset
db2 "drop database testdb"

# 6. Odtworzenie bazy testdb z backupu
# Uwaga: Wartość t2 należy zastąpić rzeczywistym znacznikiem czasu zapisanym po wykonaniu backupu
db2 "restore db testdb from /backups taken at t2"

# 7. Odtworzenie danych z dziennika
db2 "rollforward db testdb to end of logs and complete"

# 8. Połączenie z bazą testdb i sprawdzenie zawartości tabeli employee
db2 connect to TESTDB
db2 "select * from employee"

# 9. Odczytanie czasu systemowego t3 i usunięcie ostatnich trzech wierszy z tabeli employee
# Uwaga: Czas t3 należy ustawić ręcznie w odpowiednim formacie yyyy-mm-dd-hh.mm.ss
db2 "delete from employee where ID in (3, 4, 5)"

# 10. Odtworzenie bazy z backupu do określonego momentu czasowego
db2 "restore db testdb from /backups taken at t2"
db2 "rollforward db testdb to 't3' using local time and stop"

# Ponowne połączenie z bazą testdb i sprawdzenie zawartości tabeli employee
db2 connect to TESTDB
db2 "select * from employee"


# Zad. 3. Wykonywanie backupu przyrostowego
# 1. Zmiana parametru konfiguracyjnego TRACKMOD dla bazy testdb
db2 "update db cfg for testdb using TRACKMOD ON"

# 2. Ponowne połączenie z bazą danych testdb
db2 connect reset
db2 connect to TESTDB

# 3. Wykonanie pełnego backupu bazy danych w trybie online
db2 "backup db testdb online to /backups" # Zmień ścieżkę zgodnie z systemem operacyjnym
db2 "list history backup all for db testdb" # Użyj tej komendy, aby znaleźć czas wykonania backupu (t4)

# 4. Zmiana zarobków wszystkich pracowników
db2 "update pracownik set Zarobki = 3000"

# 5. Wykonanie backupu przyrostowego
db2 "backup db testdb incremental to /backups" # Ponownie, zmień ścieżkę zgodnie z systemem operacyjnym
db2 "list history backup all for db testdb" # Użyj tej komendy, aby znaleźć czas wykonania backupu (t5)

# 6. Odtworzenie bazy danych z backupu przyrostowego
db2 "restore db testdb incremental automatic from /backups taken at t5"

# 7. Wykonanie pełnego backupu bazy danych
db2 "backup db testdb online to /backups"

# 8. Wykonanie kolejnych zmian i backupów przyrostowych typu delta
# Zmiana danych w bazie
db2 "update pracownik set Zarobki = 3500"

# Pierwszy backup przyrostowy typu delta
db2 "backup db testdb incremental delta to /backups"
db2 "list history backup all for db testdb" # Odczytanie czasu wykonania pierwszego backupu przyrostowego

# Druga zmiana danych w bazie
db2 "update pracownik set Zarobki = 4000"

# Drugi backup przyrostowy typu delta
db2 "backup db testdb incremental delta to /backups"
db2 "list history backup all for db testdb" # Odczytanie czasu wykonania drugiego backupu przyrostowego

# Odtworzenie bazy danych z obu backupów przyrostowych typu delta
db2 "restore db testdb incremental automatic from /backups taken at t5" # Uwaga: zastąp t5 odpowiednim czasem
