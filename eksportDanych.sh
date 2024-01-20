# Zad. 1. Narzędzia eksportu i importu danych
# 2. Uruchomienie menadżera bazy danych
db2start

# 3. Uruchomienie IBM Data Studio (musi być wykonane poza skryptem DB2)

# 4. Połączenie z bazą SAMPLE
db2 connect to SAMPLE

# 5. Utworzenie nowego schematu "kopia"
db2 "create schema kopia"

# 6. Utworzenie tabeli "empcopy" w schemacie "kopia" o takiej samej strukturze jak "employee"
db2 "create table kopia.empcopy like employee"

# 7. Sprawdzenie struktury tabeli "empcopy"
db2 "describe table kopia.empcopy"

# 8. Zdefiniowanie klucza głównego dla "empcopy" na polu "empno"
db2 "alter table kopia.empcopy add primary key (empno)"

# Operacje eksportu/importu danych (punkty 9-16) wymagają ręcznych działań w Data Studio lub z użyciem narzędzi komend DB2

# 17. Sprawdzenie, jak dane zostały zaimportowane
db2 "select * from kopia.empcopy"

# Operacje eksportu/importu danych do/z arkusza kalkulacyjnego (punkty 18-20) wymagają ręcznych działań poza DB2


# Zad.2. Konfigurowanie automatycznej konserwacji
# data studio part
