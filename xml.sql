--1. uruchom narzędzie linii komend i uruchom menadżera bazy danych (db2start)
--2. uruchom DataStudio i połącz się z bazą sample
--3. w tabeli CUSTOMER, sprawdź, jakiego typu są kolumny. Jak przechowywane są dane XML?

-- 4. Zapytania XQuery
-- a. Wybór wszystkich danych z kolumny INFO
xquery db2-fn:xmlcolumn("CUSTOMER.INFO");

-- b. Wybór nazwisk wszystkich klientów (element name)
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo/name return $cust;

-- c. Wybór nazwisk wszystkich klientów (tylko zawartość tekstowa)
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo/name/text() return $cust;

-- d. Wybór tylko danych klienta o id 1003
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[@Cid="1003"] return $cust;

-- e. Wybór tylko nazwisk klientów o id 1003 lub 1005 (tylko zawartość tekstowa)
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[@Cid=("1003", "1005")]/name/text() return $cust;

-- f. Wybór nazwiska i numerów telefonów klienta o id 1005 (użyć sekwencji)
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[@Cid="1005"] return ($cust/name, $cust/phone);

-- g. Wybór numerów telefonów domowych klienta o id 1005
xquery for $phone in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[@Cid="1005"]/phone[@type="home"] return $phone;

-- h. Wybór nazwisk tylko tych klientów, którzy mają asystenta
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[assistant] return $cust/name;

-- i. Wybór nazwisk wszystkich asystentów (tylko sama zawartość tekstowa)
xquery for $asst in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo/assistant/name/text() return $asst;

-- j. Wybór wszystkich nazwisk i numerów telefonów asystentów (tylko sama zawartość tekstowa)
xquery for $asst in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo/assistant return ($asst/name/text(), $asst/phone/text());

-- k. Wybór nazwiska asystenta klienta z Kanady z telefonem domowym
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[addr[@country="Canada"] and phone[@type="home"]] return $cust/assistant/name/text();

-- l. Wybór numerów telefonów klientów z Toronto
xquery for $phone in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[addr/city="Toronto"]/phone/text() return $phone;

-- m. Wybór nazwisk i numerów telefonów asystentów klientów z Toronto
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo[addr/city="Toronto"]/assistant return ($cust/name, $cust/phone);

-- 5. Użycie wyrażenia FLWOR XQuery
-- a. Zwrócenie sekwencji zawierającej nazwiska i numery telefonów klientów
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo let $name := $cust/name, $phones := $cust/phone return ($name, $phones);

-- b. Zwrócenie sekwencji zawierającej nazwiska i numery telefonów do pracy klientów
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo let $name := $cust/name, $workphone := $cust/phone[@type="work"] return ($name, $workphone);

-- c. Zwrócenie sekwencji zawierającej nazwiska klientów i informację o asystentach
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo let $name := $cust/name/text() return if ($cust/assistant) then ($name, "asystent: ", $cust/assistant/name) else $name;

-- d. Wybór nazwisk klientów z asystentami oraz nazwisk i telefonów tych asystentów
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo where $cust/assistant let $name := $cust/name, $asst := $cust/assistant return ($name, $asst/name, $asst/phone);

-- e. Wybór nazwisk wszystkich klientów i liczby ich telefonów
xquery for $cust in db2-fn:xmlcolumn("CUSTOMER.INFO")/customerinfo let $name := $cust/name, $phoneCount := count($cust/phone) return ($name, $phoneCount);

-- 6. Użycie funkcji sqlquery
-- a. Wybór tylko klienta o id 1003
xquery db2-fn:sqlquery("select INFO from customer")/customerinfo[@Cid="1003"];

-- b. Wybór tylko nazwisk klientów o id 1003 lub 1005
xquery db2-fn:sqlquery("select INFO from customer")/customerinfo[@Cid=("1003", "1005")]/name/text();

-- c. Wybór numerów telefonów klienta o id 1005
xquery db2-fn:sqlquery("select INFO from customer")/customerinfo[@Cid="1005"]/phone/text();

-- d. Wybór numerów telefonów domowych klienta o id mniejszym od 1005
xquery db2-fn:sqlquery("select INFO from customer")/customerinfo[@Cid < "1005"]/phone[@type="home"]/text();


--Zad. 2. Odczytywanie danych XML za pomocą SQL/XML
-- Zakładamy, że mamy tabelę o nazwie customers z kolumną xml_data typu XML

-- Zadanie 1: Wybranie danych klientów (nazwa, miasto, telefon domowy), uporządkowanie po nazwach miast
SELECT
    X.name,
    X.city,
    X.phone
FROM
    customers,
    XMLTABLE('$d/customerinfo[phone[@type="home"]]' PASSING customers.xml_data AS "d"
             COLUMNS
                 name VARCHAR(100) PATH 'name',
                 city VARCHAR(100) PATH 'addr/city',
                 phone VARCHAR(20) PATH 'phone[@type="home"]') AS X
ORDER BY
    X.city;

-- Zadanie 2: Wybranie danych klientów z tego samego miasta, co klient o id 1001
WITH city_subquery AS (
    SELECT
        XMLCAST(XMLQUERY('$d/customerinfo/addr/city' PASSING customers.xml_data AS "d") AS VARCHAR(100)) AS city
    FROM
        customers
    WHERE
        XMLCAST(XMLQUERY('$d/customerinfo/@Cid' PASSING customers.xml_data AS "d") AS INTEGER) = 1001
)
SELECT
    X.name,
    X.city
FROM
    customers,
    city_subquery,
    XMLTABLE('$d/customerinfo' PASSING customers.xml_data AS "d"
             COLUMNS
                 name VARCHAR(100) PATH 'name',
                 city VARCHAR(100) PATH 'addr/city') AS X
WHERE
    X.city = city_subquery.city;

-- Zadanie 3: Zadania 5 i 6 za pomocą SQL/XML (zakładamy, że wymagane są inne operacje)

-- Zadanie 4a: Zwrócenie w postaci tablicy danych: nazwa klienta, miasto, pierwszy numer telefonu
SELECT
    X.name,
    X.city,
    X.phone
FROM
    customers,
    XMLTABLE('$d/customerinfo' PASSING customers.xml_data AS "d"
             COLUMNS
                 name VARCHAR(100) PATH 'name',
                 city VARCHAR(100) PATH 'addr/city',
                 phone VARCHAR(20) PATH 'phone[1]') AS X;

-- Zadanie 4b: Zwrócenie w postaci tablicy danych: nazwa klienta, miasto, wszystkie numery telefonów
SELECT
    X.name,
    X.city,
    X.phone
FROM
    customers,
    XMLTABLE('$d/customerinfo/phone' PASSING customers.xml_data AS "d"
             COLUMNS
                 name VARCHAR(100) PATH '../name',
                 city VARCHAR(100) PATH '../addr/city',
                 phone VARCHAR(20)) AS X;


-- Zad. 3. Modyfikacja danych XML za pomocą SQL/XML
-- Połącz się z bazą TESTDB
-- db2 connect to TESTDB

-- 1. Utwórz nowy schemat LIB
CREATE SCHEMA LIB;

-- Utwórz tabelę biblioteki (za pomocą skryptu skrypt_biblioteka.sql)

-- Przejrzyj zawartość tych tabel
-- SELECT * FROM LIB.biblioteka;

-- 2. Dodaj nowego autora do tabeli AUTHOR
INSERT INTO LIB.AUTHOR (author_id, info)
VALUES (100, XMLELEMENT(NAME "authorInfo",
                        XMLELEMENT(NAME "email", 'jk@example.com'),
                        XMLELEMENT(NAME "country", 'Poland'),
                        XMLELEMENT(NAME "dob", '1980-01-01')));

-- 3. SQL/XML TRANSFORM zadań dla autora "Jan Kowalski" (przykładowe implementacje)
-- Uwaga: Wymaga odpowiedniego formatowania i adaptacji do rzeczywistej struktury XML w tabeli AUTHOR

-- a. Dodaj kolejny email
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do insert XMLELEMENT(NAME "email", "newemail@example.com")
                        into ($c/authorInfo)[1]
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- b. Usuń wszystkie węzły email
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do delete $c/authorInfo/email
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- c. Dodaj nowy węzeł contact z atrybutem type='phone'
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do insert XMLELEMENT(NAME "contact", XMLATTRIBUTES('phone' as "type"), '12345')
                        into ($c/authorInfo)[1]
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;
-- d. Dodaj kolejny węzeł contact, z atrybutem type='mail', z wartością jk@gg.com
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do insert XMLELEMENT(NAME "contact", XMLATTRIBUTES('mail' as "type"), "jk@gg.com")
                        into ($c/authorInfo)[1]
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- e. Zmień nazwę pierwszego węzła contact na phone
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do rename $c/authorInfo/contact[1] as "phone"
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- f. Usuń atrybut type z węzła contact
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do replace value of $c/authorInfo/contact/@type with ""
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- g. Zmień wartość atrybutu type w węźle phone na work
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do replace value of $c/authorInfo/phone/@type with "work"
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- h. Dodaj nowy element addr, który będzie zawierał dwa elementy potomne: city i street
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do insert XMLELEMENT(NAME "addr",
                                             XMLELEMENT(NAME "city", "Szczecin"),
                                             XMLELEMENT(NAME "street", "Nowa"))
                        into ($c/authorInfo)[1]
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- i. Dodaj do elementu addr kolejne dziecko country, jako pierwsze z dzieci, z wartością Polska
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do insert XMLELEMENT(NAME "country", "Polska")
                        as first into ($c/authorInfo/addr)[1]
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- j. Dodaj kolejny węzeł phone (z atrybutem type=home), po już istniejącym węźle phone
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do insert XMLELEMENT(NAME "phone", XMLATTRIBUTES('home' as "type"), "123-456-7890")
                        after ($c/authorInfo/phone)[1]
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- k. Zmień nazwy wszystkich węzłów phone na contact_phone
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do rename $c/authorInfo/phone as "contact_phone"
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- l. Usuń węzeł addr (wraz z zawartością)
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do delete $c/authorInfo/addr
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;

-- m. Dodaj do wszystkich węzłów phone nowy atrybut public=yes
UPDATE LIB.AUTHOR
SET info = XMLQUERY('transform copy $c := $INFO modify
                        do replace $c/authorInfo/phone with
                           XMLELEMENT(NAME "phone", XMLATTRIBUTES("yes" as "public"), $c/authorInfo/phone/text())
                        return $c'
                    passing info as "INFO")
WHERE author_id = 100;
