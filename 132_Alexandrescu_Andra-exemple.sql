--12-1)
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

--12-2)
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

--12-3)
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

--12-4)
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

--12-5)
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

--13-1)
-- sa se stearg? toti agentii de vanzari care nu sunt asociati unui magazin sau pe cei care nu proceseaza nicio comanda
delete from agent_vanzari
where id_angajat in (   select id_angajat
                        from agent_vanzari
                        where id_magazin is null )
or id_angajat not in (  select id_angajat
                        from comanda
                        where id_angajat is not null    );
rollback;

--13-2)
-- sa se stearga toate stocurile pentru care cantitatea asociata in tabelul de aprovizionare este mai mica decat 50% din average-ul cantitatilor in total aprovizionate.
delete from stoc
where id_stoc in (  select distinct(s.id_stoc)--, a.cantitate
                    from stoc s
                    join aprovizioneaza a on s.id_stoc = a.id_stoc
                    where a.cantitate < 0.5 * ( select avg(cantitate)
                                                from aprovizioneaza )
                );        
rollback;

--13-3)
-- sa se actualizeze toate inregistrarile de adaugat produse intr-o comanda in care este setat momentul de timp timestamp cu 2 zile dupa toate comenzile avand data de achizitie 28 mai
update adauga_comanda
set moment_timp = moment_timp + 2
where id_comanda in (   select id_comanda
                        from comanda
                        where to_char(data_achizitie, 'DD-MON') = '28-MAY'  );
rollback;

--15-1)
-- sa se afiseze toate produsele reaprovizionate in stoc, alaturi de specificatiile lor (de fiecare data), insemnand afisarea, acolo unde este posibil, a materialelor folosite
select p.id_produs, p.nume, p.descriere, m.id_material, m.tip_material, p_d.unitati, s.id_stoc, s.data_aprovizionare
from materie_prima m
right join produsa_din p_d on(p_d.id_material = m.id_material)
right join piesa_mobilier p on(p.id_produs = p_d.id_produs)
right join aprovizioneaza a on(a.id_produs = p.id_produs)
right join stoc s on(a.id_stoc = s.id_stoc);

--15-2)
-- sa se afiseze toate id-urile comenzilor in care exista numai piese de mobilier care au garantie de 1 an (fara a considera prelungirea)
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

--15-3)
-- sa se afiseze primele 5 cele mai bine vandute produse, descrescator in functie de cantitatea (nu un numar determinat de totalul comenzilor) de vanzari din 2024 (determinata de adauga_comanda)
with top_vanzari_categorie as (
    select c.nume as nume_categorie, p.nume as nume_produs, sum(a.cantitate) as total_vanzari_categorie, to_char(a.moment_timp, 'YYYY') as an_vanzare -- conflict de nume fara definirea alias-urilor
    from adauga_comanda a
    join piesa_mobilier p on(a.id_produs = p.id_produs)
    join categorie c on(p.id_categorie = c.id_categorie)
    --where to_char(a.moment_timp, 'YYYY') = 2024
    group by c.nume, p.nume, to_char(a.moment_timp, 'YYYY')
    --order by 3 desc
)
select nume_categorie, nume_produs, total_vanzari_categorie, an_vanzare
from top_vanzari_categorie
where an_vanzare = 2024
and rownum <= 5
order by total_vanzari_categorie desc;
