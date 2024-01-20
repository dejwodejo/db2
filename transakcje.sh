# 2. Uruchomienie menadżera bazy danych
db2start

# 3. Połączenie z bazą TESTDB jako aktualnie zalogowany użytkownik systemu i wejście w tryb interaktywny
db2 connect to TESTDB

# 4. Wyświetlenie listy tabel bazy TESTDB
db2 "list tables"

# 5. Usunięcie tabeli test, jeśli istnieje, i utworzenie jej na nowo
db2 "drop table test"
db2 "create table test (kol integer)"

# 6. Dodanie 10 wierszy do tabeli test
db2 "insert into test select 1 from syscat.tables fetch first 10 rows only"

# 7. Odczytanie zawartości tabeli test
db2 "select * from test"

# 8. Rozłączenie się z TESTDB
db2 connect reset

# Zad. 1. Poziomy izolacji Repeatable Read i Read Stability
# W oknie A
db2 "update command options using c off" # Wyłączenie auto-commit
db2 connect to TESTDB                   # Połączenie z TESTDB
db2 "set current isolation rr"          # Ustawienie izolacji na Repeatable Read

# W oknie A
db2 "select * from test where kol=1"     # Wykonanie zapytania

# W oknie B
db2 connect to TESTDB                   # Połączenie z TESTDB
db2 "insert into test values (1)"       # Wstawienie wiersza do tabeli test

# W oknie A
db2 "commit"                            # Zatwierdzenie transakcji

# W oknie A
db2 connect reset                       # Zamknięcie połączenia z bazą

# W oknie A
db2 connect to TESTDB                   # Ponowne połączenie z TESTDB
db2 "set current isolation rs"          # Zmiana izolacji na Read Stability

# W oknie A
db2 "select * from test where kol=1"     # Wykonanie zapytania

# W oknie B
db2 "insert into test values (1)"       # Wstawienie kolejnego wiersza do tabeli test

# W oknie A
db2 "select * from test where kol=1"     # Ponowne odczytanie danych

# W oknie A
db2 "commit"                            # Zatwierdzenie transakcji

# W oknie A i B
db2 connect reset                       # Zamknięcie połączenia z bazą


#Zad. 2. Poziom izolacji CURSOR STABILITY i opcja READ COMMITTED
# 1. Sprawdzenie wartości parametru konfiguracyjnego cur_commit dla bazy TESTDB
db2 "get db cfg for testdb"

# 2. Wyłączenie opcji cur_commit
db2 "update db cfg for testdb using cur_commit disabled"

# W oknie A
db2 connect to TESTDB                           # 4. Połączenie z bazą TESTDB
db2 "update command options using c off"        # 3. Wyłączenie auto-commit
db2 "select * from test"                        # Odczytanie zawartości tabeli test

# W oknie B
db2 connect to TESTDB                           # 5. Połączenie z TESTDB

# W oknie A
db2 "update test set kol=10"                    # 6. Wykonanie polecenia update

# W oknie B
db2 "select * from test"                        # 7. Wybór wszystkich wierszy z tabeli test

# W oknie A
db2 "commit"                                    # 8. Zakończenie transakcji poleceniem COMMIT

# W oknie A i B
db2 connect reset                               # 9. Rozłączenie się z bazą TESTDB

# 10. Włączenie ponownie opcji cur_commit
db2 "update db cfg for testdb using cur_commit on"

# W oknie A i B
db2 connect to TESTDB                           # 11. Ponowne połączenie z TESTDB

# W oknie A
db2 "update test set kol=20"                    # 12. Wykonanie polecenia update

# W oknie B
db2 "select * from test"                        # 13. Odczytanie wierszy z tabeli test

# W oknie A
db2 "commit"                                    # 14. Zakończenie transakcji

# W oknie B
db2 "select * from test"                        # Ponowne odczytanie danych z tabeli test

# W oknie A i B
db2 connect reset                               # 15. Zamknięcie połączenia z bazą

# Poziom Uncommitted Read (UR)
# W oknie A
db2 "set current isolation rr"          # 1. Ustawienie izolacji na Repeatable Read
db2 connect to TESTDB                   # 2. Połączenie z TESTDB
db2 "update command options using c off" # Wyłączenie auto-commit

# W oknie A
db2 "update test set kol=30"            # 3. Wykonanie polecenia update

# W oknie B
db2 connect to TESTDB                   # 2. Połączenie z TESTDB
db2 "select * from test"                # 4. Odczytanie wierszy z tabeli test

# W oknie A
db2 "commit"                            # 5. Zakończenie transakcji

# W oknie B
db2 connect reset                       # 6. Rozłączenie się z bazą

# W oknie B
db2 "set current isolation ur"          # 7. Zmiana izolacji na Uncommitted Read
db2 connect to TESTDB                   # 8. Ponowne połączenie z TESTDB

# W oknie A
db2 "update test set kol=40"            # 9. Wykonanie polecenia update

# W oknie B
db2 "select * from test"                # 10. Odczytanie wierszy z tabeli test

# W oknie A
db2 "commit"                            # 11. Zatwierdzenie transakcji

# W oknie B
db2 "select * from test"                # 12. Ponowne odczytanie danych z tabeli test

# W oknie A
db2 "update test set kol=99"            # 13. Wykonanie kolejnego polecenia update

# W oknie B
db2 "select * from test"                # 14. Odczytanie danych z tabeli test

# W oknie A
db2 "rollback"                          # 15. Wycofanie transakcji

# W oknie B
db2 "select * from test"                # 16. Ponowne odczytanie danych z tabeli test

# W oknie A i B
db2 connect reset                       # 17. Zamknięcie połączenia z bazą
