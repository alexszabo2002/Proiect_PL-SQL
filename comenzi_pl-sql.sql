SET SERVEROUTPUT ON

--Se incearca modificarea datelor din tabela CONTRIBUTII pe baza id-ului
--Folosind atributul cursorului implicit SQL%NOTFOUND in conditia structurii IF 
--Mesajul afisat indica daca modificarea s-a realizat sau nu

BEGIN 
    UPDATE contributii_proiect
    SET tip_contributie = 'jucarii'
    WHERE id_contributie = 2;
   
    IF SQL%NOTFOUND THEN 
        DBMS_OUTPUT.PUT_LINE('Nu exista contributie cu acest numar in tabela.');
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Modificarea contributiei s-a realizat cu succes.');
    END IF;
    ROLLBACK;
END;
/

--Se va efectua o marire salariala de 100 celor care au salariul sub 5000
--Se va afisa cati dintre cei care au salariul peste 5000 se incadreaza aici dupa marire

DECLARE 
    v_nrang NUMBER := 0;
    nr_salarii_mari NUMBER := 0;
    v_aux angajati_proiect.salariu%TYPE;
    
BEGIN 
    SELECT salariu INTO v_aux
    FROM angajati_proiect
    WHERE salariu < 5000 AND (salariu + 100) >= 5000; 
    
    v_nrang := SQL%ROWCOUNT;

    UPDATE angajati_proiect 
    SET salariu = salariu + 100 
    WHERE salariu < 5000; 
    DBMS_OUTPUT.PUT_LINE('A fost acordata o marire salariala de 100 celor care aveau sub 5000.');
    
    FOR a IN (SELECT * FROM angajati_proiect
              WHERE salariu >= 5000)
    LOOP
        DBMS_OUTPUT.PUT_LINE('Nume: ' || a.nume || '; Salariu: ' || a.salariu);
        nr_salarii_mari := nr_salarii_mari + 1;
    END LOOP;
    
    CASE 
        WHEN nr_salarii_mari = 0 THEN 
            DBMS_OUTPUT.PUT_LINE('Nu a fost gasit niciun angajat cu salariul cel putin 5000.');
        WHEN nr_salarii_mari = 1 THEN 
            DBMS_OUTPUT.PUT_LINE('A fost gasit un singur angajat cu salariul cel putin 5000.');
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Au fost gasiti ' || nr_salarii_mari || ' angajati cu salariul cel putin 5000, dintre care ' || v_nrang || ' dupa marire.');
    END CASE;
    
    ROLLBACK;
    
END;
/

--Afisare informatii despre angajatii din departament utilizand un cursor explicit

DECLARE
    CURSOR c_ang IS SELECT nume, salariu, id_functie 
                    FROM angajati_proiect
                    WHERE id_departament = 40;
    
    ang_num angajati_proiect.nume%TYPE;
    ang_sal angajati_proiect.salariu%TYPE;
    ang_fct angajati_proiect.id_functie%TYPE;
                    
BEGIN 
    DBMS_OUTPUT.PUT_LINE('Lista salariilor angajatilor din departamentul Imagine si Promovare:');
    OPEN c_ang;
    LOOP 
        FETCH c_ang INTO ang_num, ang_sal, ang_fct;
        EXIT WHEN c_ang%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(ang_num || ' cu functia de ' || ang_fct || ' are salariul ' || ang_sal);
    END LOOP;
    CLOSE c_ang;
    
END;
/

--Se vor afisa primele 2 proiecte cu cele mai multe contributii

DECLARE
    CURSOR c IS SELECT pp.id_proiect, pp.denumire_proiect denumire, COUNT(cp.id_contributie) nr_contributii
                FROM proiecte_proiect pp, contributii_proiect cp
                WHERE pp.id_proiect = cp.id_proiect
                GROUP BY pp.id_proiect, pp.denumire_proiect
                ORDER BY COUNT(cp.id_contributie) DESC
                FETCH FIRST 2 ROWS ONLY;
                
    crow c%ROWTYPE;

BEGIN 
    OPEN c;
    LOOP 
        FETCH c INTO crow;
        EXIT WHEN c%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('Proiectul ' || crow.denumire || ' are ' || crow.nr_contributii || ' contributii.');
    END LOOP;
    CLOSE c;

END;
/

--Se vor afisa informatii despre donatii si se va calcula suma totala de bani stransi

DECLARE 
    v_total NUMBER := 0;
    
    CURSOR c_contrib IS SELECT id_contributie, valoare_in_bani
                        FROM contributii_proiect;

BEGIN
    FOR i IN c_contrib 
    LOOP 
        IF i.valoare_in_bani IS NOT NULL THEN 
            DBMS_OUTPUT.PUT_LINE('Donatia cu id-ul ' || i.id_contributie || ' este in valoare de ' || i.valoare_in_bani);
            v_total := v_total + i.valoare_in_bani;
        ELSE 
            DBMS_OUTPUT.PUT_LINE('Donatia cu id-ul ' || i.id_contributie || ' nu este in bani.');
        END IF;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Suma de bani adunata din donatii este de ' || v_total);

END;
/

--Se va afisa numele complet si departamentul angajatului al carui prenume este introdus de la tastatura
--Se vor trata cazurile in care sunt prea multi sau nu exista angajati prin exceptii 

DECLARE 
    v_nume angajati_proiect.nume%TYPE;
    v_dep departamente_proiect.denumire_departament%TYPE;
    v_prenume angajati_proiect.prenume%TYPE := '&prenume';
    prea_multi_angajati EXCEPTION;
    PRAGMA EXCEPTION_INIT(prea_multi_angajati,-01422);
    
BEGIN
    SELECT a.nume, d.denumire_departament
    INTO v_nume, v_dep
    FROM angajati_proiect a, departamente_proiect d
    WHERE a.id_departament = d.id_departament
    AND a.prenume = v_prenume;
    DBMS_OUTPUT.PUT_LINE(v_prenume || ' ' || v_nume || ' face parte din departamentul ' || v_dep);
    
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('Nu exista angajat.');
    WHEN prea_multi_angajati THEN 
        DBMS_OUTPUT.PUT_LINE('Sunt mai multi angajati cu acest nume.');
        FOR v IN (SELECT a.nume as nume, d.denumire_departament as dep
                  FROM angajati_proiect a, departamente_proiect d
                  WHERE a.id_departament = d.id_departament
                  AND a.prenume = v_prenume)
        LOOP 
            DBMS_OUTPUT.PUT_LINE(v_prenume || ' ' || v.nume || ' este din ' || v.dep);
        END LOOP;
END;
/

--Se vor majora salariile care au valoarea sub un anumit prag
--In caz contrar, se va gestiona printr-o exceptie

DECLARE 
    nu_exista_angajati EXCEPTION;
    
BEGIN 
    UPDATE angajati_proiect
    SET salariu = salariu + 150
    WHERE salariu < &prag_salariu_minim;
    
    IF SQL%FOUND THEN 
        DBMS_OUTPUT.PUT_LINE('S-au modificat ' || SQL%ROWCOUNT || ' salarii');
    ELSE 
        RAISE nu_exista_angajati;
    END IF;
    ROLLBACK;

EXCEPTION 
    WHEN nu_exista_angajati THEN
        DBMS_OUTPUT.PUT_LINE('Nu exista angajati cu salariul sub prag.');
        
END;
/

--Se vor afisa ultimii 5 angajati in functie de data
--Vom primi eroare, deoarece utilizand FOR se incearca deschiderea cursorului de 2 ori

DECLARE 
    CURSOR c IS SELECT nume, prenume, data_angajare 
                FROM angajati_proiect 
                ORDER BY data_angajare DESC
                FETCH FIRST 5 ROWS ONLY;
                
BEGIN 
    OPEN c;
    FOR r IN c LOOP 
         DBMS_OUTPUT.PUT_LINE(r.prenume || ' ' || r.nume || ' e angajat din ' || r.data_angajare);
    END LOOP;
    
EXCEPTION 
    WHEN CURSOR_ALREADY_OPEN THEN 
        DBMS_OUTPUT.PUT_LINE('Cursorul este deja deschis!');

END;
/

--Varianta corecta este fara deschiderea cursorului prin comanda OPEN c

DECLARE 
    CURSOR c IS SELECT nume, prenume, data_angajare 
                FROM angajati_proiect 
                ORDER BY data_angajare DESC
                FETCH FIRST 5 ROWS ONLY;
                
BEGIN 
    FOR r IN c LOOP 
         DBMS_OUTPUT.PUT_LINE(r.prenume || ' ' || r.nume || ' e angajat din ' || r.data_angajare);
    END LOOP;
    
EXCEPTION 
    WHEN CURSOR_ALREADY_OPEN THEN 
        DBMS_OUTPUT.PUT_LINE('Cursorul este deja deschis!');

END;
/

--Se va compara suma valorilor contributiilor cu o suma prag
--Daca fondurile nu sunt suficiente, se va gestiona printr-o exceptie

DECLARE 
    v_contributii_cash NUMBER;
    CURSOR c IS SELECT id_contributie, valoare_in_bani 
                FROM contributii_proiect;
    fonduri_insuficiente EXCEPTION;
    v_id contributii_proiect.id_contributie%TYPE;
    v_valoare contributii_proiect.valoare_in_bani%TYPE;
    suma_prag NUMBER := &suma_prag;
    
BEGIN 
    v_contributii_cash := 0;
    OPEN c;
    LOOP 
        FETCH c INTO v_id, v_valoare;
        EXIT WHEN c%NOTFOUND;
        v_contributii_cash := v_contributii_cash + NVL(v_valoare, 0);
    END LOOP;
    CLOSE c;
    IF v_contributii_cash < suma_prag THEN 
        RAISE fonduri_insuficiente;
    ELSE 
        DBMS_OUTPUT.PUT_LINE('Fonduri suficiente');
    END IF;

EXCEPTION 
    WHEN fonduri_insuficiente THEN 
        DBMS_OUTPUT.PUT_LINE('Valoarea contributiilor este o suma prea mica');
        
END;
/


CREATE OR REPLACE PACKAGE pachet_proceduri_proiect AS
    
    --Afisare detalii despre angajatii dintr-un departament
    PROCEDURE Afisare_angajati_departament(departament_id IN ANGAJATI_PROIECT.id_departament%TYPE);
    
    --Valoarea totala a contributiilor unui participant
    PROCEDURE Valoare_contributii (p_id NUMBER);
    
    --Afisarea tuturor angajatilor in ordinea cronologica a angajarilor
    PROCEDURE Ordine_angajari;
    
END;
/

CREATE OR REPLACE PACKAGE BODY pachet_proceduri_proiect AS

        PROCEDURE Afisare_angajati_departament(departament_id IN ANGAJATI_PROIECT.id_departament%TYPE)
    AS
        v_count NUMBER;
        CURSOR c_angajati IS 
            SELECT nume, email, telefon, data_nastere, salariu, id_functie
            FROM ANGAJATI_PROIECT 
            WHERE id_departament = departament_id;
          
    BEGIN     
            SELECT COUNT(*)
            INTO v_count
            FROM DEPARTAMENTE_PROIECT
            WHERE id_departament = departament_id;
    
            IF v_count = 0 THEN
                DBMS_OUTPUT.PUT_LINE('Nu exista departamentul '||departament_id);
                RETURN;
            END IF;
    
            DBMS_OUTPUT.PUT_LINE('Detalii angajati departament '||departament_id);
            FOR angajat IN c_angajati LOOP
                DBMS_OUTPUT.PUT_LINE('Nume: '||angajat.nume);
                DBMS_OUTPUT.PUT_LINE('Email: '||angajat.email);
                DBMS_OUTPUT.PUT_LINE('Telefon: '||angajat.telefon);
                DBMS_OUTPUT.PUT_LINE('Data nasterii: '||angajat.data_nastere);
                DBMS_OUTPUT.PUT_LINE('Salariu: '||angajat.salariu);
                DBMS_OUTPUT.PUT_LINE('Functie: '||angajat.id_functie);
                DBMS_OUTPUT.PUT_LINE('------------------------------');
            END LOOP;
        
    EXCEPTION
    
        WHEN NO_DATA_FOUND THEN
            DBMS_OUTPUT.PUT_LINE('Nu exista angajati in departamentul '||departament_id);
    END;
    
    
        PROCEDURE Valoare_contributii (p_id NUMBER)
    AS
        nr_contrib NUMBER;
        nu_sunt_contributii EXCEPTION;
        valoare_contributii NUMBER := 0;
    
    BEGIN 
        SELECT COUNT(*)
        INTO nr_contrib
        FROM contributii_proiect
        WHERE id_participant = p_id;
        
        IF nr_contrib = 0 THEN
            RAISE nu_sunt_contributii;
        END IF;
        
        FOR c IN (SELECT id_contributie, valoare_in_bani FROM contributii_proiect WHERE id_participant = p_id) LOOP
            valoare_contributii := valoare_contributii + NVL(c.valoare_in_bani, 0);
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('Valoarea contributiilor pentru participantul ' || p_id || ' este ' || valoare_contributii);
        
    EXCEPTION 
        WHEN nu_sunt_contributii THEN 
            DBMS_OUTPUT.PUT_LINE('Nu exista participant cu acest id!');
    
    END;
    
    
        PROCEDURE Ordine_angajari
    AS
    
        CURSOR c IS SELECT a.nume, a.prenume, a.data_angajare, d.denumire_departament 
                    FROM angajati_proiect a, departamente_proiect d
                    WHERE a.id_departament = d.id_departament
                    ORDER BY data_angajare, a.id_angajat;
        r c%ROWTYPE;
        
    BEGIN 
        DBMS_OUTPUT.PUT_LINE('Ordinea angajarilor:');
        OPEN c;
        LOOP 
            FETCH c INTO r;
            EXIT WHEN c%NOTFOUND;
            DBMS_OUTPUT.PUT_LINE(r.nume || ' ' || r.prenume || ' *** ' || r.denumire_departament || ' *** ' || r.data_angajare);
        END LOOP;
        CLOSE c;
    
    END;

END;
/

--apel procedura--

EXECUTE pachet_proceduri_proiect.Afisare_angajati_departament(20);
/

EXECUTE pachet_proceduri_proiect.Valoare_contributii(4);
/

EXECUTE pachet_proceduri_proiect.Ordine_angajari();
/


CREATE OR REPLACE PACKAGE pachet_functii_proiect AS
    
    --Se afiseaza contributiile unui participant sub forma de lista, oferind ca parametru id-ul participantului
    FUNCTION Afisare_contributii (p_id IN contributii_proiect.id_participant%TYPE) RETURN VARCHAR2;
 
    --Verificare daca angajatul cu id-ul introdus are sau nu 2 ani vechime   
    FUNCTION Verificare_vechime (p_idang angajati_proiect.id_angajat%TYPE) RETURN BOOLEAN;
    
    --Afisare detalii despre proiectul cu id-ul introdus
    FUNCTION Detalii_proiect (p_id proiecte_proiect.id_proiect%TYPE) RETURN VARCHAR2;
    
END;
/

CREATE OR REPLACE PACKAGE BODY pachet_functii_proiect AS

        FUNCTION Afisare_contributii (p_id IN contributii_proiect.id_participant%TYPE) RETURN VARCHAR2
    IS
        nr_contrib NUMBER;
        nu_sunt_contributii EXCEPTION;
        v_denum VARCHAR2(100) := '';
    
    BEGIN 
        SELECT COUNT(*)
        INTO nr_contrib
        FROM contributii_proiect
        WHERE id_participant = p_id;
        
        IF nr_contrib = 0 THEN
            RAISE nu_sunt_contributii;
        END IF;
        
        FOR c IN (SELECT tip_contributie FROM contributii_proiect WHERE id_participant = p_id) LOOP
            v_denum := v_denum || c.tip_contributie || '; ';
        END LOOP;
        
        RETURN v_denum;
        
    EXCEPTION 
        WHEN nu_sunt_contributii THEN RETURN 'Nu exista participant!';
        
    END;
    
        FUNCTION Verificare_vechime (p_idang angajati_proiect.id_angajat%TYPE) RETURN BOOLEAN 
    IS
        v_vechime NUMBER;
        
    BEGIN 
        SELECT TRUNC((SYSDATE-data_angajare)/365) INTO v_vechime
        FROM angajati_proiect
        WHERE id_angajat = p_idang;
        
        IF v_vechime >= 2 THEN 
            RETURN TRUE;        
        ELSE 
            RETURN FALSE;
        END IF;
        
    END;
    
    
        FUNCTION Detalii_proiect (p_id proiecte_proiect.id_proiect%TYPE) RETURN VARCHAR2
    IS
        nr_proiecte NUMBER;
        nu_sunt_proiecte EXCEPTION;
        v_det VARCHAR2(200) := '';
        
    BEGIN 
        SELECT COUNT(*)
        INTO nr_proiecte
        FROM proiecte_proiect
        WHERE id_proiect = p_id;
        
        IF nr_proiecte = 0 THEN
            RAISE nu_sunt_proiecte;
        END IF; 
        
        FOR c IN (SELECT denumire_proiect, descriere FROM proiecte_proiect WHERE id_proiect = p_id) LOOP
            v_det := v_det || c.denumire_proiect || ' - ' || c.descriere;
        END LOOP;
        
        RETURN v_det;
        
    EXCEPTION 
        WHEN nu_sunt_proiecte THEN RETURN 'Nu exista proiect!';
        
    END;

END;
/

--apel functii--

DECLARE 
    v_denum VARCHAR2(100);

BEGIN 
    v_denum := pachet_functii_proiect.Afisare_contributii(6);
    IF v_denum = 'Nu exista participant!' THEN 
        DBMS_OUTPUT.PUT_LINE('Nu exista participant!');
    ELSE
        DBMS_OUTPUT.PUT_LINE(v_denum);
    END IF;
END;
/


DECLARE
    v_id angajati_proiect.id_angajat%TYPE:=&v;

BEGIN
    DBMS_OUTPUT.PUT_LINE('Verificare angajat '||v_id);
    IF (pachet_functii_proiect.Verificare_vechime(v_id)) THEN
        DBMS_OUTPUT.PUT_LINE('Angajatul are cel putin 2 ani vechime');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Angajatul nu are 2 ani vechime');
    END IF;
    
END;
/


DECLARE 
    v_det VARCHAR2(200);
    v_id proiecte_proiect.id_proiect%TYPE:=&idproiect;

BEGIN 
    v_det := pachet_functii_proiect.Detalii_proiect(v_id);
    IF v_det = 'Nu exista proiect!' THEN 
        DBMS_OUTPUT.PUT_LINE('Nu exista proiect!');
    ELSE
        DBMS_OUTPUT.PUT_LINE(v_det);
    END IF;
END;
/


--Prin modificarea id-ului de participant se va face modificarea pentru fiecare contributie a acestuia

CREATE OR REPLACE TRIGGER trg_update_participanti

    BEFORE UPDATE OF id_participant ON participanti_proiect
    FOR EACH ROW 
    BEGIN
        UPDATE contributii_proiect
        SET id_participant = :NEW.id_participant
        WHERE id_participant = :OLD.id_participant;
    END;
    /
    
UPDATE participanti_proiect
SET id_participant = 100 
WHERE id_participant = 5;

--Nu va fi permisa diminuarea salariului sub valoarea minima de 3000

CREATE OR REPLACE TRIGGER trg_stop_taiere_sal

    BEFORE UPDATE OF salariu ON angajati_proiect
    FOR EACH ROW 
    BEGIN 
        IF :NEW.salariu < 3000 THEN 
            RAISE_APPLICATION_ERROR(-20010, 'Angajatul nu poate avea salariul sub minimul pe economie!');
        END IF;
    END;
    /
    
UPDATE angajati_proiect
SET salariu = 2000
WHERE id_angajat = 120;

--Nu vom putea adauga un nou proiect pe lista daca nu face parte din una din cele trei categorii

CREATE OR REPLACE TRIGGER trg_categorie_invalida

    BEFORE INSERT ON proiecte_proiect
    FOR EACH ROW
    DECLARE
        v_categorie proiecte_proiect.categorie%TYPE;
    BEGIN
        v_categorie := :NEW.categorie;
        IF v_categorie NOT IN ('caritate', 'tehnologie', 'entertainment') THEN 
            RAISE_APPLICATION_ERROR(-20011, 'Proiectul trebuie s? se încadreze în una dintre categoriile: caritate, tehnologie, entertainment.');
        END IF;
    END;
    /
    
INSERT INTO proiecte_proiect 
VALUES (4, 'Music4All', 'Un proiect in care gazduim un festival de muzica.', 'festival');
