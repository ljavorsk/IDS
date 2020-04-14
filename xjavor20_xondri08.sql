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


INSERT INTO Zakaznik VALUES('ferko123','Fero','Novak','L.Stura 34, Zvolen', '+421949324567', 'ferko123@gmail.com');
INSERT INTO Zakaznik VALUES('xmajko22','Marian','Zeleny','Nogradyho 34, Zvolen', '+421947111209', NULL);

INSERT INTO Zamestnanec VALUES('983011/2334','Lukas','Novak','Lukova 21, Budca', '+421907311862', 'lestic', 5.5, NULL);
INSERT INTO Zamestnanec VALUES('901104/2200','Patrik','Budaj','Pod Hradom 4, Sliac', '+421909888123', 'montovac', 4, 'Glamio s.r.o');

INSERT INTO Zakazka VALUES(12, TO_DATE('17/12/2019', 'DD/MM/YYYY'), TO_DATE('21/12/2019', 'DD/MM/YYYY'), NULL, NULL, 'ferko123', '983011/2334');
INSERT INTO Zakazka VALUES(23, TO_DATE('04/03/2020', 'DD/MM/YYYY'), TO_DATE('09/03/2020', 'DD/MM/YYYY'), TO_DATE('14/03/2020', 'DD/MM/YYYY'), 3000, 'ferko123', '901104/2200');

INSERT INTO Zamestnanec_pracuje_na_zakazke VALUES(20, 23, 'ferko123', '983011/2334');

INSERT INTO Nabytok VALUES(233412, 'Staro zamocka truhla', '100x80x230');
INSERT INTO Nabytok VALUES(1234442, 'Stolicka s 3 nohami', '40x50x30');

INSERT INTO Farba VALUES('zelena');
INSERT INTO Farba VALUES('cervena');
INSERT INTO Farba VALUES('hneda');

INSERT INTO Nabytok_ma_farbu VALUES(233412, 'hneda');
INSERT INTO Nabytok_ma_farbu VALUES(1234442, 'cervena');
INSERT INTO Nabytok_ma_farbu VALUES(1234442, 'zelena');

INSERT INTO Kus VALUES(9314, 'Spracuvava sa', NULL, 233412, 12, 'ferko123');
INSERT INTO Kus VALUES(402, 'Dokoncene', NULL, 1234442, 23, 'ferko123');
INSERT INTO Kus VALUES(551, 'Dokoncene', NULL, 233412, 23, 'ferko123');


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
INSERT INTO Zamestnanec_pracuje_na_zakazke VALUES(30, 23, 'ferko123', '961105/1082');

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
INSERT INTO Zakazka VALUES(14, TO_DATE('19/12/2019', 'DD/MM/YYYY'), TO_DATE('23/12/2019', 'DD/MM/YYYY'), NULL, NULL, 'ludvik_d', '961105/1082');
INSERT INTO Zakazka VALUES(19, TO_DATE('21/12/2019', 'DD/MM/YYYY'), TO_DATE('01/01/2020', 'DD/MM/YYYY'), NULL, NULL, 'ludvik_d', '981011/2004');

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
