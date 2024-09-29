drop sequence seq_client;
drop sequence seq_agent;
drop sequence seq_comanda;
drop sequence seq_tranzactie;
drop sequence seq_material;
drop sequence seq_produs;

drop table adauga_comanda cascade constraints;
drop table piesa_mobilier cascade constraints;
drop table categorie cascade constraints;
drop table comanda cascade constraints;
drop table adresa cascade constraints;
drop table agent_vanzari cascade constraints;
drop table aprovizioneaza cascade constraints;
drop table produsa_din cascade constraints;
drop table client cascade constraints;
drop table client_fizic cascade constraints;
drop table client_online cascade constraints;
drop table furnizor cascade constraints;
drop table magazin cascade constraints;
drop table materie_prima cascade constraints;
drop table stoc cascade constraints;
drop table tranzactie cascade constraints;
drop table oferta cascade constraints;

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

select seq_client.nextval
from dual;
select seq_agent.nextval
from dual;
select seq_comanda.nextval
from dual;
select seq_tranzactie.nextval
from dual;
select seq_produs.nextval
from dual;
select seq_material.nextval
from dual;

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

create table ADRESA
(
    cod_postal number(6) primary key,
    oras varchar(25) not null,
    tara varchar(25) not null,
    strada varchar(70)
);

create table MAGAZIN
(
    id_magazin varchar(4) primary key,
    telefon char(12) unique,
    centru_ridicare smallint, constraint verif_centru_bool check(centru_ridicare in (0, 1)),
    cod_postal number(6) not null unique, -- relatie one-to-one: cardinalitate maxima 1 (unique) inspre MAGAZIN, cardinalitate minima 1 (not null) inspre ADRESA
    
    constraint fk_magazin_cod_postal
        foreign key(cod_postal)
        references ADRESA(cod_postal)
        on delete set null
);

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

create table COMANDA
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

create table CATEGORIE
(
    id_categorie char(5) primary key,
    nume varchar(50) unique
);

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

create table FURNIZOR
(
    id_furnizor varchar(4) primary key,
    nume varchar(35) unique,
    telefon char(12) unique
);

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

create table STOC
(
    id_stoc char(5),
    data_aprovizionare date default sysdate,
    
    constraint pk_stoc primary key(id_stoc, data_aprovizionare)
);

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

alter session set nls_date_format='DD-MON-RR';
alter session set nls_timestamp_format='DD-MON-RR HH24:MI:SS';
select systimestamp from dual;

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

insert into CLIENT_ONLINE values(10000000, 'alexandrescu_a@gmail.com', null, 'Andra');
insert into CLIENT_ONLINE values(10000020, 'andreea.badea_@retailexpress.outlook.com', 'Badea', 'Andreea');
insert into CLIENT_ONLINE values(10000030, 'alinapopescu1997@gmail.com', 'Popescu', 'Alina');
insert into CLIENT_ONLINE values(10000070, 'dan_cristescu@manager.buytoday.ro', 'Cristescu', 'Dan');
insert into CLIENT_ONLINE values(10000080, 'alex_dragos@gmail.com', null, 'Alexandru');
insert into CLIENT_ONLINE values(10000090, 'maria_pestritu@alphabank.outlook.ro', 'Pestritu', 'Maria');

insert into CLIENT_FIZIC values(10000010, '+40772937066');
insert into CLIENT_FIZIC values(10000040, '+40791816617');
insert into CLIENT_FIZIC values(10000050, '+40716423256');
insert into CLIENT_FIZIC values(10000060, '+40756246891');
insert into CLIENT_FIZIC values(10000100, '+40752789141');

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

insert into MAGAZIN values('A42D', '+40789947067', 0, 032266);
insert into MAGAZIN values('09OP', '+40769937527', 0, 307160);
insert into MAGAZIN values('45E', '+40781550674', 0, 013696);
insert into MAGAZIN values('234Y', '+40752356779', 1, 550088);
insert into MAGAZIN values('RT56', '+40742622774', 1, 400436);
insert into MAGAZIN values('7TY6', '+40782378375', 1, 707252);
insert into MAGAZIN values('10UP', '+40792378237', 1, 900147);
insert into MAGAZIN values('56GH', '+40721729803', 1, 500238);
insert into MAGAZIN values('4DF', '+40762751657', 1, 410224);

insert into AGENT_VANZARI values(seq_agent.currval, 'Adela', 'Angelescu', '19-MARCH-22', '+40785267887', 'A42D');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Madalin', 'Stroe', '09-FEBRUARY-21', '+40790380926', 'A42D');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Andrei', 'Comanescu', '18-MAY-21', '+40799080928', '45E');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Mircea', 'Istrate', '15-APRIL-20', '+40728767134', '09OP');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Daria', 'Marculescu', '17-FEBRUARY-21', '+40754678239', '45E');
insert into AGENT_VANZARI values(seq_agent.nextval, 'Daniela', 'Ignat', '10-OCTOBER-23', '+40754156824', null);
insert into AGENT_VANZARI values(seq_agent.nextval, 'Mihai', 'Radulescu', '07-JANUARY-24', '+40778567230', null);

insert into COMANDA values(seq_comanda.currval, 793.82, '24-MAY-23', 10020, 10000040, 040394);
insert into COMANDA values(seq_comanda.nextval, 1574.51, '05-DECEMBER-21', 10000, 10000100, null);
insert into COMANDA values(seq_comanda.nextval, 3460.05, '18-APRIL-24', 10000, 10000080, 707252);
insert into COMANDA values(seq_comanda.nextval, 2388.15, '11-FEBRUARY-24', null, 10000080, 700259);
insert into COMANDA values(seq_comanda.nextval, 679.3, '28-MAY-24', null, 10000050, null);
insert into COMANDA values(seq_comanda.nextval, 349.75, '29-MAY-24', null, 10000050, null);
insert into COMANDA values(seq_comanda.nextval, 5667.75, '14-MAY-24', null, 10000030, 106100);
insert into COMANDA values(seq_comanda.nextval, 3853.05, '28-MAY-24', 10025, 10000000, 400436);
insert into COMANDA values(seq_comanda.nextval, 919.7, '30-AUGUST-21', 10030, 10000020, 900147);
insert into COMANDA values(seq_comanda.nextval, 9751.92, '19-NOVEMBER-23', 10005, 10000010, null);
insert into COMANDA values(seq_comanda.nextval, 1439.03, '21-JUNE-23', 10015, 10000060, null);
insert into COMANDA values(seq_comanda.nextval, 8144.95, '28-MAY-24', 10005, 10000070, 550088);
insert into COMANDA values(seq_comanda.nextval, 1199.98, '09-FEBRUARY-24', 10020, 10000090, 010566);
insert into COMANDA values(seq_comanda.nextval, 4192.55, '28-MAY-24', null, 10000090, 010566);
insert into COMANDA values(seq_comanda.nextval, 5349.75, '13-MAY-2018', null, 10000040, null);

insert into TRANZACTIE values(seq_tranzactie.currval, 'card', 'in procesare', 1000000000);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'cash', 'aprobata', 1000000002);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000004);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'respinsa', 1000000006);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'cash', 'aprobata', 1000000008);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'in procesare', 1000000010);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000012);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'in procesare', 1000000014);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000016);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000018);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'cash', 'aprobata', 1000000020);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'respinsa', 1000000022);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000024);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000026);
insert into TRANZACTIE values(seq_tranzactie.nextval, 'card', 'aprobata', 1000000028);

insert into CATEGORIE values('ASDRT', 'Accesorii');
insert into CATEGORIE values('PASDU', 'Paturi');
insert into CATEGORIE values('GHJeR', 'Rafturi, dulapuri si unitati de depozitare');
insert into CATEGORIE values('DFGhT', 'Unitati de dulapuri pentru bucatarie');
insert into CATEGORIE values('SDsRK', 'Scaune, mese si birouri');
insert into CATEGORIE values('madYU', 'Mobilier de exterior');
insert into CATEGORIE values('CghUI', 'Canapele si fotolii');
insert into CATEGORIE values('kkRTy', 'Jucarii si jocuri');
insert into CATEGORIE values('eedaT', 'Gradina');

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

insert into ADAUGA_COMANDA values(400023, 1000000008, 1, '28-MAY-24 10:20:00');
insert into ADAUGA_COMANDA values(400002, 1000000008, 1, '28-MAY-24 10:20:03');
insert into ADAUGA_COMANDA values(400005, 1000000008, 2, '28-MAY-24 10:20:04');
insert into ADAUGA_COMANDA values(400009, 1000000010, 1, '28-MAY-24 10:20:06');
insert into ADAUGA_COMANDA values(400010, 1000000014, 1, '28-MAY-24 10:20:08');
insert into ADAUGA_COMANDA values(400015, 1000000014, 1, '28-MAY-24 10:20:09');
insert into ADAUGA_COMANDA values(400006, 1000000022, 1, '28-MAY-24 10:20:11');
insert into ADAUGA_COMANDA values(400017, 1000000022, 2, '28-MAY-24 10:20:12');
insert into ADAUGA_COMANDA values(400013, 1000000022, 3, '28-MAY-24 10:20:14');
insert into ADAUGA_COMANDA values(400012, 1000000026, 1, '28-MAY-24 10:20:16');
insert into ADAUGA_COMANDA values(400009, 1000000026, 4, '28-MAY-24 10:20:17');
insert into ADAUGA_COMANDA values(400008, 1000000026, 2, '28-MAY-24 10:20:20');
insert into ADAUGA_COMANDA values(400007, 1000000026, 5, '28-MAY-24 10:20:21');
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
insert into ADAUGA_COMANDA values(400020, 1000000028, 3, '13-MAY-18 10:09:45');
insert into ADAUGA_COMANDA values(400005, 1000000028, 1, '13-MAY-18 11:09:45');

insert into OFERTA values(400002, '28-MAY-24', '01-JUNE-24', 24.99);
insert into OFERTA values(400010, '28-MAY-24', '02-JUNE-24', 12.99);
insert into OFERTA values(400007, '28-MAY-24', '07-JUNE-24', 29.99);
insert into OFERTA values(400012, '23-MAY-23', '29-MAY-24', 39.99);
insert into OFERTA values(400011, '01-DECEMBER-21', '10-DECEMBER-21', 34.99);
insert into OFERTA values(400018, '19-NOVEMBER-23', '19-NOVEMBER-23', 49.99);
insert into OFERTA values(400007, '30-AUGUST-21', '10-SEPTEMBER-21', 19.99);
insert into OFERTA values(400003, '04-DECEMBER-21', '10-DECEMBER-21', 20);

insert into FURNIZOR values('ADS', 'Mircea Oprea', '+40794267037');
insert into FURNIZOR values('AER3', 'Mihnea Vasilescu', '+40712347037');
insert into FURNIZOR values('67RT', 'Adriana Georgescu', '+40794234567');
insert into FURNIZOR values('OO03', 'Petru Coman', '+40791234567');
insert into FURNIZOR values('1S', 'Daniel Popara', '+40778967037');

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

insert into STOC values('AGFJK', '01-DECEMBER-21');
insert into STOC values('DFGTY', '14-MAY-24');
insert into STOC values('BSJUY', '18-OCTOBER-22');
insert into STOC values('RLJFG', '12-AUGUST-19');
insert into STOC values('OUNDS', '15-DECEMBER-24');
insert into STOC values('AGFJK', '13-APRIL-22');
insert into STOC values('RLJFG', '02-MARCH-19');

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

--1)
--a)
-- sa se afiseze detaliile unei comenzi (id comanda, data achizitiei, numele produsului, descrierea lui, cantitatea per comanda si numele categoriei careia ii apartine) in care cantitatea cumparata este mai mare decat un average de cerere pentru acea categorie, produsul fiind cumparat in mai multe comenzi individuale. se va sorta dupa nume.
select co.id_comanda, co.data_achizitie, p.nume, p.descriere, a.cantitate, c.nume, -- se motiveaza join-ul lui comanda cu adauga_comanda pt ca se doreste in select a se cunoaste detalii specifice unei comenzi
(   select count(distinct a2.id_comanda) -- subcerere corelata: nr de comenzi distincte pentru acelasi produs (adaugat la mai multe comenzi)
    from adauga_comanda a2
    where p.id_produs = a2.id_produs
) as nr_comenzi_dif
from comanda co
join adauga_comanda a on(co.id_comanda = a.id_comanda)
join piesa_mobilier p on(a.id_produs = p.id_produs)
join categorie c on(p.id_categorie = c.id_categorie) -- categoria curenta a unui produs e folosita ca reper in subcererea corelata urm
where a.cantitate > (   select avg(a1.cantitate) -- cantitatea curenta a produsului la nivelul tabelei adauga_comanda sa fie mai mare decat un average
                        from adauga_comanda a1
                        join piesa_mobilier p1 on(a1.id_produs = p1.id_produs) 
                        where p1.id_categorie = c.id_categorie  )
and exists (    select 1 -- subcerere corelata pt clauza exists: produs care a fost cumparat in cel putin doua comenzi
                from adauga_comanda a1
                where p.id_produs = a1.id_produs
                group by a1.id_produs -- grupare dupa produs
                having count(distinct a1.id_comanda) >= 2) -- aparitii distincte ale unei comenzi (constrangere model: la o comanda la care a fost adaugat un produs, nu exista posibilitatea de a-l adauga inca o data la comanda)
order by 3; -- sortare

--2)
--b)
-- sa se afiseze detalii despre vanzarile dintr-o luna pentru care totalul vanzarilor online (din acea luna), vazute ca venit, sa depaseasca pe cel al vanzarilor realizate fizic. sa se creeze tabele auxiliare care sa verifice acest lucru
select luna_vanzari_online.data_vanzare, luna_vanzari_online.total_vanzari_online, luna_vanzari_online.nr_comenzi_online, luna_vanzari_fizic.total_vanzari_fizic, luna_vanzari_fizic.nr_comenzi_fizic--, sum(co.pret) as total_vanzari_luna
from -- prefer ca subcererea aceea necorelata sa nu fie direct in clauza from, pentru a evita un produs cartezian
(   select to_char(co.data_achizitie, 'Mon') AS data_vanzare, -- doar pentru a corela la conditia de join cu luna corespunzatoare curenta
    sum( -- fara case, adica folosind sum(co.pret) impreuna cu where cl.tip_client = 'online' e incorect in cazul in care existe luni in care se realizeaza cumparaturi numai online sau fizic
        case 
            when cl.tip_client = 'online' then 1 
            else 0
        end
        ) as nr_comenzi_online,
    sum(
        case 
            when cl.tip_client = 'online' then co.pret 
            else 0
        end
        ) as total_vanzari_online
    from comanda co
    join client cl on(co.id_client = cl.id_client) -- pt a avea acces la tip_client
    group by to_char(co.data_achizitie, 'Mon') -- grupare in fct de luna
) luna_vanzari_online
join
(   select to_char(co.data_achizitie, 'Mon') AS data_vanzare,
    sum(
        case 
            when cl.tip_client = 'fizic' then 1 
            else 0
        end
        ) as nr_comenzi_fizic,
    sum(
        case
            when cl.tip_client = 'fizic' then co.pret 
            else 0
        end
        ) as total_vanzari_fizic
    from comanda co
    join client cl on(co.id_client = cl.id_client)
    group by to_char(co.data_achizitie, 'Mon')
) luna_vanzari_fizic on(luna_vanzari_online.data_vanzare = luna_vanzari_fizic.data_vanzare)
where luna_vanzari_online.total_vanzari_online > luna_vanzari_fizic.total_vanzari_fizic -- venit mai mare online obtinut luna respectiva decat fizic
group by luna_vanzari_online.data_vanzare, luna_vanzari_online.total_vanzari_online, luna_vanzari_online.nr_comenzi_online, luna_vanzari_fizic.total_vanzari_fizic, luna_vanzari_fizic.nr_comenzi_fizic;

--prea easy si nu respecta subpunctul b)
/*select to_char(data_achizitie, 'Month') as data_vanzare, sum(pret) as total_vanzari_luna
from comanda
group by to_char(data_achizitie, 'Month');

select to_char(co.data_achizitie, 'Mon') as data_vanzare,
(   select count(*)
    from comanda co2
    join client cl2 on(co2.id_client = cl2.id_client)
    where cl2.tip_client = 'online' and to_char(co.data_achizitie, 'Mon') = to_char(co2.data_achizitie, 'Mon')
) as nr_comenzi_online,
(
    select count(*)
    from comanda co2
    join client cl2 on(co2.id_client = cl2.id_client)
    where cl2.tip_client = 'fizic' and to_char(co.data_achizitie, 'Mon') = to_char(co2.data_achizitie, 'Mon')
)as nr_comenzi_fizic,
sum(co.pret) as total_vanzari_luna,
sum(
    case 
        when cl.tip_client = 'online' then co.pret 
        else 0
    end
    ) as total_online_vanzari_luna,
sum(
    case 
        when cl.tip_client = 'fizic' then co.pret 
        else 0
    end
    ) as total_fizic_vanzari_luna
from comanda co
join client cl on(co.id_client = cl.id_client) 
group by to_char(co.data_achizitie, 'Mon');*/

-- gresit nu e acelasi lucru
/*select to_char(co.data_achizitie, 'Mon'), sum(co.pret) as total_vanzari_luna, luna_vanzari_online.total_vanzari_online, luna_vanzari_online.nr_comenzi_online, luna_vanzari_fizic.total_vanzari_fizic, luna_vanzari_fizic.nr_comenzi_fizic
from comanda co
join 
(   select to_char(co.data_achizitie, 'Mon') AS data_vanzare, sum(co.pret) as total_vanzari_online, count(co.id_comanda) as nr_comenzi_online
    from comanda co
    join client cl on(co.id_client = cl.id_client)
    where cl.tip_client = 'online'
    group by to_char(co.data_achizitie, 'Mon')
) luna_vanzari_online on to_char(co.data_achizitie, 'Mon') = luna_vanzari_online.data_vanzare
join
(   select to_char(co.data_achizitie, 'Mon') AS data_vanzare, sum(co.pret) as total_vanzari_fizic, count(co.id_comanda) as nr_comenzi_fizic
    from comanda co
    join client cl on(co.id_client = cl.id_client)
    where cl.tip_client = 'fizic'
    group by to_char(co.data_achizitie, 'Mon')
) luna_vanzari_fizic on(luna_vanzari_online.data_vanzare = luna_vanzari_fizic.data_vanzare)
where luna_vanzari_online.total_vanzari_online > luna_vanzari_fizic.total_vanzari_fizic
group by to_char(co.data_achizitie, 'Mon'), luna_vanzari_online.total_vanzari_online, luna_vanzari_online.nr_comenzi_online, luna_vanzari_fizic.total_vanzari_fizic, luna_vanzari_fizic.nr_comenzi_fizic
order by 1;*/

--3)
--b), c)
-- sa se afiseze detalii legate de costul per piesa de mobilier pentru care costul de productie este mai mare de 80% din un average al costului de productie din toate categoriile (insemnand ca un cost de productie al unei categorii este totalul costurilor de productie al tutoror produselor ce se incadreaza in acea categorie, iar average-ul e suma tututor costurilor de productie de categorii impartita la nr categoriilor). se vor folosi informatiile despre nr de unitati din fiecare material si costul unei unitati 
select p.id_produs, p.nume, p.id_categorie, sum(to_number(m.pret_unitate)*to_number(p_d.unitati)) as cost_total_productie_per_produs, p.pret-sum(to_number(m.pret_unitate)*to_number(p_d.unitati)) as profit
from piesa_mobilier p
join produsa_din p_d on(p.id_produs = p_d.id_produs) -- pt a accesa nr de unitati in productia unei piese de mobilier
join materie_prima m on(p_d.id_material = m.id_material) -- pt a accesa costul unei unitati din materia prima
group by p.id_produs, p.nume, p.id_categorie, p.pret -- grupare dupa produse numai
having sum(to_number(m.pret_unitate)*to_number(p_d.unitati)) > 0.8 * (
                                                                            -- se vor calcula in functie de categorie sumele costurilor de productie
                                                                            select avg(costuri_productie_categorie.cost_total_productie_produse) -- un average la nivelul tuturor categoriilor
                                                                            from (
                                                                                -- gruparea produselor in functie de categorie si calculul sumei costurilor de productie in total per categorie
                                                                                -- echivalent cu a gasi costul de productie al unei categorii
                                                                                select c.id_categorie, sum(to_number(m.pret_unitate) * to_number(p_d.unitati)) as cost_total_productie_produse
                                                                                from categorie c
                                                                                join piesa_mobilier p on c.id_categorie = p.id_categorie
                                                                                join produsa_din p_d on p.id_produs = p_d.id_produs
                                                                                join materie_prima m on p_d.id_material = m.id_material
                                                                                group by c.id_categorie -- gruparea nu merge fara a fi mentionat c.id_categorie in clauza de select
                                                                            ) costuri_productie_categorie
                                                                        )
order by 4 desc; -- descrescator dupa pret productie piesa

-- putin mai mult gresit foarte gresit
/*select c.id_categorie, avg(to_number(m.pret_unitate) * to_number(p_d.unitati)) as average_cost_productie_categorie
from categorie c
join piesa_mobilier p on(c.id_categorie = p.id_categorie)
join produsa_din p_d on(p.id_produs = p_d.id_produs)
join materie_prima m on(p_d.id_material = m.id_material)
group by c.id_categorie;*/
-- like idea as one wise man said once
/*select p.id_produs, p.nume, sum(to_number(m.pret_unitate) * to_number(p_d.unitati)) as cost_total_productie_per_produs
from piesa_mobilier p
join produsa_din p_d on(p.id_produs = p_d.id_produs)
join materie_prima m on(p_d.id_material = m.id_material)
group by p.id_produs, p.nume
order by cost_total_productie_per_produs desc;*/
  
--4)
--f)
-- sa se afiseze detalii in legatura cu preturile reale pentru fiecare comanda, cu aplicarea ofertelor. daca exista mai produse intr-o comanda care sunt reduse, se vor afisa detaliile comenzii pentru fiecare reducere in parte, insemnand ca nu se poate aplica decat o reducere, indiferent de numarul de produse la oferta.
-- cuvant inainte:
-- exista o constrangere a modelului: la nivelul unei comenzi nu pot exista mai multe produse care sa fie reduse prin oferte diferite care sunt in vigoare in acelasi timp in timpul achizitiei comenzii (le va aplica pe rand excluzandu-se reciproc, de aceea apar mai mult de un rezultat per comanda de acest fel in interogare)
-- pentru comanda cu id_comanda 1000000026, exista 5*400007 + 4*400009 + 2*400008 + 1*400012 produse, insa calculeaza pretul redus in parte pentru 400007 si 400012, in loc sa fie aplicate reducerile simultan; similar se intampla si pentru comanda 1000000002
with COMENZI_DISCOUNTED as(
    select co.id_client, co.id_comanda, co.data_achizitie, a.id_produs, a.cantitate, '(' || o.id_produs || ',' || o.data_inceput || ',' || o.data_sfarsit || ')' as pk_oferta_si_data_sfarsit,
    p.pret as pret_per_produs,
    round(p.pret*(100-o.discount)/100, 2) as pret_per_produs_discounted, -- se afiseaza doar primele 2 zecimale dupa virgula
    p.pret*a.cantitate as pret_produse,
    round(p.pret*(100-o.discount)/100, 2)*a.cantitate as pret_produse_discounted,
    ( -- subcerere corelata: pt a calcula pretul total al fiecarei comenzi, fara a tine cont de oferte, ce ar reprezenta suma tuturor produselor (per produs: cantitate * pret)
        select sum(p1.pret*a1.cantitate)
        from adauga_comanda a1
        join piesa_mobilier p1 on(a1.id_produs = p1.id_produs)
        where a1.id_comanda = co.id_comanda -- e corelata cu o comanda curenta
    ) as pret_total,
    (
        select sum ( -- combinatie intre pret_produse si pret_produse_discounted
                    case
                        when p1.id_produs != o.id_produs then p1.pret*a1.cantitate -- produsul nu e la oferta
                        else round(p1.pret*(100-o.discount)/100, 2)*a1.cantitate -- e la oferta
                    end
                    )
        from adauga_comanda a1
        join piesa_mobilier p1 on(a1.id_produs = p1.id_produs)
        where a1.id_comanda = co.id_comanda -- e corelata cu o comanda curenta
    ) as pret_total_discounted
    from comanda co
    join adauga_comanda a on(co.id_comanda = a.id_comanda) -- pt a accesa cantitatea
    join piesa_mobilier p on(a.id_produs = p.id_produs) -- pt a accesa pretul
    join oferta o on(a.id_produs = o.id_produs) -- pt a corela oferta in subcererea corelata pret_total_discounted
    where co.data_achizitie>=o.data_inceput and co.data_achizitie<=o.data_sfarsit -- oferta in vigoare
    order by co.id_comanda
)
-- mai multe informatii
select co_d.id_client, co_d.id_comanda, co_d.id_produs, co_d.cantitate, p.nume, p.descriere, co_d.data_achizitie, co_d.pk_oferta_si_data_sfarsit, co_d.pret_per_produs, co_d.pret_per_produs_discounted, co_d.pret_produse, co_d.pret_produse_discounted, co_d.pret_total, co_d.pret_total_discounted, co_d.pret_total - co_d.pret_total_discounted as diferenta_pret
from comenzi_discounted co_d
join piesa_mobilier p on(co_d.id_produs = p.id_produs)
join oferta o on(co_d.id_produs = o.id_produs and co_d.data_achizitie>=o.data_inceput and co_d.data_achizitie<=o.data_sfarsit);

--5)
--d), e)
-- sa se afiseze detalii legate de analiza clientilor, in care sunt determinate date precum: anul primei comenzi realizate, data cand ar trebui trimis un email (pt clienti online) sau un mesaj (pt clienti fizici) pentru a le aminti sa faca o recenzie dupa trei luni de la prima comanda. in plus, se vor afisa statusul clientului (insemnand daca este persoana juridica sau nu), fidelitatea (prin raportare la prima comanda) si daca a optat pentru livrare referitor la ultima comanda realizata
select cl.id_client, to_char(min(co.data_achizitie), 'YYYY') as an_prima_comanda, min(co.data_achizitie) as data_prima_comanda, add_months(min(co.data_achizitie), 3) as reminder_recenzie,
case -- un client este reprezentantul unei firme daca e persoana juridica, insemnand ca atributul nume_firma sa fie completat
    when cl.nume_firma is not null then replace(upper('reprezentant Unknown'), upper('Unknown'), nvl(cl.tip_client, '')) || ', ' || initcap(cl.nume_firma)
    else 'Persoana fizica'
end as reprezentant,
decode(
        trunc(months_between(sysdate, min(co.data_achizitie))/12),
        0, 'Client nou', 1, 'Client de aproximativ 1 an', 'Client fidel de mai mult de 2 ani' 
    ) as fidelitate,
nvl(    -- doresc sa gasesc codul postal al ultimei comenzi realizate, daca el e null, adica campul nu e completat, inseamna ca acel client nu a optat pentru livrare
        (   -- ar fi fost gresit daca faceam max(co1.cod_postal) pt ca ar fi intervenit compararea lexicografica a codurilor postale
            select to_char(co1.cod_postal)
            from comanda co1
            where co1.id_client = cl.id_client
            and co1.data_achizitie = ( -- doar pt a selecta ultima comanda (cea mai recenta achizitie)
                                    select max(co2.data_achizitie)
                                    from comanda co2
                                    where co2.id_client = cl.id_client -- corelare la nivel de client
                                )
        ), 'Comanda fara livrare') as tip_ultima_comanda
from comanda co
join client cl on co.id_client = cl.id_client
group by cl.id_client, cl.tip_client, cl.nume_firma -- ultimele doua conditii de grupare sunt din cauza acelui case din clauza de select de la inceputul exercitiului
order by 2; -- crescator dupa data comenzii

-- 13
delete from agent_vanzari
where id_angajat in (   select id_angajat
                        from agent_vanzari
                        where id_magazin is null )
or id_angajat not in (  select id_angajat
                        from comanda
                        where id_angajat is not null    );
rollback;

delete from stoc
where id_stoc in (  select distinct(s.id_stoc)--, a.cantitate
                    from stoc s
                    join aprovizioneaza a on s.id_stoc = a.id_stoc
                    where a.cantitate < 0.5 * ( select avg(cantitate)
                                                from aprovizioneaza )
                );        
rollback;

update adauga_comanda
set moment_timp = moment_timp + 2
where id_comanda in (   select id_comanda
                        from comanda
                        where to_char(data_achizitie, 'DD-MON') = '28-MAY'  );
rollback;

-- probabil fac ex 15

-- la top-n folosesc moment_timp din adauga_produs
-- produsele cele mai vandute
with top_vanzari_categorie as (
    select c.nume as nume_categorie, p.nume as nume_produs, sum(a.cantitate) as total_vanzari_categorie
    from adauga_comanda a
    join piesa_mobilier p on(a.id_produs = p.id_produs)
    join categorie c on(p.id_categorie = c.id_categorie)
    where to_char(a.moment_timp, 'YYYY') = 2024
    group by c.nume, p.nume
    order by 3 desc
)
select nume_categorie, nume_produs, total_vanzari_categorie
from top_vanzari_categorie
where rownum <= 5;

-- sa se afiseze toate id-urile comenzilor in care exista numai piese de mobilier care au garantie de 1 an (fara a considera prelungirea)
/*select distinct aux1.id_comanda -- toate comenzile distincte
from adauga_comanda aux1
where not exists -- false: filtreaza toate id_comanda care nu respecta subcererea urm
(   -- toate produsele pentru care garantia este de 1 an (indiferent de posibilitatea de prelungire a garantiei)
    select p.id_produs
    from piesa_mobilier p
    where nvl(to_number(substr(garantie, 1, 1)), 0) = 1 -- nr de ani dintr-o garantie neprelungita e chiar prima litera din stringul din campul garantie
    and not exists -- produsul curent filtrat nu exista in adauga_comanda in care id_comanda este aceeasi valoare
        (   -- verifica daca id_produsul p anterior determinat exista in adauga_comanda pentru aceeasi comanda aux1
            select aux2.id_produs
            from adauga_comanda aux2
            where aux2.id_produs = p.id_produs
            and aux2.id_comanda = aux1.id_comanda
        )
);*/

select distinct id_comanda -- toate comenzile distincte
from adauga_comanda aux1
where not exists -- false: filtreaza toate id_comanda care nu respecta subcererea urm
(
    -- toate piesele de mobilier pentru care garantia este de o perioada de timp care incepe cu cifra 1 (1 an, 10 ani, ...)
    select aux2.id_produs
    from adauga_comanda aux2
    join piesa_mobilier p on(aux2.id_produs = p.id_produs)
    where aux2.id_comanda = aux1.id_comanda
    and nvl(to_number(substr(p.garantie, 1, 1)), 0) != 1 -- nr de ani dintr-o garantie neprelungita e chiar prima litera din stringul din campul garantie
)
and exists
(
    -- exista cel putin un produs cu tipul de garantie specificat
    select aux3.id_produs
    from adauga_comanda aux3
    join piesa_mobilier p on(aux3.id_produs = p.id_produs)
    where aux3.id_comanda = aux1.id_comanda
    and nvl(to_number(substr(p.garantie, 1, 1)), 0) = 1
);

-- verificare
/*select c.id_categorie, c.nume, round(avg(nvl(to_number(substr(p.garantie, 1, 1)), 0)), 2) as average_garantie_produs_per_categorie
from categorie c
join piesa_mobilier p on(p.id_categorie = c.id_categorie)
group by c.id_categorie, c.nume;*/
-- se se afiseze toate produsele reaprovizionate in stoc, alaturi de specificatiile lor (de fiecare data), insemnand afisarea, acolo unde este posibil, a materialelor folosite
select p.id_produs, p.nume, p.descriere, m.id_material, m.tip_material, p_d.unitati, s.id_stoc, s.data_aprovizionare
from materie_prima m
right join produsa_din p_d on(p_d.id_material = m.id_material)
right join piesa_mobilier p on(p.id_produs = p_d.id_produs)
right join aprovizioneaza a on(a.id_produs = p.id_produs)
right join stoc s on(a.id_stoc = s.id_stoc);
