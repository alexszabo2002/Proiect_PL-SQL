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
