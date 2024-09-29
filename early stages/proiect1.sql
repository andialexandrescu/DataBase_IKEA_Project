alter session set nls_date_format='DD-MON-RR';
alter session set nls_timestamp_tz_format='HH24:MI:SS';

select systimestamp from dual;
select sysdate from dual;

create sequence seq_client
start with 10000000
increment by 10
maxvalue 99999999
nocycle
nocache;

create sequence seq_agent
start with 10000
increment by 5
maxvalue 99999
nocycle
nocache;

create sequence seq_comanda
start with 1000000000
increment by 2
maxvalue 4999999999
nocycle
nocache;

create sequence seq_tranzactie
start with 1000000001
increment by 2
maxvalue 4999999999
nocycle
nocache;

create sequence seq_material
start with 5000000000
increment by 3
maxvalue 9999999999
nocycle
nocache;

create sequence seq_produs
start with 400000
increment by 1
maxvalue 999999
nocycle
nocache;

create table CLIENT
(
    id_client number(8) primary key,
    tip_client varchar(6) not null, constraint verif_tip_client check (tip_client in ('online', 'fizic')),
    nume_firma varchar(50)
);

create table CLIENT_ONLINE
(
    id_client number(8) primary key, -- id_client_online
    email varchar(50) not null,
    nume varchar(20),
    prenume varchar(20) not null,
    
    constraint fk_client_online
        foreign key(id_client)
        references CLIENT(id_client)
        on delete cascade
);

create table CLIENT_FIZIC
(
    id_client number(8) primary key, -- id_client_fizic
    telefon char(12) unique,
    
    constraint fk_client_fizic
        foreign key(id_client)
        references CLIENT(id_client)
        on delete cascade
);

select seq_client.nextval
from dual;

insert into CLIENT values(seq_client.currval, 'online', null);
insert into CLIENT values(seq_client.nextval, 'fizic', 'DEluxe Store');
insert into CLIENT values(seq_client.nextval, 'online', 'Retail Express S.R.L.');
insert into CLIENT values(seq_client.nextval, 'online', 'Alina CraftShop S.R.L.');
insert into CLIENT values(seq_client.nextval, 'fizic', null);
insert into CLIENT values(seq_client.nextval, 'fizic', null);
insert into CLIENT values(seq_client.nextval, 'fizic', 'Evenimente cu Familia');
insert into CLIENT values(seq_client.nextval, 'online', 'Agentia de imobiliare BuyToday');
insert into CLIENT values(seq_client.nextval, 'online', null);
insert into CLIENT values(seq_client.nextval, 'online', 'Alpha Bank Headquarters');
insert into CLIENT values(seq_client.nextval, 'fizic', null);

select * from client;

insert into CLIENT_ONLINE values(10000000, 'alexandrescu_a@gmail.com', null, 'Andra');
insert into CLIENT_ONLINE values(10000020, 'andreea.badea_@retailexpress.outlook.com', 'Badea', 'Andreea');
insert into CLIENT_ONLINE values(10000030, 'alinapopescu1997@gmail.com', 'Popescu', 'Alina');
insert into CLIENT_ONLINE values(10000070, 'dan_cristescu@manager.buytoday.ro', 'Cristescu', 'Dan');
insert into CLIENT_ONLINE values(10000080, 'alex_dragos@gmail.com', null, 'Alexandru');
insert into CLIENT_ONLINE values(10000090, 'maria_pestritu@alphabank.outlook.ro', 'Pestritu', 'Maria');

select * from client_online;

insert into CLIENT_FIZIC values(10000010, '+40772937066');
insert into CLIENT_FIZIC values(10000040, '+40791816617');
insert into CLIENT_FIZIC values(10000050, '+40716423256');
insert into CLIENT_FIZIC values(10000060, '+40756246891');
insert into CLIENT_FIZIC values(10000100, '+40752789141');

select * from client_fizic;

create table ADRESA
(
    cod_postal number(6) primary key,
    oras varchar(25) not null,
    tara varchar(25) not null,
    strada varchar(70)
);

drop table adresa;

-- magazine
insert into ADRESA values(032266, 'Bucuresti', 'Romania', 'Bulevardul Theodor Pallady, nr. 57, Sector 3');
insert into ADRESA values(013696, 'Bucuresti', 'Romania', 'Sos. Bucuresti Ploiesti, nr. 42A, Sector 1');
insert into ADRESA values(307160, 'Timisoara', 'Romania', 'Bulevardul Petre Tutea, nr. 2A');
insert into ADRESA values(400436, 'Cluj-Napoca', 'Romania', 'Str. Alexandru Vaida Voevod 53B');
insert into ADRESA values(500238, 'Brasov', 'Romania', 'Str. Crisului, nr. 18');
insert into ADRESA values(707252, 'Iasi', 'Romania', 'Bulevardul Calea Chisinaului, nr. 29');
insert into ADRESA values(410224, 'Oradea', 'Romania', 'Calea Aradului 87A');
insert into ADRESA values(550088, 'Sibiu', 'Romania', 'Calea Surii Mari 43');
insert into ADRESA values(900147, 'Constanta', 'Romania', 'Str. Cumpenei, nr. 2');
-- clienti
insert into ADRESA values(040394, 'Bucuresti', 'Romania', 'Str. Visana, nr. 3, bloc 44, sc. A, ap. 12');
insert into ADRESA values(700259, 'Iasi', 'Romania', 'Str. Vasile Stroescu, nr. 28, bloc Y4');
insert into ADRESA values(106100, 'Sinaia', 'Romania', 'Str. Paraul Dorului');
insert into ADRESA values(010566, 'Bucuresti', 'Romania', 'Calea Dorobantilor, nr. 237 B, Sector 1');


select * from adresa;

create table MAGAZIN -- trebuie drop
(
    id_magazin varchar(4) primary key,
    telefon char(12) unique,
    centru_ridicare smallint not null, constraint verif_centru_bool check(centru_ridicare in (0, 1)),
    cod_postal number(6) not null unique, -- relatie one-to-one: cardinalitate maxima 1 (unique) inspre MAGAZIN, cardinalitate minima 1 (not null) inspre ADRESA
    
    constraint fk_magazin_cod_postal
        foreign key(cod_postal)
        references ADRESA(cod_postal)
        on delete set null
);

-- ca sa nu mai dau drop altfel nu execut liniile astea
alter table MAGAZIN modify (cod_postal unique);
alter table MAGAZIN modify (cod_postal not null);

drop table magazin;

insert into MAGAZIN values('A42D', '+40789947067', 032266, 0);
insert into MAGAZIN values('09OP', '+40769937527', 307160, 0);
insert into MAGAZIN values('45E', '+40781550674', 013696, 0);
insert into MAGAZIN values('234Y', '+40752356779', 550088, 1);
insert into MAGAZIN values('RT56', '+40742622774', 400436, 1);
insert into MAGAZIN values('7TY6', '+40782378375', 707252, 1);
insert into MAGAZIN values('10UP', '+40792378237', 900147, 1);
insert into MAGAZIN values('56GH', '+40721729803', 500238, 1);
insert into MAGAZIN values('4DF', '+40762751657', 410224, 1);

select * from magazin;

create table AGENT_VANZARI
(   
    id_angajat number(5) primary key,
    nume varchar(20) not null,
    prenume varchar(20) not null,
    data_angajare date not null,
    telefon char(12) unique,
    id_magazin varchar(4), -- cardinalitate maxima M (not unique) inspre AGENT_VANZARI, cardinalitate minima 0 (may be null) inspre MAGAZIN
    
    -- imposibil fara un trigger: constraint verif_tip_magazin check(centru_ridicare = 0),
    constraint fk_agent_vanzari_id_magazin
        foreign key(id_magazin)
        references MAGAZIN(id_magazin)
        on delete set null -- raman angajati dar nu le mai este asociat magazinul cu inregistrarea stearsa
);

drop table agent_vanzari;

select seq_agent.nextval
from dual;

drop sequence seq_agent;

-- de adaug documentatie constrangeri
insert into AGENT_VANZARI values(seq_agent.currval, 'Adela', 'Angelescu', '19-MARCH-22', '+40785267887', 'A42D');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Madalin', 'Stroe', '09-FEBRUARY-21', '+40790380926', 'A42D');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Andrei', 'Comanescu', '18-MAY-21', '+40799080928', '45E');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Mircea', 'Istrate', '15-APRIL-20', '+40728767134', '09OP');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Daria', 'Marculescu', '17-FEBRUARY-21', '+40754678239', '45E');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Daniela', 'Ignat', '10-OCTOBER-23', '+40754156824', null);
insert into AGENT_VANZARI values(seq_agent.nextval, 'Mihai', 'Radulescu', '07-JANUARY-24', '+40778567230', null);

select * from agent_vanzari;

create table COMANDA -- trebuie drop table
(
    id_comanda number(10) primary key,
    pret number(6, 2) not null,
    data_achizitie date default sysdate,
    --livrare char(2) default 'nu', constraint verif_opt_livrare check(livrare in ('da', 'nu')),
    id_angajat number(5), -- cardinalitate minima 0 inspre ANGAJAT
    id_client number(8) not null, -- cardinalitate minima 1 inspre CLIENT
    cod_postal number(6), -- cardinalitate minima 0 inspre ADRESA
    --constraint verif_asociere_adresa check((livrare = 'da' and cod_postal is not null) or (livrare = 'nu' and cod_postal is null)), -- este dependinta tranzitiva, nu respecta criteriile FN3
    
    -- relatii one-to-many (many in partea tabelei COMANDA)
    constraint fk_comanda_id_angajat
        foreign key(id_angajat)
        references AGENT_VANZARI(id_angajat)
        on delete set null,
    constraint fk_comanda_id_client
        foreign key(id_client)
        references CLIENT(id_client)
        on delete set null,
    constraint fk_comanda_cod_postal
        foreign key(cod_postal)
        references ADRESA(cod_postal)
        on delete set null
);

--in loc de drop table altfel nu
alter table COMANDA modify (id_client not null);

create table TRANZACTIE
(
    id_tranzactie number(10) primary key,
    modalitate_plata char(4) not null, constraint verif_modal_plata check (modalitate_plata = 'cash' or modalitate_plata = 'card'),
    status_plata varchar(12) default 'aprobata', constraint verif_status check (status_plata in ('in procesare', 'verificare', 'aprobata', 'respinsa')), -- atat pentru o plata card, cat si cash, cu toate ca un model real nu respecta aceasta regula
    id_comanda number(10) not null unique, -- relatie one-to-one: cardinalitate maxima 1 (unique) inspre TRANZACTIE, cardinalitate minima 1 (not null) inspre COMANDA
    
    constraint fk_tranzactie_id_comanda
        foreign key(id_comanda)
        references COMANDA(id_comanda)
        on delete cascade
);
drop table comanda;
drop table tranzactie;

select seq_comanda.nextval
from dual;
select seq_tranzactie.nextval
from dual;

drop sequence seq_comanda;
drop sequence seq_tranzactie;

insert into COMANDA values(seq_comanda.currval, 525.45, '24-MAY-23', 10020, 10000040, 040394);
update comanda set pret = '793.82' where id_comanda = 1000000000;
insert into TRANZACTIE values(seq_tranzactie.currval, 'card', 'in procesare', seq_comanda.currval);
insert into TRANZACTIE values(seq_tranzactie.currval, 'card', 'in procesare', 1000000000);
insert into COMANDA values(seq_comanda.nextval, 1119.99, '05-DECEMBER-21', 10000, 10000100, null);
update comanda set pret = '1574.51' where id_comanda = 1000000002;
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'cash', seq_comanda.currval); -- pt a testa constrangerea default a campului status_plata
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'cash', 1000000002);
--insert into COMANDA values(seq_comanda.nextval, 345.15, '14-APRIL-24', 'da', 10000, 10000080, null); constrangerea de optiune livrare functioneaza
insert into COMANDA values(seq_comanda.nextval, 345.15, '18-APRIL-24', 10000, 10000080, 707252);
update comanda set pret = '3460.05' where id_comanda = 1000000004;
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', seq_comanda.currval);
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', 1000000004);
insert into COMANDA values(seq_comanda.nextval, 798.15, '11-FEBRUARY-24', null, 10000080, 700259);
update comanda set pret = '2388.15' where id_comanda = 1000000006;
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'respinsa', seq_comanda.currval);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'respinsa', 1000000006);
insert into COMANDA(id_comanda, pret, id_client) values(seq_comanda.nextval, 2590.75, 10000050);
update comanda set pret = '679.3' where id_comanda = 1000000008;
insert into TRANZACTIE values(seq_tranzactie.nextval, 'cash', 'aprobata', seq_comanda.currval);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'cash', 'aprobata', 1000000008);
insert into COMANDA(id_comanda, pret, id_client) values(seq_comanda.nextval, 50.10, 10000050);
update comanda set pret = '349.75' where id_comanda = 1000000010;
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'in procesare', seq_comanda.currval);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'in procesare', 1000000010);
insert into COMANDA values(seq_comanda.nextval, 990.5, '14-MAY-24', null, 10000030, 106100);
update comanda set pret = '5667.75' where id_comanda = 1000000012;
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', seq_comanda.currval);
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', 1000000012);
insert into COMANDA values(seq_comanda.nextval, 468.99, sysdate, 10025, 10000000, 400436);
update comanda set pret = '3853.05' where id_comanda = 1000000014;
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'in procesare', seq_comanda.currval);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'in procesare', 1000000014);
insert into COMANDA values(seq_comanda.nextval, 1559.99, '30-AUGUST-21', 10030, 10000020, 900147);
update comanda set pret = '919.7' where id_comanda = 1000000016;
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', seq_comanda.currval);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000016);
insert into COMANDA values(seq_comanda.nextval, 1559.99, '19-NOVEMBER-23', 10005, 10000010, null);
update comanda set pret = '9751.92' where id_comanda = 1000000018;
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', seq_comanda.currval);
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', 1000000018);
insert into COMANDA values(seq_comanda.nextval, 658.65, '21-JUNE-23', 10015, 10000060, null);
update comanda set pret = '1439.03' where id_comanda = 1000000020;
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'cash', seq_comanda.currval);
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'cash', 1000000020);
insert into COMANDA values(seq_comanda.nextval, 1799.99, sysdate, 10005, 10000070, 550088);
update comanda set pret = '8144.95' where id_comanda = 1000000022;
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'respinsa', seq_comanda.currval);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'respinsa', 1000000022);
update tranzactie set status_plata = 'aprobata' where id_tranzactie = 1000000023;
insert into COMANDA values(seq_comanda.nextval, 5600, '09-FEBRUARY-24', 10020, 10000090, 010566);
update comanda set pret = '1199.98' where id_comanda = 1000000024;
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', seq_comanda.currval);
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', 1000000024);
insert into COMANDA values(seq_comanda.nextval, 1679.99, sysdate, null, 10000090, 010566);
update comanda set pret = '4192.55' where id_comanda = 1000000026;
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', seq_comanda.currval);
insert into TRANZACTIE(id_tranzactie, modalitate_plata, id_comanda) values(seq_tranzactie.nextval, 'card', 1000000026);

-- eroare: unique constraint violated relatie de one-to-one 
insert into TRANZACTIE values(seq_tranzactie.nextval, 'cash', 'respinsa', 1000000026);

select * from comanda;
select * from tranzactie;

create table CATEGORIE
(
    id_categorie char(5) primary key,
    nume varchar(50) unique
);

drop table categorie;

insert into CATEGORIE values('ASDRT', 'Accesorii');
insert into CATEGORIE values('PASDU', 'Paturi');
insert into CATEGORIE values('GHJeR', 'Rafturi, dulapuri si unitati de depozitare');
insert into CATEGORIE values('DFGhT', 'Unitati de dulapuri pentru bucatarie');
insert into CATEGORIE values('SDsRK', 'Scaune, mese si birouri');
insert into CATEGORIE values('madYU', 'Mobilier de exterior');
insert into CATEGORIE values('CghUI', 'Canapele si fotolii');
insert into CATEGORIE values('kkRTy', 'Jucarii si jocuri');
insert into CATEGORIE values('eedaT', 'Gradina');

select * from categorie;

create table PIESA_MOBILIER
(
    id_produs number(6) primary key,
    nume varchar(30) unique,
    pret number(6, 2) not null, -- o piesa de mobilier va avea intotdeauna un pret listat si maximul unui pret nu depaseste pragul de 9999 de lei
    descriere varchar(100),
    lungime int,
    latime int,
    inaltime int,
    garantie varchar(50),
    link_web varchar(150),
    nume_designer varchar(50),
    id_categorie char(5) not null, -- cardinalitate maxima M (not unique) inspre PIESA_MOBILIER, cardinalitate minima 1 (not null) inspre CATEGORIE
    
    constraint fk_piesa_mobilier_id_categorie
        foreign key(id_categorie)
        references CATEGORIE(id_categorie)
        on delete cascade
);
alter table PIESA_MOBILIER modify (id_categorie not null);

drop table piesa_mobilier;
drop sequence seq_produs;

select seq_produs.nextval from dual;

insert into PIESA_MOBILIER values(seq_produs.currval, 'MALM', 1999.89, 'Pat cu spatiu de depozitare', 210, 175, 40, '4 ani, prelungire 1 an', 'https://www.ikea.com/ro/ro/p/malm-pat-cu-depozitare-alb-20404806/', 'Eva Lilja Lowenhielm', 'PASDU');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'IDANAS', 2499.15, 'Pat tapitat cu depozitare, Gunnared gri inchis, 140x200 cm', 224, 150, 40, '3 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/idanaes-pat-tapitat-cu-depozitare-gunnared-gri-inchis-40458964/', 'Francis Cayouette', 'PASDU');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'ENHET', 50.50, 'Polita rotativa, antracit, 40x21 cm', 21, 21, 40, null, 'https://www.ikea.com/ro/ro/p/enhet-polita-rotativa-antracit-20465734/', 'IKEA of Sweden/E Lilja Lowenhielm', 'ASDRT');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'KLIPSK', 39.90, 'Tava mic-dejun, gri', 56, 36, 26, null, 'https://www.ikea.com/ro/ro/p/klipsk-tava-mic-dejun-gri-10327700/', 'Marcus Arvonen', 'ASDRT');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'EKET', 320.30, 'Corp cu 2 usi si 1 polita, gri inchis, 70x35x70 cm', 70, 35, 70, '2 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/eket-corp-cu-2-usi-si-1-polita-gri-inchis-20344921/', 'Jon Karlsson', 'GHJeR');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'BILLY', 249.45, 'Biblioteca, alb, 80x28x202 cm', 80, 28, 202, '1 an, prelungire 1 an', 'https://www.ikea.com/ro/ro/p/billy-biblioteca-alb-00263850/', 'Gillis Lundgren', 'GHJeR');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'KALLAX', 749.20, 'Etajera cu 4 organizatoare, negru-maro, 147x147 cm', 147, 39, 147, '2 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/kallax-etajera-cu-4-organizatoare-negru-maro-s09017483/', 'Tord Bjorklund', 'GHJeR');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'FINNBY', 229.90, 'Biblioteca, negru, 60x180 cm', 60, 24, 180, '2 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/finnby-biblioteca-negru-10261129/', 'IKEA of Sweden', 'GHJeR');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'MARKUS', 599.99, 'Scaun rotativ, Vissle gri inchis', 62, 60, 140, '10 ani', 'https://www.ikea.com/ro/ro/p/markus-scaun-rotativ-vissle-gri-inchis-70261150/', 'Henrik Preutz', 'SDsRK');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'BERGMUND', 349.75, 'Scaun, negru/Gunnared gri mediu', 52, 59, 96, null, 'https://www.ikea.com/ro/ro/p/bergmund-scaun-negru-gunnared-gri-mediu-s69384307/', 'IKEA of Sweden/K Hagberg/M Hagberg', 'SDsRK');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'SKOGSTA/INGOLF', 3433.50, 'Masa+6scaune, acacia/negru, 235x100 cm', 235, 100, 74, '5 ani, prelungire 1 an', 'https://www.ikea.com/ro/ro/p/skogsta-ingolf-masa-6scaune-acacia-negru-s09482693/', null, 'SDsRK');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'TARSELE', 2299.20, 'Masa extensibila, furnir stejar/negru, 150/200x80 cm', 200, 80, 77, '3 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/tarsele-masa-extensibila-furnir-stejar-negru-70581359/', null, 'SDsRK');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'MITTCIRKEL/ALEX', 739.99, 'Birou, aspect pin intens/alb, 140x60 cm', 140, 60, 73, '2 ani, prelungire 1 an', 'https://www.ikea.com/ro/ro/p/mittcirkel-alex-birou-aspect-pin-intens-alb-s09521722/', null, 'SDsRK');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'BRIMNES', 799.15, 'Dulap cu 3 usi, negru, 117x190 cm', 117, 50, 190, '2 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/brimnes-dulap-cu-3-usi-negru-60407577/', 'K Hagberg/M Hagberg', 'GHJeR');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'KNOXHULT', 1889.25, 'Bucatarie, alb, 220x61x220 cm', 220, 61, 220, '7 ani garantie, fara prelungire', 'https://www.ikea.com/ro/ro/p/knoxhult-bucatarie-alb-s49180467/', 'IKEA of Sweden/Mikael Warnhammar', 'DFGhT');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'METOD/MAXIMERA', 419.55, 'Corp baza plita+cuptor+sertar, alb/Bodarp gri-verde, 60x60 cm', 60, 61, 88, null, 'https://www.ikea.com/ro/ro/p/metod-maximera-corp-baza-plita-cuptor-sertar-alb-bodarp-gri-verde-s19306816/', null, 'DFGhT');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'ASPINGE', 2388.15, 'Chicineta, negru/frasin, 120x60x202 cm', 120, 60, 202, '10 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/aespinge-chicineta-negru-frasin-s99478168/', null, 'DFGhT');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'LANDSKRONA', 2499.15, 'Canapea 3 locuri, Gunnared verde deschis/lemn', 204, 89, 78, '3 ani, prelungire 2 ani', 'https://www.ikea.com/ro/ro/p/landskrona-canapea-3-locuri-gunnared-verde-deschis-lemn-s39270326/', 'IKEA of Sweden/Tord Björklund', 'CghUI'); 
insert into PIESA_MOBILIER values(seq_produs.nextval, 'LANGARYD', 6499.99, 'Canapea 3locuri+sezlong, dreapta, Lejde gri/negru/lemn', 280, 135, 70, '5 ani, prelungire 2 ani', 'https://www.ikea.com/ro/ro/p/langaryd-canapea-3locuri-sezlong-dreapta-lejde-gri-negru-lemn-s19418734/', null, 'CghUI');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'KIVIK', 1449.55, 'Canapea 2 locuri, Tibbleby bej/gri', 190, 95, 83, '4 ani, fara prelungire', 'https://www.ikea.com/ro/ro/p/kivik-canapea-2-locuri-tibbleby-bej-gri-s09440599/', null, 'CghUI'); 
insert into PIESA_MOBILIER values(seq_produs.nextval, 'SODERHAMN', 1700.10, 'Sezlong, Viarp bej/maro', 93, 151, 83, '1 an, fara prelungire', 'https://www.ikea.com/ro/ro/p/soederhamn-sezlong-viarp-bej-maro-s89305620/', 'Ola Wihlborg','CghUI');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'ASKHOLMEN', 149.35, 'Masa pentru perete, exterior, Pliant maro inchis, 70x44 cm', 70, 44, 71, null, 'https://www.ikea.com/ro/ro/p/askholmen-masa-pentru-perete-exterior-pliant-maro-inchis-70557496/', 'Jon Karlsson', 'madYU');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'NAMMARO', 449.99, 'Banca cu spatar, exterior, maro deschis vopsit', 62, 78, 50, null, 'https://www.ikea.com/ro/ro/p/naemmaroe-banca-cu-spatar-exterior-maro-deschis-vopsit-30510302/', 'Nike Karlsson', 'madYU');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'DJUNGELSKOG', 129.90, 'Jucarie de plus, urs brun', 100, 50, 50, null, 'https://www.ikea.com/ro/ro/p/djungelskog-jucarie-de-plus-urs-brun-00402813/', 'Annie Hulden', 'kkRTy');
insert into PIESA_MOBILIER values(seq_produs.nextval, 'SATSUMAS', 249.99, 'Suport plante, bambus/alb, 70 cm', 84, 28, 70, null, 'https://www.ikea.com/ro/ro/p/satsumas-suport-plante-bambus-alb-90258156/', 'Carl Hagerling', 'eedaT');

select * from piesa_mobilier;

create table ADAUGA_COMANDA
(
    id_produs number(6),
    id_comanda number(10),
    cantitate int default 1,
    moment_timp timestamp default systimestamp,
    
    constraint pk_adauga_comanda primary key(id_produs, id_comanda),
    constraint fk_adauga_comanda_id_produs
        foreign key(id_produs)
        references PIESA_MOBILIER(id_produs)
        on delete cascade,
    constraint fk_adauga_comanda_id_comanda
        foreign key(id_comanda)
        references COMANDA(id_comanda)
        on delete cascade
);

select cl.id_client, cl.tip_client, cl.nume_firma, co.id_comanda, co.cod_postal, co.data_achizitie
from client cl
join comanda co on(cl.id_client = co.id_client)
where trunc(co.data_achizitie) != trunc(sysdate)
order by co.id_comanda;

drop table adauga_comanda;

insert into ADAUGA_COMANDA(id_produs, id_comanda) values(400023, 1000000008);
insert into ADAUGA_COMANDA(id_produs, id_comanda) values(400002, 1000000008);
insert into ADAUGA_COMANDA(id_produs, id_comanda, cantitate) values(400005, 1000000008, 2);
insert into ADAUGA_COMANDA(id_produs, id_comanda) values(400009, 1000000010);
insert into ADAUGA_COMANDA(id_produs, id_comanda) values(400010, 1000000014);
insert into ADAUGA_COMANDA(id_produs, id_comanda) values(400015, 1000000014);
insert into ADAUGA_COMANDA(id_produs, id_comanda) values(400006, 1000000022);
insert into ADAUGA_COMANDA(id_produs, id_comanda, cantitate) values(400017, 1000000022, 2);
insert into ADAUGA_COMANDA(id_produs, id_comanda, cantitate) values(400013, 1000000022, 3);
insert into ADAUGA_COMANDA(id_produs, id_comanda) values(400012, 1000000026);
insert into ADAUGA_COMANDA(id_produs, id_comanda, cantitate) values(400009, 1000000026, 4);
insert into ADAUGA_COMANDA(id_produs, id_comanda, cantitate) values(400008, 1000000026, 2);
insert into ADAUGA_COMANDA(id_produs, id_comanda, cantitate) values(400007, 1000000026, 5);
insert into ADAUGA_COMANDA values(400009, 1000000000, 1, '24-MAY-23 10:37:10');
insert into ADAUGA_COMANDA values(400012, 1000000000, 1, '24-MAY-23 10:40:30');
insert into ADAUGA_COMANDA values(400003, 1000000002, 2, '05-DEC-21 21:15:20');
insert into ADAUGA_COMANDA values(400011, 1000000002, 1, '05-DEC-21 21:51:30');
insert into ADAUGA_COMANDA values(400001, 1000000004, 1, '18-APR-24 19:22:35');
insert into ADAUGA_COMANDA values(400004, 1000000004, 3, '18-APR-24 20:00:10');
insert into ADAUGA_COMANDA values(400016, 1000000006, 1, '11-FEB-24 12:06:10');
insert into ADAUGA_COMANDA values(400014, 1000000012, 3, '14-MAY-24 17:09:45');
insert into ADAUGA_COMANDA values(400007, 1000000016, 5, '30-AUG-21 01:45:35');
insert into ADAUGA_COMANDA values(400018, 1000000018, 3, '19-NOV-23 18:07:10');
insert into ADAUGA_COMANDA values(400023, 1000000020, 3, '21-JUN-23 16:05:11');
insert into ADAUGA_COMANDA values(400022, 1000000020, 2, '21-JUN-23 16:35:50');
insert into ADAUGA_COMANDA values(400021, 1000000020, 1, '21-JUN-23 17:40:30');
insert into ADAUGA_COMANDA values(400008, 1000000024, 2, '09-FEB-24 09:23:30');

select * from adauga_comanda;

create table OFERTA
(
    id_produs number(6),
    data_inceput date default sysdate,
    data_sfarsit date not null,
    discount number(5, 2) not null, constraint verif_procent check(discount > 0 and discount < 100),
    
    constraint pk_oferta primary key(id_produs, data_inceput),
    constraint fk_oferta_id_produs
        foreign key(id_produs)
        references PIESA_MOBILIER(id_produs)
        on delete cascade
);

-- preturile reale pentru inregistrarile din comanda, fara aplicarea ofertelor
select co.id_comanda, co.data_achizitie, a.id_produs, a.cantitate, 
    p.pret as pret_per_produs,
    p.pret*a.cantitate as pret_produse,
    (
        select sum(p.pret*a.cantitate)
        from adauga_comanda a
        join piesa_mobilier p on(a.id_produs = p.id_produs)
        where a.id_comanda = co.id_comanda
    ) as pret_total
from comanda co
join adauga_comanda a on(co.id_comanda = a.id_comanda)
join piesa_mobilier p on(a.id_produs = p.id_produs)
order by co.id_comanda;

-- preturile reale pentru inregistrarile din comanda, cu aplicarea ofertelor
-- nu functioneaza corect total in momentul in care la nivelul unei comenzi sunt mai multe reduceri (le va aplica pe rand excluzandu-se reciproc, de aceea apar mai mult de un rezultat per comanda de acest fel in interogare)
-- conceptual, te ajuta sa nu fie nevoie sa calculezi manual pretul total dintr-o comnada si de a face update pe rand la campurile de pret de testare pentru fiecare inregistrare din comanda
-- cu materia din anul 2 sem 1 va putea exista un trigger care sa modifice campul pret din comanda in functie de produsele din adauga_comanda
-- pentru comanda cu id_comanda 1000000026, exsita 5*400007 + 4*400009 + 2*400008 + 1*400012 produse, insa calculeaza pretul redus in parte pentru 400007 si 400012, in loc sa fie aplicate reducerile simultan; similar se intampla si pentru comanda 1000000002
select co.id_comanda, co.data_achizitie, a.id_produs, a.cantitate, '(' || o.id_produs || ',' || o.data_inceput || ',' || o.data_sfarsit || ')' as pk_oferta_si_data_sfarsit,
    p.pret as pret_per_produs,
    round(p.pret*(100-o.discount)/100, 2) as pret_per_produs_discounted,
    p.pret*a.cantitate as pret_produse,
    round(p.pret*(100-o.discount)/100, 2)*a.cantitate as pret_produse_discounted,
    (
        select sum(p.pret*a.cantitate)
        from adauga_comanda a
        join piesa_mobilier p on(a.id_produs = p.id_produs)
        where a.id_comanda = co.id_comanda
    ) as pret_total,
    (
        select sum (
                    case
                    when p1.id_produs != o.id_produs then p1.pret*a1.cantitate
                    else round(p1.pret*(100-o.discount)/100, 2)*a1.cantitate
                    end
                    )
        from adauga_comanda a1
        join piesa_mobilier p1 on(a1.id_produs = p1.id_produs)
        where a1.id_comanda = co.id_comanda
    ) as pret_total_discounted
from comanda co
join adauga_comanda a on(co.id_comanda = a.id_comanda)
join piesa_mobilier p on(a.id_produs = p.id_produs)
join oferta o on(a.id_produs = o.id_produs)
where co.data_achizitie >= o.data_inceput and co.data_achizitie <= o.data_sfarsit
order by co.id_comanda;

drop table oferta;

--insert into OFERTA(id_produs, data_sfarsit, discount) values(400002, trunc(sysdate)+4, 24.99);
insert into OFERTA values(400002, '07-MAY-24', '11-MAY-24', 24.99);
--insert into OFERTA(id_produs, data_sfarsit, discount) values(400010, trunc(sysdate)+5, 12.99);
insert into OFERTA values(400010, '07-MAY-24', '12-MAY-24', 12.99);
--insert into OFERTA(id_produs, data_sfarsit, discount) values(400007, trunc(sysdate)+10, 29.99);-- buba 26
insert into OFERTA values(400007, '07-MAY-24', '17-MAY-24', 29.99);
--delete FROM OFERTA WHERE id_produs = 400007 and data_inceput = '07-MAY-24';
insert into OFERTA values(400011, '01-DECEMBER-21', '10-DECEMBER-21', 34.99);
insert into OFERTA values(400012, '24-MAY-23', sysdate, 39.99);
--DELETE FROM OFERTA WHERE id_produs = 400012 and data_inceput = '24-MAY-23';
insert into OFERTA values(400018, '19-NOVEMBER-23', '19-NOVEMBER-23', 49.99);
insert into OFERTA values(400007, '30-AUGUST-21', '10-SEPTEMBER-21', 19.99);
--DELETE FROM OFERTA WHERE id_produs = 400007 and data_inceput = '30-AUGUST-21';
insert into OFERTA values(400003, '04-DECEMBER-21', '10-DECEMBER-21', 20);-- buba 02

select * from oferta;

create table FURNIZOR
(
    id_furnizor varchar(4) primary key,
    nume varchar(35) unique,
    telefon char(12) unique
);

drop table FURNIZOR;

insert into FURNIZOR values('ADS', 'Mircea Oprea', '+40794267037');
insert into FURNIZOR values('AER3', 'Mihnea Vasilescu', '+40712347037');
insert into FURNIZOR values('67RT', 'Adriana Georgescu', '+40794234567');
insert into FURNIZOR values('OO03', 'Petru Coman', '+40791234567');
insert into FURNIZOR values('1S', 'Daniel Popara', '+40778967037');

create table MATERIE_PRIMA
(
    id_material number(10) primary key,
    tip_material varchar(25) not null, -- nu e unic deoarece mai multi furnizori pot aproviziona cu acelasi tip de material, avand aceeasi denumire
    unitate_masura varchar(17) not null, constraint verif_masura check (unitate_masura in ('metru patrat', 'decimetru patrat', 'centimetru patrat', 'milimetru patrat', 'metru cub', 'decimetru cub', 'centimetru cub', 'milimetru cub', 'kilogram', 'gram')),
    pret_unitate decimal not null,
    id_furnizor varchar(4) not null, -- cardinalitate maxima M (not unique) inspre MATERIE_PRIMA, cardinalitate minima 1 (not null) inspre FURNIZOR
    
    constraint fk_materie_prima_id_furnizor
        foreign key(id_furnizor)
        references FURNIZOR(id_furnizor)
        on delete cascade
);

drop table materie_prima;

select seq_material.nextval
from dual;

drop sequence seq_material;

insert into MATERIE_PRIMA values(seq_material.currval, 'MDF', 'metru patrat', 20.37, 'OO03');
insert into MATERIE_PRIMA values(seq_material.nextval, 'MDF', 'centimetru patrat', 5.47, '1S');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Plastic', 'metru cub', 2.37, 'AER3');
insert into MATERIE_PRIMA values(seq_material.nextval, 'PAL', 'metru patrat', 7.89, '1S');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Vopsea', 'decimetru cub', 3.44, '1S');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Lemn masiv', 'metru patrat', 50.99, '67RT');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Spuma poliuretanica', 'centimetru cub', 12.34, '1S');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Otel galvanizat', 'kilogram', 6.78, '1S');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Hartie laminata', 'kilogram', 3.21, 'ADS');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Lac acrilic', 'gram', 1.32, 'OO03');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Otel galvanizat', 'kilogram', 5.47, 'ADS');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Poliester', 'kilogram', 10.32, '67RT');
insert into MATERIE_PRIMA values(seq_material.nextval, 'Bumbac', 'centimetru cub', 5.47, 'ADS');

create table PRODUSA_DIN
(
    id_produs number(6),
    id_material number(10),
    unitati int,
    
    constraint pk_produsa_din primary key(id_produs, id_material),
    constraint fk_produsa_din_id_produs
        foreign key(id_produs)
        references PIESA_MOBILIER(id_produs)
        on delete cascade,
    constraint fk_produsa_din_id_material
        foreign key(id_material)
        references MATERIE_PRIMA(id_material)
        on delete cascade
);

drop table produsa_din;

insert into PRODUSA_DIN values(400000, 5000000003, 6);
insert into PRODUSA_DIN values(400000, 5000000006, 3);
insert into PRODUSA_DIN values(400000, 5000000009, 10);
insert into PRODUSA_DIN values(400000, 5000000012, 1);
insert into PRODUSA_DIN values(400001, 5000000003, 6);
insert into PRODUSA_DIN values(400001, 5000000009, 5);
insert into PRODUSA_DIN values(400001, 5000000015, 3);
insert into PRODUSA_DIN values(400001, 5000000018, 1);
insert into PRODUSA_DIN values(400001, 5000000030, 4);
insert into PRODUSA_DIN values(400002, 5000000021, 2);
insert into PRODUSA_DIN values(400008, 5000000033, 3);
insert into PRODUSA_DIN values(400008, 5000000018, 5);
insert into PRODUSA_DIN values(400008, 5000000006, 2);
insert into PRODUSA_DIN values(400003, 5000000006, 1);
insert into PRODUSA_DIN values(400004, 5000000000, 4);
insert into PRODUSA_DIN values(400004, 5000000024, 1);
insert into PRODUSA_DIN values(400004, 5000000009, 3);
insert into PRODUSA_DIN values(400004, 5000000006, 6);
insert into PRODUSA_DIN values(400011, 5000000027, 2);
insert into PRODUSA_DIN values(400017, 5000000030, 3);
insert into PRODUSA_DIN values(400017, 5000000033, 6);
insert into PRODUSA_DIN values(400017, 5000000036, 2);

create table STOC
(
    id_stoc char(5),
    data_aprovizionare date default sysdate,
    
    constraint pk_stoc primary key(id_stoc, data_aprovizionare)
);

drop table stoc;

insert into STOC values('AGFJK', '01-DECEMBER-21');
insert into STOC values('DFGTY', '14-MAY-24');
insert into STOC values('BSJUY', '18-OCTOBER-22');
insert into STOC values('RLJFG', '12-AUGUST-19');
insert into STOC values('OUNDS', '15-DECEMBER-24');
insert into STOC values('AGFJK', '13-APRIL-22');
insert into STOC values('RLJFG', '02-MARCH-19');

create table APROVIZIONEAZA
(
    id_magazin varchar(4),
    id_produs number(6),
    id_stoc char(5),
    data_aprovizionare date,
    cantitate int,
    
    constraint pk_aprovizioneaza primary key(id_magazin, id_produs, id_stoc, data_aprovizionare),
    constraint fk_aprovizioneaza_id_produs
        foreign key(id_produs)
        references PIESA_MOBILIER(id_produs)
        on delete cascade,
    constraint fk_aprovizioneaza_id_magazin
        foreign key(id_magazin)
        references MAGAZIN(id_magazin)
        on delete cascade,
    constraint fk_aprovizioneaza_id_stoc_data_aprovizionare
        foreign key(id_stoc, data_aprovizionare)
        references STOC(id_stoc, data_aprovizionare)
        on delete cascade
);

drop table aprovizioneaza;

insert into APROVIZIONEAZA values('56GH', 400009, 'AGFJK', '01-DEC-21', 5);
insert into APROVIZIONEAZA values('10UP', 400015, 'BSJUY', '18-OCT-22', 21);
insert into APROVIZIONEAZA values('10UP', 400005, 'BSJUY', '18-OCT-22', 137);
insert into APROVIZIONEAZA values('09OP', 400009, 'RLJFG', '12-AUG-19', 99);
insert into APROVIZIONEAZA values('234Y', 400021, 'RLJFG', '12-AUG-19', 23);
insert into APROVIZIONEAZA values('45E', 400010, 'RLJFG', '12-AUG-19', 4);
insert into APROVIZIONEAZA values('10UP', 400003, 'OUNDS', '15-DEC-24', 78);
insert into APROVIZIONEAZA values('234Y', 400017, 'OUNDS', '15-DEC-24', 35);
insert into APROVIZIONEAZA values('09OP', 400019, 'AGFJK', '13-APR-22', 35);
insert into APROVIZIONEAZA values('4DF', 400023, 'AGFJK', '13-APR-22', 27);
insert into APROVIZIONEAZA values('7TY6', 400017, 'RLJFG', '02-MAR-19', 14);
insert into APROVIZIONEAZA values('56GH', 400000, 'BSJUY', '18-OCT-22', 67);




