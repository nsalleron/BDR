-- NOM: 
-- Prénom: 

-- NOM: 
-- Prénom: 

-- Binome: 

-- ==========================

-- TME Jointure:

-- Préparation
-- ===========

-- construire la base de l'exercice 3
@vider

connect E3504018/E3504018@ora11
@vider
@base3
drop table J;
@liste

connect E3504018/E3504018@ora10
@vider
@base3
drop table C cascade constraints;
@liste


drop database link site2;
create database link site2 connect to E3504018 identified by "E3504018" using 'ora10';

desc J@site2

desc C

 insert into C values( 6000, 'petit club', 2, 'Combourg');


create view J as
      select *
      from j@site2;

--R1
--OU: C LOCAL et J sur site 2 en remote SELECT "LICENCE","CNUM","PRENOM","SALAIRE","SPORT" FROM "J" "J" (accessing 'SITE2.UFR-INFO-P6.JUSSIEU.FR' )
--QUELLE :
--	 0<-local
--	 1<-local	
--	2 3<-distant
--	^- local
-- 2 : TABLE ACCESS FULL
-- 3 : REMOTE (SELECT ...)
 set timing on
 set autotrace trace explain stat
 select *
    from J, C
    where j.cnum = c.cnum;


--R1bis
-- QUELLE :
-- 	    PROJ <-local
--	    JOIN	<-local
--local->PROJ  PROJ<-SELECT "LICENCE","CNUM","SALAIRE" FROM "J" "J" (accessing 'SITE2....JUSSIEU.FR' )
--local-> C	J<-distant
-- Le systeme comprend que l'on a pas besoin de tout les attributs et il ne prend donc pas le sport de J ! + de performance !
 set timing on
 set autotrace trace explain stat
 select J.licence, J.salaire, c.ville
    from J, C
    where j.cnum = c.cnum;

-- Requête : Joueurs et dates de la ville "Combourg"
--Ra <- site 1
 set timing on
 set autotrace trace explain stat
 select cnum
 from C
 where ville='combourg';
 
--Rb <- site 2
 set timing on
 set autotrace trace explain stat
 select *
 from J, Ra
 where j.cnum = ra.cnum
 
--Rc <- site 1
 set timing on
 set autotrace trace explain stat
 select *
 from C, Rb
 where c.num = Rb.cnum


 -- Sur le site A
 create view Ra as 
 select cnum
 from C
 where ville = 'Combourg';

 -- Sur le site B
 connect E3504018/E3504018@ora10
 drop database link site1;
 create database link site1 connect to E3504018 identified by "E3504018" using 'ora11';
 create view Rb as
 select j.*
 from J, Ra@site1
 where j.cnum = Ra.cnum



 -- Sur le site A
 connect E3504018/E3504018@ora11
 select *
 from C, Rb@site2 r
 where c.num = r.cnum;










/* 
   Directive driving site
   1°) Envoyer tous les club (ville = Combourg) vers le site 2
   2°) Jointure sur le site 2
   3°) Résultat affichés sur le site 1
       	<-- Affichage sur le site 1 
       0 <- REMOTE sur site 2
       1 <- sur site 2
     2  3 <- Table access full 
     ^- Sur le site 1 REMOTE


*/
--Essai de réalisation de la requête précédente <= OK

 set timing on
 set autotrace trace explain stat
 select /*+ driving_site(j)*/* 
 from J, C
 where j.cnum = c.cnum;











--R2
--OU
--QUELLE : 
 set timing on
 set autotrace trace explain stat
 select *
 from J, C
 where j.cnum = c.cnum and salaire > 59000;
--> Il y a 997 lignes, la requête n'est donc pas assez sélective.
--     0 <- Local site 1
--     1 <- Local site 1
--    2 3 <- Local site 1
--    ^-Remote site 2





--R3a
--OU
--QUELLE : 
 set timing on
 set autotrace trace explain stat
 select *
 from J, C
 where j.cnum = c.cnum
 and ville = 'Combourg';
/*

	0 <-Local
        1 <-Local
       2 3 <- Remote 
       ^- Local




*/

--R3b
--OU
--QUELLE : 
 set timing on
 set autotrace trace explain stat
 select /*+ driving_site(j1) */ *
 from J j1, C c1
 where j1.cnum = c1.cnum
 and ville = 'Combourg';
