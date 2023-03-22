--Script pentru generarea bazei de date--

drop table departamente_proiect cascade constraints;
drop table angajati_proiect cascade constraints;
drop table proiecte_proiect cascade constraints;
drop table participanti_proiect cascade constraints;
drop table participanti_posibili cascade constraints;
drop table contributii_proiect cascade constraints;

prompt 
prompt Creating table DEPARTAMENTE_PROIECT
prompt ===================================
prompt
create table departamente_proiect
(
id_departament number(4) not null,
denumire_departament varchar2(30) not null,
id_manager number(6)
);
alter table departamente_proiect 
add constraint departamente_id_dep_pk primary key (id_departament);

prompt 
prompt Creating table ANGAJATI_PROIECT
prompt ===============================
prompt
create table angajati_proiect
(
id_angajat number(6) not null,
nume varchar2(20),
prenume varchar2(20),
email varchar2(30),
telefon varchar2(20),
data_nastere date not null,
data_angajare date not null,
salariu number(8,2),
id_functie varchar2(10),
id_departament number(4),
id_manager number(6)
);
alter table angajati_proiect
add constraint angajati_id_ang_pk primary key (id_angajat);
alter table angajati_proiect
add constraint angajati_email_uk unique (email);
alter table angajati_proiect
add constraint angajati_departamente_fk foreign key (id_departament)
references departamente_proiect (id_departament);
alter table angajati_proiect
add constraint angajati_manager_fk foreign key (id_manager)
references angajati_proiect (id_angajat);
alter table angajati_proiect
add constraint angajati_salariu_min 
check (salariu > 0);

prompt 
prompt Creating table PROIECTE_PROIECT
prompt ===============================
prompt
create table proiecte_proiect
(
id_proiect number(4),
denumire_proiect varchar2(30),
descriere varchar2(200),
categorie varchar2(30)
);
alter table proiecte_proiect
add constraint proiecte_id_proiect_pk primary key (id_proiect);

prompt 
prompt Creating table PARTICIPANTI_PROIECT
prompt ===================================
prompt
create table participanti_proiect
(
id_participant number(4) not null,
nume_participant varchar2(20) not null,
prenume_participant varchar2(20),
email_participant varchar2(30) not null,
data_nastere_participant date not null
);
alter table participanti_proiect
add constraint participanti_id_pk primary key (id_participant);
alter table participanti_proiect
add constraint participanti_email_uk unique (email_participant);

prompt 
prompt Creating table PARTICIPANTI_POSIBILI
prompt ====================================
prompt
create table participanti_posibili
(
id_participant number(4) not null,
nume_participant varchar2(20) not null,
prenume_participant varchar2(20),
email_participant varchar2(30) not null,
data_nastere_participant date not null
);
alter table participanti_posibili
add constraint participanti_po_id_pk primary key (id_participant);
alter table participanti_posibili
add constraint participanti_po_email_uk unique (email_participant);

prompt 
prompt Creating table CONSTRIBUTII_PROIECT
prompt ===================================
prompt
create table contributii_proiect
(
id_contributie number(6),
id_participant number(4),
id_proiect number(4),
tip_contributie varchar2(30),
valoare_in_bani number(8,2)
);
alter table contributii_proiect
add constraint contributii_id_cont_pk primary key (id_contributie);
alter table contributii_proiect
add constraint contributii_participanti_fk foreign key (id_participant)
references participanti_proiect (id_participant);
alter table contributii_proiect
add constraint contributii_proiecte_fk foreign key (id_proiect)
references proiecte_proiect (id_proiect);

prompt 
prompt All tables created
prompt

prompt Loading DEPARTAMENTE_PROIECT...
insert into departamente_proiect (id_departament, denumire_departament, id_manager)
values (10, 'Administrativ', 100);
insert into departamente_proiect (id_departament, denumire_departament, id_manager)
values (20, 'Financiar', 102);
insert into departamente_proiect (id_departament, denumire_departament, id_manager)
values (30, 'Resurse Umane', 108);
insert into departamente_proiect (id_departament, denumire_departament, id_manager)
values (40, 'Imagine si Promovare', 114);
insert into departamente_proiect (id_departament, denumire_departament, id_manager)
values (50, 'IT', 122);
commit;
prompt 5 records loaded

prompt Loading ANGAJATI_PROIECT...
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (100, 'Dinu', 'Ana', 'anadinu@gmail.com', '0745.479.299', to_date('12-08-2002', 'dd-mm-yyyy'), to_date('10-12-2020', 'dd-mm-yyyy'), 10000, 'AD_PRES', 10, null);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (101, 'Mitu', 'Alexandru', 'alexmitu@gmail.com', '0742.225.131', to_date('19-07-2002', 'dd-mm-yyyy'), to_date('10-12-2020', 'dd-mm-yyyy'), 9000, 'AD_VP', 10, 100);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (102, 'Micloiu', 'Diana', 'dianamicloiu@gmail.com', '0747.924.268', to_date('15-11-2003', 'dd-mm-yyyy'), to_date('12-12-2020', 'dd-mm-yyyy'), 7500, 'FR_MAN', 20, 101);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (103, 'Ciur', 'Ana', 'anaciur@gmail.com', '0758.035.379', to_date('06-10-2002', 'dd-mm-yyyy'), to_date('04-01-2021', 'dd-mm-yyyy'), 5000, 'FR_ANG', 20, 102);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (104, 'Tudorache', 'Andrei', 'andreitudorache@yahoo.ro', '0755.172.243', to_date('23-01-2002', 'dd-mm-yyyy'), to_date('04-01-2021', 'dd-mm-yyyy'), 5000, 'FR_ANG', 20, 102);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (105, 'Radu', 'Catalina', 'catalinaradu@gmail.com', '0738.615.299', to_date('22-09-2002', 'dd-mm-yyyy'), to_date('10-02-2021', 'dd-mm-yyyy'), 4500, 'FR_ANG', 20, 103);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (106, 'Mitrea', 'Bogdan', 'bogdanmitrea@yahoo.ro', '0724.111.970', to_date('15-02-2002', 'dd-mm-yyyy'), to_date('15-02-2021', 'dd-mm-yyyy'), 4600, 'FR_ANG', 20, 104);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (107, 'Nan', 'Stefan', 'stefannan@gmail.com', '0735.031.233', to_date('20-12-2001', 'dd-mm-yyyy'), to_date('16-02-2021', 'dd-mm-yyyy'), 4400, 'FR_ANG', 20, 104);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (108, 'Ezaru', 'Radu', 'raduezaru@gmail.com', '0722.851.288', to_date('18-11-2002', 'dd-mm-yyyy'), to_date('13-12-2020', 'dd-mm-yyyy'), 7500, 'HR_MAN', 30, 101);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (109, 'Birzan', 'Adelin', 'adelinbirzan@gmail.com', '0725.153.235', to_date('21-03-2002', 'dd-mm-yyyy'), to_date('10-01-2021', 'dd-mm-yyyy'), 5000, 'HR_ANG', 30, 108);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (110, 'Nitu', 'Oana', 'oananitu@yahoo.ro', '0746.242.095', to_date('01-01-2002', 'dd-mm-yyyy'), to_date('11-01-2021', 'dd-mm-yyyy'), 5000, 'HR_ANG', 30, 108);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (111, 'Ionescu', 'Vlad', 'vladionescu@gmail.com', '0726.116.919', to_date('27-10-2002', 'dd-mm-yyyy'), to_date('01-03-2021', 'dd-mm-yyyy'), 4700, 'HR_ANG', 30, 109);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (112, 'Gaita', 'Stefan', 'stefangaita@yahoo.ro', '0787.811.148', to_date('30-10-2002', 'dd-mm-yyyy'), to_date('04-03-2021', 'dd-mm-yyyy'), 4500, 'HR_ANG', 30, 110);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (113, 'Pana', 'Adrian', 'adrianpana@gmail.com', '0720.342.867', to_date('06-06-2002', 'dd-mm-yyyy'), to_date('04-04-2021', 'dd-mm-yyyy'), 4500, 'HR_ANG', 30, 110);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (114, 'Iancu', 'Andrei', 'andreiiancu@gmail.com', '0752.246.785', to_date('18-06-2002', 'dd-mm-yyyy'), to_date('15-12-2020', 'dd-mm-yyyy'), 7800, 'IP_MAN', 40, 101);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (115, 'Stoicescu', 'Stefan', 'stefanstoicescu@gmail.com', '0731.970.868', to_date('26-08-2002', 'dd-mm-yyyy'), to_date('15-12-2020', 'dd-mm-yyyy'), 7500, 'IP_MAN', 40, 101);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (116, 'Raduta', 'Andrei', 'andreiraduta@gmail.com', '0737.549.230', to_date('12-01-2002', 'dd-mm-yyyy'), to_date('12-01-2021', 'dd-mm-yyyy'), 5000, 'IP_ANG', 40, 114);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (117, 'Ionita', 'Maria', 'mariaionita@gmail.com', '0756.502.780', to_date('29-12-2001', 'dd-mm-yyyy'), to_date('13-01-2021', 'dd-mm-yyyy'), 4900, 'IP_ANG', 40, 114);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (118, 'Popescu', 'Mara', 'marapopescu@gmail.com', '0767.603.891', to_date('03-03-2003', 'dd-mm-yyyy'), to_date('18-03-2021', 'dd-mm-yyyy'), 4700, 'IP_ANG', 40, 117);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (119, 'Szabo', 'Alexandru', 'alexszabo@yahoo.ro', '0720.230.202', to_date('23-02-2002', 'dd-mm-yyyy'), to_date('23-02-2021', 'dd-mm-yyyy'), 5100, 'IP_ANG', 40, 115);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (120, 'Georgescu', 'Cosmina', 'cosminageorgescu@gmail.com', '0787.918.866', to_date('15-08-2002', 'dd-mm-yyyy'), to_date('24-03-2021', 'dd-mm-yyyy'), 4900, 'IP_ANG', 40, 119);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (121, 'Radu', 'Steluta', 'stelutaradu@gmail.com', '0741.391.891', to_date('28-09-2002', 'dd-mm-yyyy'), to_date('05-04-2021', 'dd-mm-yyyy'), 4800, 'IP_ANG', 40, 119);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (122, 'Dragan', 'Andrei', 'andreidragan@gmail.com', '0726.599.637', to_date('31-05-2002', 'dd-mm-yyyy'), to_date('17-12-2020', 'dd-mm-yyyy'), 7900, 'IT_MAN', 50, 101);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (123, 'Spiru', 'Andrei', 'andreispiru@gmail.com', '0728.457.135', to_date('07-07-2002', 'dd-mm-yyyy'), to_date('17-12-2020', 'dd-mm-yyyy'), 7700, 'IT_MAN', 50, 101);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (124, 'Ionescu', 'Andrei', 'andreiionescu@gmail.com', '0721.340.848', to_date('01-12-2002', 'dd-mm-yyyy'), to_date('02-03-2021', 'dd-mm-yyyy'), 5500, 'IT_ANG', 50, 122);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (125, 'Petria', 'Cristian', 'cristianpetria@gmail.com', '0725.207.881', to_date('12-10-2002', 'dd-mm-yyyy'), to_date('12-04-2021', 'dd-mm-yyyy'), 5400, 'IT_ANG', 50, 124);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (126, 'Merla', 'Antoniu', 'antoniumerla@gmail.com', '0729.959.422', to_date('13-12-2001', 'dd-mm-yyyy'), to_date('20-05-2021', 'dd-mm-yyyy'), 5300, 'IT_ANG', 50, 125);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (127, 'Kurzberg', 'Sarah', 'sarahkurzberg@yahoo.ro', '0758.357.483', to_date('18-06-2002', 'dd-mm-yyyy'), to_date('24-06-2021', 'dd-mm-yyyy'), 5200, 'IT_ANG', 50, 126);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (128, 'Cirstea', 'Andrei', 'andreicirstea@yahoo.ro', '0727.940.042', to_date('04-07-2002', 'dd-mm-yyyy'), to_date('10-03-2021', 'dd-mm-yyyy'), 5500, 'IT_ANG', 50, 123);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (129, 'Tanasescu', 'Alexandru', 'alextanasescu@gmail.com', '0726.031.135', to_date('21-03-2002', 'dd-mm-yyyy'), to_date('13-04-2021', 'dd-mm-yyyy'), 5400, 'IT_ANG', 50, 128);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (130, 'Cantar', 'Nicholas', 'nicholascantar@gmail.com', '0737.142.246', to_date('20-12-2002', 'dd-mm-yyyy'), to_date('01-05-2021', 'dd-mm-yyyy'), 5300, 'IT_ANG', 50, 129);
insert into angajati_proiect (id_angajat, nume, prenume, email, telefon, data_nastere, data_angajare, salariu, id_functie, id_departament, id_manager)
values (131, 'Nitu', 'Vlad', 'vladnitu@gmail.com', '0748.253.357', to_date('16-01-2002', 'dd-mm-yyyy'), to_date('30-06-2021', 'dd-mm-yyyy'), 5200, 'IT_ANG', 50, 130);
commit;
prompt 32 records loaded

prompt Loading PROIECTE_PROIECT...
insert into proiecte_proiect (id_proiect, denumire_proiect, descriere, categorie)
values (1, 'Dorinte Indeplinite', 'Un proiect in care ii ajutam cu bani, mancare sau lucruri pe cei care au nevoie.', 'caritate');
insert into proiecte_proiect (id_proiect, denumire_proiect, descriere, categorie)
values (2, 'Next In Tech', 'Un proiect in care promovam tehnologia si inovatia.', 'tehnologie');
insert into proiecte_proiect (id_proiect, denumire_proiect, descriere, categorie)
values (3, 'Entertainment Masters', 'Un proiect in care vrem sa aducem un strop de distractie in viata tuturor.', 'entertainment');
commit;
prompt 3 records loaded

prompt Loading PARTICIPANTI_PROIECT...
insert into participanti_proiect (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (1, 'Szabo', 'Tiberiu', 'tiberiuszabo@gmail.com', to_date('15-07-2006', 'dd-mm-yyyy'));
insert into participanti_proiect (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (2, 'Popescu', 'Teodora', 'teopopescu@gmail.com', to_date('23-07-2007', 'dd-mm-yyyy'));
insert into participanti_proiect (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (3, 'Lasue', 'Nathalie', 'nathalielasue@gmail.com', to_date('12-08-2006', 'dd-mm-yyyy'));
insert into participanti_proiect (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (4, 'Popescu', 'Andrei', 'andreipopescu@gmail.com', to_date('24-02-2001', 'dd-mm-yyyy'));
insert into participanti_proiect (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (5, 'Voinea', 'Andrei', 'andreivoinea@gmail.com', to_date('20-12-2001', 'dd-mm-yyyy'));
insert into participanti_proiect (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (6, 'Capatina', 'Bogdan', 'bogdancapatina@gmail.com', to_date('12-04-2005', 'dd-mm-yyyy'));
insert into participanti_proiect (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (7, 'Ilie', 'David', 'davidilie@gmail.com', to_date('15-12-2004', 'dd-mm-yyyy'));
commit;
prompt 7 records loaded

prompt Loading PARTICIPANTI_POSIBILI...
insert into participanti_posibili (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (3, 'Lasue', 'Nathalie', 'nathalielasue@gmail.com', to_date('12-08-2006', 'dd-mm-yyyy'));
insert into participanti_posibili (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (100, 'Dita', 'Mara', 'maradita@gmail.com', to_date('01-12-2002', 'dd-mm-yyyy'));
insert into participanti_posibili (id_participant, nume_participant, prenume_participant, email_participant, data_nastere_participant)
values (101, 'Dita', 'Stefan', 'stefandita@gmail.com', to_date('20-06-2007', 'dd-mm-yyyy'));
commit;
prompt 3 records loaded

prompt Loading CONTRIBUTII_PROIECT...
insert into contributii_proiect (id_contributie, id_participant, id_proiect, tip_contributie, valoare_in_bani)
values (1, 1, 1, 'jucarii', null);
insert into contributii_proiect (id_contributie, id_participant, id_proiect, tip_contributie, valoare_in_bani)
values (2, 2, 1, 'dulciuri', null);
insert into contributii_proiect (id_contributie, id_participant, id_proiect, tip_contributie, valoare_in_bani)
values (3, 4, 2, 'donatie in lei', 1000);
insert into contributii_proiect (id_contributie, id_participant, id_proiect, tip_contributie, valoare_in_bani)
values (4, 5, 2, 'donatie in lei', 1400);
insert into contributii_proiect (id_contributie, id_participant, id_proiect, tip_contributie, valoare_in_bani)
values (5, 6, 3, 'mancare si bauturi', null);
insert into contributii_proiect (id_contributie, id_participant, id_proiect, tip_contributie, valoare_in_bani)
values (6, 7, 3, 'donatie in lei', 800);
commit;
prompt 6 records loaded

prompt 
prompt All rows inserted
prompt Done
