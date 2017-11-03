
-- TME index

-- usage:
-- @annuaire


 -- création de la relation Annuaire

drop table Annuaire;

create table Annuaire(
  nom varchar(30), 
  prenom varchar(30), 
  age number(3) not null, 
  cp number(6) not null, 
  tel varchar(10) not null,
  profil varchar(1500) not null,
  -- le telephone est unique
  constraint UniqueTel unique(tel)
) nocache nologging;


-- définition de la procedure 
-- pour ajouter n tuples dans l'annuaire

create or replace procedure ajouter(n number) is
 nom varchar(30);
 prenom varchar(30);
 age integer;
 cp integer;
 tel varchar(10);
 profil varchar(1500);
--
begin
 DBMS_RANDOM.INITIALIZE(1);
--
   FOR i in 1 .. n LOOP
     -- générer des valeurs aléatoires pour une personne
     nom := 'n' || i;
     prenom := 'pn' || i;
     age := 1 + abs(DBMS_RANDOM.RANDOM) mod 100;
     cp := abs(DBMS_RANDOM.RANDOM) mod 1000;
     tel := '0' || abs(DBMS_RANDOM.RANDOM) mod 900000000;
     profil := rpad('p' || abs(DBMS_RANDOM.RANDOM) mod 2000000, 1500, '.');
     --insérer une nouvelle personne
     insert into Annuaire values(nom, prenom, age, cp, tel, profil);
   END LOOP;
   -- valider les insertions
   commit;
   DBMS_RANDOM.TERMINATE;
end;
/
sho err




-- remplir l'annuaire avec 1000 personnes
begin
 ajouter(1000);
end;
/



-- remplir l'annuaire
--Créer les index sur les attributs age et cp :
create index IndexAge on Annuaire(age);
create index IndexCp on Annuaire(cp);


--statistiques sur l'Annuaire
@analyse

-- créer les synonymes pour les tables de grande taille
create synonym BigAnnuaire for hubert.BigAnnuaire; 
create synonym BigAnnuaireSimple for hubert.BigAnnuaireSimple;


prompt fin du ficher annuaire.sql
prompt
