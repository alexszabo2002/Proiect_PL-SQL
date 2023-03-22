--Comenzi SQL executate pe tabelele create
------------------------------------------

--Modificarea tipului de contributie sub o alta denumire
update contributii_proiect
set tip_contributie = 'donatie' 
where tip_contributie = 'donatie in lei';

--Cresterea salariului pentru salariatii angajati mai devreme de 01.02.2021
update angajati_proiect
set salariu = salariu + 100
where data_angajare < to_date('01-02-2021', 'dd-mm-yyyy');

--Inserarea si stergerea unui nou proiect in tabela PROIECTE
select * from proiecte_proiect;
insert into proiecte_proiect values (4, 'Amenajare Scena', 'Amenajam scena pentru un posibil eveniment din viitor.', 'intern');
select * from proiecte_proiect;
delete from proiecte_proiect
where denumire_proiect = 'Amenajare Scena';
select * from proiecte_proiect;

--Afisarea managerilor de departamente din tabela ANGAJATI
select * from angajati_proiect 
where id_functie like '%MAN';

--Afisarea angajatilor cu prenumele Andrei
select id_angajat, nume, prenume, id_functie
from angajati_proiect
where prenume = 'Andrei';

--Afisare informatii despre angajati si departamentul din care fac parte pe baza id-ului 
select a.id_angajat, a.nume, a.prenume, a.id_departament, d.denumire_departament
from angajati_proiect a, departamente_proiect d
where a.id_departament = d.id_departament
and a.nume like 'M%';

--Completarea inregistrarilor din tabela PARTICIPANTI_POSIBILI cu inregistrari din tabela PARTICIPANTI folosind comanda MERGE
merge into participanti_posibili po
using participanti_proiect pr
on (po.id_participant = pr.id_participant)
when not matched then
    insert (po.id_participant, po.nume_participant, po.prenume_participant, po.email_participant, po.data_nastere_participant)
    values (pr.id_participant, pr.nume_participant, pr.prenume_participant, 
    pr.email_participant, pr.data_nastere_participant)
when matched then
    update set po.email_participant = pr.email_participant;
    
--Afisarea angajatilor din alte departamente care au salariul mai mic decat salariul maxim din departamentul IT
select id_angajat, nume, prenume, id_functie, salariu 
from angajati_proiect
where salariu < any (select salariu from angajati_proiect where id_functie like '%IT%')
and id_functie <> 'IT_MAN' and id_functie <> 'IT_ANG'
order by salariu desc;

--Afisarea angajatilor care au salariul mai mic decat toate salariile din departamentul IP
select id_angajat, nume, prenume, id_functie, salariu 
from angajati_proiect
where salariu < all (select salariu from angajati_proiect where id_functie like '%IP%')
order by salariu desc;

--Exemplu jonctiune de egalitate pe baza id-urilor comune intre tabelele ANGAJATI si DEPARTAMENTE
select a.id_angajat, a.nume, a.prenume, a.id_departament, d.denumire_departament
from angajati_proiect a, departamente_proiect d
where a.id_departament = d.id_departament 
and a.nume like 'S%';

--Exemplu jonctiune externa intre tabele, se completeaza cu valoarea NULL daca participantii nu au avut contributii
select p.id_participant, p.nume_participant, p.prenume_participant, c.tip_contributie, c.valoare_in_bani
from participanti_proiect p, contributii_proiect c
where p.id_participant = c.id_participant(+);

--Exemplu de interogare subordonata, se vor selecta angajatii care fac parte din acelasi departament ca Adrian
select * from angajati_proiect
where id_departament = (select id_departament from angajati_proiect 
                        where upper(prenume) = 'ADRIAN');

--Exemplu de interogare subordonata, se vor selecta angajatii care au salariul mai mare decat Petria
select * from angajati_proiect
where salariu > (select salariu from angajati_proiect 
                        where lower(nume) = 'petria');

--Exemplu cu functia de concatenare
select 'Angajatul ' || nume || ' ' || prenume || ' are salariul ' || salariu || ' RON.'
from angajati_proiect;

--Exemplu cu functia SUBSTR
select distinct substr(prenume,1,4) "Prescurtare"
from angajati_proiect
where prenume = 'Alexandru';

--Exemplu cu functia MONTHS_BETWEEN
select months_between (sysdate , max(data_angajare))
"Luni trecute"
from angajati_proiect;

--Exemplu cu functia ADD_MONTHS
select add_months (max(data_angajare),6)
from angajati_proiect;

--Exemplu cu functia NEXT_DAY
select next_day (max(data_angajare) , 'monday')
from angajati_proiect;

--Exemplu cu functia LAST_DAY
select data_angajare,
       last_day(data_angajare) "ULTIMA ZI",
       last_day(data_angajare) - data_angajare "ZILE RAMASE"
from angajati_proiect
where nume = 'Szabo';

--Exemplu cu functia TO_NUMBER
select salariu + TO_NUMBER('1000.00', '9999D99')
"CRESTERE SALARIALA"
from angajati_proiect
WHERE nume = 'Szabo';

--Exemplu cu functia NVL
select id_angajat, nume, prenume, id_functie, 
nvl(to_char(id_manager), 'Presedintele nu are manager') id_manager 
from angajati_proiect
where id_departament = 10;

--Exemplu cu functia COUNT
select count (distinct id_angajat) 
"ANGAJATI IT"
from angajati_proiect
where id_functie like '%IT%';

--Exemplu cu functia SUM
select sum (salariu) 
"SALARIILE HR"
from angajati_proiect
where id_functie like '%HR%';

--Structura ierarhica parcursa TOP_DOWN ce ilustreaza relatiile dintre angajati si manageri
SELECT LEVEL, LPAD('-------', LEVEL)|| nume FROM angajati_proiect
CONNECT BY PRIOR id_angajat = id_manager
START WITH id_angajat= 100;

--Structura ierarhica parcursa BOTTOM-UP ce ilustreaza urcarea pe nivelul ierarhiei incepand de la angajatul Kurzberg
SELECT id_angajat, nume, id_manager, LEVEL FROM angajati_proiect
CONNECT BY id_angajat = PRIOR id_manager
START WITH nume= 'Kurzberg'
ORDER BY LEVEL;

--Folosind functia CASE vom afisa salariile cu diferite bonusuri in functie de departament
select nume, prenume, id_functie, 
(case 
when id_functie like 'IT%' then 250
when id_functie like 'IP%' then 150
else 0 
end) + salariu "SALARIU CU BONUS" 
from angajati_proiect;

--Acelasi lucru, folosind functia DECODE
select nume, prenume, id_functie, 
decode(id_functie, 'IT_ANG', 250, 'IT_MAN', 250,
'IP_ANG', 150, 'IP_MAN', 150, 0)
+ salariu "SALARIU CU BONUS" 
from angajati_proiect;

--Folosind comanda MINUS vom afisa angajatii dintr-un departament care nu sunt manageri
select * from angajati_proiect where id_functie like 'IT%'
minus
select * from angajati_proiect where id_functie like '%MAN';

--Crearea unei tabele virtuale cu angajatii dintr-un anume departament
CREATE OR REPLACE VIEW v_angajati_proiect_10
AS SELECT * FROM angajati_proiect
WHERE id_departament = 10
WITH READ ONLY;

SELECT * FROM v_angajati_proiect_10;

--Acest VIEW este READ ONLY, comanda UPDATE va genera eroare
UPDATE v_angajati_proiect_10
SET salariu = salariu + 1000;

--Crearea unei secvente care se incrementeaza cu o valoare, pe baza careia vom face noi inserari de valori
CREATE SEQUENCE seq_contrib
START WITH 250 INCREMENT BY 10
MAXVALUE 1500 NOCYCLE;

INSERT INTO contributii_proiect 
VALUES (7, 4, 2, 'donatie', seq_contrib.nextval);

INSERT INTO contributii_proiect 
VALUES (8, 5, 2, 'donatie', seq_contrib.nextval);

