DROP MATERIALIZED VIEW prehlad_zakaziek_podla_datumu_vytvorenia;
DROP INDEX farba_index;
DROP PROCEDURE zakaznik_nesparvny_email;
DROP TRIGGER login_update_zakazka;
DROP TRIGGER generate_poradove_cislo;
DROP TABLE Material_doda_dodavatel;
DROP TABLE Nabytok_mozne_vyrobit_z_materialu;
DROP TABLE Kus_vyrobeny_z_materialu;
DROP TABLE Nabytok_ma_prislusenstvo;
DROP TABLE Kus_ma_prislusenstvo;
DROP TABLE Material;
DROP TABLE Dodavatel;
DROP TABLE Kus_ma_farbu;
DROP TABLE Prislusenstvo;
DROP TABLE Nabytok_ma_farbu;
DROP TABLE Kus;
DROP TABLE Nabytok;
DROP TABLE Farba;
DROP TABLE Zamestnanec_pracuje_na_zakazke;
DROP TABLE Zakazka;
DROP TABLE Zakaznik;
DROP TABLE Zamestnanec;
DROP SEQUENCE zakazka_poradove_cislo_automat;


CREATE TABLE Zakaznik (
login VARCHAR(25) PRIMARY KEY,
meno  VARCHAR(20) NOT NULL,
priezvisko VARCHAR(30) NOT NULL,
adresa VARCHAR(50) NOT NULL ,
telefonne_cislo CHAR(13) NOT NULL,
email VARCHAR(25) NULL
);

CREATE TABLE Zamestnanec (
RC CHAR(11),
meno  VARCHAR(20) NOT NULL,
priezvisko VARCHAR(30) NOT NULL,
adresa VARCHAR(50) NOT NULL ,
telefonne_cislo CHAR(13) NOT NULL,
specializacia VARCHAR(40) NOT NULL,
mzda_na_hod INTEGER NOT NULL,
nazov_externej_firmy VARCHAR(35)
);

CREATE TABLE Zakazka (
poradove_cislo INTEGER,
datum_vytvorenia DATE NOT NULL,
datum_poslednej_upravy DATE,
datum_zaplatenia DATE,
cena_faktury DECIMAL(10,2),
objednal_login VARCHAR(25),
riadi_RC CHAR(11)
);

CREATE TABLE Zamestnanec_pracuje_na_zakazke (
odpracovane_hod  INTEGER NOT NULL,
poradove_cislo INTEGER,
objednal_login VARCHAR(25),
pracuje_na_RC CHAR(11)
);

CREATE TABLE Nabytok (
ID  INTEGER,
nazov VARCHAR(100) NOT NULL,
rozmery VARCHAR(15) NOT NULL
);

CREATE TABLE Farba (
nazov VARCHAR(20)
);

CREATE TABLE Nabytok_ma_farbu (
ID_nabytku  INTEGER,
nazov_farby VARCHAR(20)
);

CREATE TABLE Kus (
ID  INTEGER,
stav VARCHAR(19) NOT NULL,
CONSTRAINT moznosti_stavu CHECK (stav IN ('Caka na spracovanie', 'Spracuvava sa', 'Dokoncene')),
datum_vyrobenia DATE,
ID_nabytku  INTEGER,
poradove_cislo INTEGER,
login VARCHAR(25)
);

CREATE TABLE Kus_ma_farbu (
ID_kusu  INTEGER,
ID_nabytku INTEGER,
nazov_farby VARCHAR(20)
);

CREATE TABLE Prislusenstvo (
ID  INTEGER,
nazov VARCHAR(50) NOT NULL,
cena DECIMAL(6,2) NOT NULL
);

CREATE TABLE Kus_ma_prislusenstvo (
ID_kusu  INTEGER,
ID_nabytku INTEGER,
ID_prislusenstva INTEGER
);

CREATE TABLE Nabytok_ma_prislusenstvo (
ID_nabytku  INTEGER,
ID_prislusenstva INTEGER
);

CREATE TABLE Material (
oznacenie  VARCHAR(20),
nazov VARCHAR(30) NOT NULL,
typ VARCHAR(15) NOT NULL
);

CREATE TABLE Nabytok_mozne_vyrobit_z_materialu (
ID_nabytku  INTEGER,
oznacenie_materialu  VARCHAR(20)
);

CREATE TABLE Kus_vyrobeny_z_materialu (
mnozstvo  VARCHAR(15) NOT NULL,
oznacenie  VARCHAR(20),
ID_kusu  INTEGER,
ID_nabytku INTEGER
);

CREATE TABLE Dodavatel (
obchodne_meno  VARCHAR(70),
fakturacna_adresa VARCHAR(50) NOT NULL,
ICO NUMBER(8,0),
CONSTRAINT ICO_check CHECK (ICO > 9999999),
DIC INTEGER,
CONSTRAINT DIC_check CHECK (length(DIC) = 10)
);

CREATE TABLE Material_doda_dodavatel (
mnozstvo  VARCHAR(8) NOT NULL,
jednotkova_cena DECIMAL(4,2) NOT NULL,
oznacenie  VARCHAR(20),
obchodne_meno  VARCHAR(70)
);

-- Triger so sequenciou, ktora automaticky naplna ID hodnotu pre zakazky
CREATE SEQUENCE zakazka_poradove_cislo_automat START WITH 1;

CREATE OR REPLACE TRIGGER generate_poradove_cislo
BEFORE INSERT ON Zakazka
FOR EACH ROW
BEGIN
    SELECT zakazka_poradove_cislo_automat.NEXTVAL
    INTO   :NEW.poradove_cislo
    FROM   DUAL;
END;
/

ALTER TABLE Zamestnanec ADD CONSTRAINT PK_Zamestnanec PRIMARY KEY (RC);
ALTER TABLE Zakazka ADD CONSTRAINT PK_Zakazka PRIMARY KEY (poradove_cislo,objednal_login);
ALTER TABLE Zakazka ADD CONSTRAINT FK_Zakazka_Zakaznik FOREIGN KEY (objednal_login) REFERENCES Zakaznik ON DELETE CASCADE;
ALTER TABLE Zakazka ADD CONSTRAINT FK_Zakazka_Zamestnanec FOREIGN KEY (riadi_RC) REFERENCES Zamestnanec;
ALTER TABLE Zamestnanec_pracuje_na_zakazke ADD CONSTRAINT FK_Zamestnanec_pracuje_na_zakazke_Zakazka FOREIGN KEY (poradove_cislo, objednal_login) REFERENCES Zakazka ON DELETE CASCADE;
ALTER TABLE Zamestnanec_pracuje_na_zakazke ADD CONSTRAINT FK_Zamestnanec_pracuje_na_zakazke_Zamestnanec FOREIGN KEY (pracuje_na_RC) REFERENCES Zamestnanec ON DELETE CASCADE;
ALTER TABLE Nabytok ADD CONSTRAINT PK_Nabytok PRIMARY KEY (ID);
ALTER TABLE Farba ADD CONSTRAINT PK_Farba PRIMARY KEY (nazov);
ALTER TABLE Nabytok_ma_farbu ADD CONSTRAINT FK_Nabytok_ma_farbu_Nabytok FOREIGN KEY (ID_nabytku) REFERENCES Nabytok ON DELETE CASCADE;
ALTER TABLE Nabytok_ma_farbu ADD CONSTRAINT FK_Nabytok_ma_farbu_Farba FOREIGN KEY (nazov_farby) REFERENCES Farba ON DELETE CASCADE;
ALTER TABLE Kus ADD CONSTRAINT PK_Kus PRIMARY KEY (ID, ID_nabytku);
ALTER TABLE Kus ADD CONSTRAINT FK_Kus_Nabytok FOREIGN KEY (ID_nabytku) REFERENCES Nabytok ON DELETE CASCADE;
ALTER TABLE Kus ADD CONSTRAINT FK_Kus_Zakazka FOREIGN KEY (poradove_cislo, login) REFERENCES Zakazka ON DELETE CASCADE;
ALTER TABLE Kus_ma_farbu ADD CONSTRAINT FK_Kus_ma_farbu_Kus FOREIGN KEY (ID_kusu, ID_nabytku) REFERENCES Kus ON DELETE CASCADE;
ALTER TABLE Kus_ma_farbu ADD CONSTRAINT FK_Kus_ma_farbu_Farba FOREIGN KEY (nazov_farby) REFERENCES Farba ON DELETE CASCADE;
ALTER TABLE Prislusenstvo ADD CONSTRAINT PK_Prislusenstvo PRIMARY KEY (ID);
ALTER TABLE Kus_ma_prislusenstvo ADD CONSTRAINT FK_Kus_ma_prislusenstvo_Kus FOREIGN KEY (ID_kusu, ID_nabytku) REFERENCES Kus ON DELETE CASCADE;
ALTER TABLE Kus_ma_prislusenstvo ADD CONSTRAINT FK_Kus_ma_prislusenstvo_Prislusenstvo FOREIGN KEY (ID_prislusenstva) REFERENCES Prislusenstvo ON DELETE CASCADE;
ALTER TABLE Nabytok_ma_prislusenstvo ADD CONSTRAINT FK_Nabytok_ma_prislusenstvo_Nabytok FOREIGN KEY (ID_nabytku) REFERENCES Nabytok ON DELETE CASCADE;
ALTER TABLE Nabytok_ma_prislusenstvo ADD CONSTRAINT FK_Nabytok_ma_prislusenstvo_Prislusenstvo FOREIGN KEY (ID_prislusenstva) REFERENCES Prislusenstvo ON DELETE CASCADE;
ALTER TABLE Material ADD CONSTRAINT PK_Material PRIMARY KEY (oznacenie);
ALTER TABLE Nabytok_mozne_vyrobit_z_materialu ADD CONSTRAINT FK_Nabytok_mozne_vyrobit_z_materialu_Nabytok FOREIGN KEY (ID_nabytku) REFERENCES Nabytok ON DELETE CASCADE;
ALTER TABLE Nabytok_mozne_vyrobit_z_materialu ADD CONSTRAINT FK_Nabytok_mozne_vyrobit_z_materialu_Material FOREIGN KEY (oznacenie_materialu) REFERENCES Material ON DELETE CASCADE;
ALTER TABLE Kus_vyrobeny_z_materialu ADD CONSTRAINT FK_Kus_vyrobeny_z_materialu_Material FOREIGN KEY (oznacenie) REFERENCES Material ON DELETE CASCADE;
ALTER TABLE Kus_vyrobeny_z_materialu ADD CONSTRAINT FK_Kus_vyrobeny_z_materialu_Kus FOREIGN KEY (ID_kusu, ID_nabytku) REFERENCES Kus ON DELETE CASCADE;
ALTER TABLE Dodavatel ADD CONSTRAINT PK_Dodavatel PRIMARY KEY (obchodne_meno);
ALTER TABLE Material_doda_dodavatel ADD CONSTRAINT FK_Material_doda_dodavatel_Material FOREIGN KEY (oznacenie) REFERENCES Material ON DELETE CASCADE;
ALTER TABLE Material_doda_dodavatel ADD CONSTRAINT FK_Material_doda_dodavatel_Dodavatel FOREIGN KEY (obchodne_meno) REFERENCES Dodavatel ON DELETE CASCADE;

---------------------------------------------------  Inserty  -----------------------------------------------------------------

INSERT INTO Zakaznik VALUES('ferko123','Fero','Novak','L.Stura 34, Zvolen', '+421949324567', 'ferko123@gmail.com');
INSERT INTO Zakaznik VALUES('xmajko22','Marian','Zeleny','Nogradyho 34, Zvolen', '+421947111209', NULL);

INSERT INTO Zamestnanec VALUES('983011/2334','Lukas','Novak','Lukova 21, Budca', '+421907311862', 'lestic', 5.5, NULL);
INSERT INTO Zamestnanec VALUES('901104/2200','Patrik','Budaj','Pod Hradom 4, Sliac', '+421909888123', 'montovac', 4, 'Glamio s.r.o');

INSERT INTO Zakazka VALUES(NULL, TO_DATE('17/12/2019', 'DD/MM/YYYY'), TO_DATE('21/12/2019', 'DD/MM/YYYY'), NULL, NULL, 'ferko123', '983011/2334');
INSERT INTO Zakazka VALUES(NULL, TO_DATE('04/03/2020', 'DD/MM/YYYY'), TO_DATE('09/03/2020', 'DD/MM/YYYY'), TO_DATE('14/03/2020', 'DD/MM/YYYY'), 3000, 'ferko123', '901104/2200');

SELECT * FROM Zakazka;
INSERT INTO Zamestnanec_pracuje_na_zakazke VALUES(20, 1, 'ferko123', '983011/2334');

INSERT INTO Nabytok VALUES(233412, 'Staro zamocka truhla', '100x80x230');
INSERT INTO Nabytok VALUES(1234442, 'Stolicka s 3 nohami', '40x50x30');
INSERT INTO Nabytok VALUES(1123, 'Stol', '100x60x200');
INSERT INTO Nabytok VALUES(986, 'Kreslo', '50x50x70');
INSERT INTO Nabytok VALUES(555, 'Skrina', '150x100x300');

INSERT INTO Farba VALUES('zelena');
INSERT INTO Farba VALUES('cervena');
INSERT INTO Farba VALUES('hneda');

INSERT INTO Nabytok_ma_farbu VALUES(233412, 'hneda');
INSERT INTO Nabytok_ma_farbu VALUES(1234442, 'hneda');
INSERT INTO Nabytok_ma_farbu VALUES(986, 'hneda');
INSERT INTO Nabytok_ma_farbu VALUES(986, 'cervena');
INSERT INTO Nabytok_ma_farbu VALUES(1123, 'hneda');
INSERT INTO Nabytok_ma_farbu VALUES(555, 'hneda');
INSERT INTO Nabytok_ma_farbu VALUES(555, 'zelena');
INSERT INTO Nabytok_ma_farbu VALUES(1234442, 'cervena');
INSERT INTO Nabytok_ma_farbu VALUES(1234442, 'zelena');

INSERT INTO Kus VALUES(9314, 'Spracuvava sa', NULL, 233412, 2, 'ferko123');
INSERT INTO Kus VALUES(402, 'Dokoncene', NULL, 1234442, 1, 'ferko123');
INSERT INTO Kus VALUES(551, 'Dokoncene', NULL, 233412, 1, 'ferko123');


INSERT INTO Kus_ma_farbu VALUES(9314, 233412, 'hneda');
INSERT INTO Kus_ma_farbu VALUES(402, 1234442, 'zelena');

INSERT INTO Prislusenstvo VALUES(111, 'zlata opierka', 23.5);

INSERT INTO Kus_ma_prislusenstvo VALUES(402, 1234442, 111);

INSERT INTO Nabytok_ma_prislusenstvo VALUES(1234442, 111);

INSERT INTO Material VALUES('N12', 'dubove drevo', 'drevo');
INSERT INTO Material VALUES('MX99', 'smrekove drevo', 'drevo');

INSERT INTO Nabytok_mozne_vyrobit_z_materialu VALUES(233412, 'N12');
INSERT INTO Nabytok_mozne_vyrobit_z_materialu VALUES(1234442, 'MX99');

INSERT INTO Kus_vyrobeny_z_materialu VALUES('4m^3kg', 'MX99', 402, 1234442);

INSERT INTO Dodavatel VALUES('DameDrevo s.r.o', 'Vratilova 22, Zvolen', 12345678, 1098234661);

INSERT INTO Material_doda_dodavatel VALUES('20m^3', 10.5, 'MX99', 'DameDrevo s.r.o');

-------------------------------------------  Selecty  ---------------------------------------------------------------

-- Skript vyberie vsetky udaje z tabulky Zakaznik a Zamestnanec
SELECT * FROM Zakaznik;
SELECT * FROM Zamestnanec;

-- Skript vypise rodne cislo zamestnanca Lukas Novak
SELECT RC FROM Zamestnanec WHERE meno = 'Lukas' AND priezvisko = 'Novak';

-- Skript vyberie len zakazky, ktore su riadene zamestnancom Lukas Novak
SELECT * FROM Zakazka WHERE riadi_RC = (SELECT RC FROM Zamestnanec WHERE meno = 'Lukas' AND priezvisko = 'Novak');

-- Skript vyberie vsetky kusy nabitku v ramci jednej zakaziek, ktore spravil uzivatel ferko123
SELECT * FROM Zakazka NATURAL JOIN Kus WHERE objednal_login = 'ferko123';

-- Skript vypise vsetky kusy ktore su stolicky
SELECT * FROM Kus JOIN Nabytok ON ID_nabytku = Nabytok.ID WHERE Nabytok.nazov = 'Stolicka s 3 nohami';

-- Skript vypise vsetky mena zamestnancov, pracujucich na zakazke cislo 23
INSERT INTO Zamestnanec VALUES('961105/1082','Marian','Podolsky','Ludovita Stura 22, Zvolen', '+421900985412', 'kontroler kvality', 9, NULL);
INSERT INTO Zamestnanec_pracuje_na_zakazke VALUES(30, 1, 'ferko123', '961105/1082');

SELECT (meno || ' ' || priezvisko) AS Meno_zamestnanca FROM Zamestnanec JOIN Zamestnanec_pracuje_na_zakazke ON RC = Zamestnanec_pracuje_na_zakazke.pracuje_na_RC
JOIN Zakazka ON Zamestnanec_pracuje_na_zakazke.poradove_cislo = Zakazka.poradove_cislo
AND Zamestnanec_pracuje_na_zakazke.objednal_login = Zakazka.objednal_login WHERE Zakazka.poradove_cislo = 23;

-- Skript vypise pocet rovnakych krstnych mien
INSERT INTO Zamestnanec VALUES('993102/2211','Lukas','Podolsky','Ludovita Stura 22, Zvolen', '+421908111007', 'kontroler kvality', 8, NULL);
SELECT COUNT(meno) AS pocet, meno FROM Zamestnanec GROUP BY meno;

-- Skript vypise aku priemernu vyplatu maju zamestnanci podla specifikacie
INSERT INTO Zamestnanec VALUES('981011/2004','Jano','Rychli','A.Nogradyho 1, Zvolen', '+420907344462', 'lestic', 3.2, NULL);
INSERT INTO Zamestnanec VALUES('980251/2020','Eva','Pekna','Namornicka 15, Banska Bystrica', '+420911344453', 'lestic', 11, 'Olestime s.r.o');
INSERT INTO Zamestnanec VALUES('910111/7734','Zdeno','Brnbalik','Stefanikova 35, Zvolen', '+420917311262', 'lestic', 5.2, NULL);
INSERT INTO Zamestnanec VALUES('751125/2290','Pista','Lojko','Murgasova 798, Filakovo', '+421919832125', 'montovac', 9, 'Monter s.r.o');

SELECT CONCAT(ROUND(AVG(mzda_na_hod), 2),'€') AS Priemerna_mzda, specializacia FROM Zamestnanec GROUP BY specializacia;

-- Skript vypise kazdeho zakaznika, ktory u nas nakupoval viac nez 1-krat a zoradi ich podla priezviska
INSERT INTO Zakaznik VALUES('ludvik_d','Ludovid','Derniarsky','Novozamocka 4, Zvolen', '+421949998292', 'dern_ludovid@seznam.cz');
INSERT INTO Zakazka VALUES(NULL, TO_DATE('19/12/2019', 'DD/MM/YYYY'), TO_DATE('23/12/2019', 'DD/MM/YYYY'), NULL, NULL, 'ludvik_d', '961105/1082');
INSERT INTO Zakazka VALUES(NULL, TO_DATE('21/12/2019', 'DD/MM/YYYY'), TO_DATE('01/01/2020', 'DD/MM/YYYY'), NULL, NULL, 'ludvik_d', '981011/2004');

SELECT * FROM Zakaznik WHERE EXISTS(
    SELECT COUNT (*) FROM Zakazka WHERE objednal_login = login HAVING COUNT (*) > 1
                                 ) ORDER BY priezvisko;

-- Skript vypise zakaznikov, ktory su zaroven nasimi zamestnancami
INSERT INTO Zakaznik VALUES('mPodolsky','Marian','Podolsky','Ludovita Stura 22, Zvolen', '+421900985412', 'marianPodol@seznam.cz');
SELECT * FROM  Zakaznik WHERE meno IN (
    SELECT meno FROM Zamestnanec
    ) AND priezvisko IN (
        SELECT priezvisko FROM Zamestnanec
    ) AND adresa IN (
        SELECT adresa FROM Zamestnanec
    );

---------------------------------------------------  Trigre  ----------------------------------------------------------

-- Triger sleduje, zmenu zakaznickeho loginu, a tuto zmenu potom aplikuje aj na cuzdi kluc loginu v tabulke Zakazka
CREATE OR REPLACE TRIGGER login_update_zakazka
AFTER UPDATE OF login ON Zakaznik
FOR EACH ROW
BEGIN
    UPDATE Zakazka SET objednal_login = :NEW.login
    WHERE objednal_login = :OLD.login;
END;
/

UPDATE Zakaznik SET login='ludvik' WHERE login='ludvik_d';


-- Triger pre automaticke generovanie poradoveho cisla pre zakazky je aj so sequence vytvoreny hore po vytvoreni vsetkych tabuliek
-- Mozme vidiet vysledok na vzostupne zoradenych poradovych cislach (primarnych klusoch) tabulky Zakazka
SELECT poradove_cislo FROM Zakazka;

-- Procedura: Pokial najde zakaznika s nespravnym emailom, vypise ho
INSERT INTO Zakaznik VALUES('test_uziv','Marek','Padly','Testova 42, Zvolen', '+421902918812', 'nespravny_email');

---------------------------------------------------  Procedury  --------------------------------------------------

CREATE OR REPLACE PROCEDURE zakaznik_nesparvny_email AS
  CURSOR zakaznici IS SELECT * FROM Zakaznik;
  pocet_nespravnych INTEGER;
  zak zakaznici%ROWTYPE;
  BEGIN
    pocet_nespravnych := 0;
    dbms_output.put_line('Osoby s nespravnym emailem:');
    OPEN zakaznici;
    LOOP
      FETCH zakaznici INTO zak;
      EXIT WHEN zakaznici%NOTFOUND;
      IF zak.email NOT LIKE '%@%.%' THEN
        dbms_output.put_line('Login: ' || zak.login);
        dbms_output.put_line('Osoba: ' ||  zak.meno || ' ' || zak.priezvisko);
        dbms_output.put_line('Email: ' || zak.email);
        pocet_nespravnych := pocet_nespravnych + 1;
      END IF;
    END LOOP;
    dbms_output.put_line('Celkem: ' || pocet_nespravnych);
    CLOSE zakaznici;
 EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20003, 'Ziadny zakaznik v databazi');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Interny error');
  END;
/

BEGIN zakaznik_nesparvny_email(); END;

SELECT RC,meno,priezvisko FROM Zamestnanec;

CREATE OR REPLACE PROCEDURE zmazat_zamestnanca (Vymazat_RC Zamestnanec.RC%TYPE) AS
  CHECK_CONSTRAINT_VIOLATED EXCEPTION;
  PRAGMA EXCEPTION_INIT(CHECK_CONSTRAINT_VIOLATED, -2292);  -- Odchytenie exception pokial ma zamestnanec priradenu zakazku
  CURSOR zamestnanec IS SELECT RC,meno,priezvisko FROM Zamestnanec;
      zam zamestnanec%ROWTYPE;
  BEGIN
    dbms_output.put_line('Mazanie zamestnanca');
    OPEN zamestnanec;
    LOOP
      FETCH zamestnanec INTO zam;
      EXIT WHEN zamestnanec%NOTFOUND;
      IF zam.RC LIKE Vymazat_RC THEN
        dbms_output.put_line('Zamestnanec sa nasiel...');
        dbms_output.put_line('Meno zamestnanca: ' ||  zam.meno || ' ' || zam.priezvisko);
        DELETE FROM Zamestnanec WHERE RC=Vymazat_RC;
      END IF;
    END LOOP;
    CLOSE zamestnanec;
    EXCEPTION
    WHEN CHECK_CONSTRAINT_VIOLATED THEN
        RAISE_APPLICATION_ERROR(-20081, 'Zamestnanec ma priradenu zakazku, neda sa odstranit');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20004, 'Interny error');
END;
/

-- Neprejde, lebo zamestnancovi je priradena zakazka
BEGIN zmazat_zamestnanca('981011/2004'); END;

-- Prejde, zamestancovi nie je nic priradene
BEGIN zmazat_zamestnanca('910111/7734'); END;

---------------------------------------------  Index a Explain plan  -----------------------------------------------------

EXPLAIN PLAN FOR
SELECT nazov_farby as Farba, count(nazov_farby) as Pocet_nabytku FROM Nabytok_ma_farbu
GROUP BY (nazov_farby)
ORDER BY count(nazov_farby) desc;

-- Bez pouzitia indexu
SELECT * FROM TABLE(dbms_xplan.display());

-- Vytvorenie indexu
CREATE INDEX farba_index ON Nabytok_ma_farbu (nazov_farby);

EXPLAIN PLAN FOR
SELECT nazov_farby as Farba, count(nazov_farby) as Pocet_nabytku FROM Nabytok_ma_farbu
GROUP BY (nazov_farby)
ORDER BY count(nazov_farby) desc;

-- S pouzitim indexu
SELECT * FROM TABLE(dbms_xplan.display());


-----------------------------------------------  Pristupova prava pre xondri08  ----------------------------------------------------

GRANT ALL ON Dodavatel TO xondri08;
GRANT ALL ON Farba TO xondri08;
GRANT ALL ON Kus TO xondri08;
GRANT ALL ON Kus_ma_farbu TO xondri08;
GRANT ALL ON Kus_ma_prislusenstvo TO xondri08;
GRANT ALL ON Kus_vyrobeny_z_materialu TO xondri08;
GRANT ALL ON Material TO xondri08;
GRANT ALL ON Material_doda_dodavatel TO xondri08;
GRANT ALL ON Nabytok TO xondri08;
GRANT ALL ON Nabytok_ma_farbu TO xondri08;
GRANT ALL ON Nabytok_ma_prislusenstvo TO xondri08;
GRANT ALL ON Nabytok_mozne_vyrobit_z_materialu TO xondri08;
GRANT ALL ON Prislusenstvo TO xondri08;
GRANT ALL ON Zakazka TO xondri08;
GRANT ALL ON Zakaznik TO xondri08;
GRANT ALL ON Zamestnanec TO xondri08;
GRANT ALL ON Zamestnanec_pracuje_na_zakazke TO xondri08;

GRANT EXECUTE ON zakaznik_nesparvny_email TO xondri08;
GRANT EXECUTE ON zmazat_zamestnanca TO xondri08;


----------------------------------------  Materializovany pohlad  --------------------------------------------

-- Zmeny v logoch tabulke Kus
CREATE MATERIALIZED VIEW LOG ON Kus WITH PRIMARY KEY, ROWID;

-- Vypis zakaziek podla vytvorenia od najnovsich
CREATE MATERIALIZED VIEW prehlad_zakaziek_podla_datumu_vytvorenia
    BUILD IMMEDIATE
    REFRESH COMPLETE
AS
SELECT * FROM Zakazka ORDER BY datum_vytvorenia desc;

GRANT ALL ON prehlad_zakaziek_podla_datumu_vytvorenia TO xjavor20;

------------------- Priklad:

-- Zobrazenie povodu
SELECT * FROM xjavor20.Zakazka;

INSERT INTO Zakazka VALUES (NULL, TO_DATE('05/02/2020', 'DD/MM/YYYY'), NULL, NULL, NULL, 'ludvik', '961105/1082');

-- Zobrazenie po inserte
SELECT * FROM xjavor20.Zakazka;

-- Aktualizacia
BEGIN DBMS_SNAPSHOT.REFRESH('prehlad_zakaziek_podla_datumu_vytvorenia','COMPLETE'); END;

-- Zobrazenie po aktualizacii
SELECT * FROM xjavor20.Zakazka;