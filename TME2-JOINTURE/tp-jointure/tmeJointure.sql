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
purge recyclebin;
@base3
@index3
@analyseJoueur

@liste


-- schéma des tables
desc J
desc C
desc F
desc BigJoueur

--
set autotrace off
select count(*) as nb_Joueurs from J; -- 50000 nuplet
select count(*) as nb_BigJoueurs from BigJoueur; --50000 nuplet
select count(*) as nb_Clubs from C;   -- 5000 nuplet
select count(*) as nb_Finances from F;	 --5000 nupet
--
--Activer la visualisation des PLANS d'exécution
set autotrace trace explain


--supprimer l'ancienne table plan_table si elle existe
--drop table plan_table;

-- cout du parcours séquentiel des tables J, C et F
-- =================================================

set autotrace trace explain
select * from J;    -- Cost : 68

select * from C;    -- Cost : 7    

select * from F;    -- Cost : 5

select * from BigJoueur;    -- Cost : 13798





-- Question 1
--===========

--a)
-- Le plan est le suivant :
-- SELECT STATEMENT id : 0
-- 	  HASH JOIN id : 1*
--	       TABLE ACCESS FULL C id : 2
--	       TABLE ACCESS FULL J id : 3*

set autotrace trace explain
select J.licence, C.nom
from C, j
where J.cnum = C.cnum
and salaire >10;
-- Lire entièrement la table de gauche (Table Access Full de C), la hacher sur la clé de jointure (ici c'est l'attribut cnum) pour créer en mémoire une HashMap<clé, {nuplet}>
-- Lire la relation de droite (Table Access Full de J) et pour chaque nuplet, effectuer la jointure (HASH_JOIN) en consultant la HashMap construite à l'étape 1.

-- Le cout de ce plan est de 76, il n'est pas égal à la somme de 7+68 (=75), il y a un cout qui doit partir dans l'opération de hash et qui est donc surement négligeable en comparaison du gain par hashage.


select /*+ ordered */ J.licence, C.nom
from J, C
where J.cnum = C.cnum
and salaire >10;

select /*+ ordered */ J.licence, C.nom
from C, J
where J.cnum = C.cnum
and salaire >10;

-- Le cout est effectivement le même pour les deux opérations SQL précédente. Cela signifie que le hash permet d'économiser peut importe l'ordre des enregistrements (que l'on réalise un table access full sur 5000 ou sur 50000). 



-- b) jointure de C avec BigJoueur

-- Le cout est de 13805 ici. Il est d'ailleurs égal à la somme des deux table access full.
select /*+ ordered */ *
from C, BigJoueur b
where b.cnum = c.cnum;

-- Le cout est de 23370 ici. Il est beaucoup plus élevé que le précédent. D'ailleurs il y a une grosse augmentation du cout due à la table de hashage ( de 9565 ) car il doit écrire les résultats sur le disque . 
select /*+ ordered */ *
from BigJoueur b, C
where b.cnum = c.cnum;

-- Quand on retire la directive ordered le SGBD choisit bien de lire BIGJOUEUR avant C.
select *
from BigJoueur b, C
where b.cnum = c.cnum;



--c)
-- Le plan ici est :
-- SELECT STATEMENT
-- 	  HASH JOIN
--	       TABLE ACCESS FULL J
--	       TABLE ACCESS FULL C
select J.licence, C.nom 
from C, j
where J.cnum = C.cnum
and salaire > 59000;

-- Le plan ici est :
-- SELECT STATEMENT
-- 	  HASH JOIN
--	       TABLE ACCESS FULL C
--	       TABLE ACCESS FULL J
select J.licence, C.nom
from C, j
where J.cnum = C.cnum
and salaire > 10;

-- Le plan ici est :
-- SELECT STATEMENT
-- 	  HASH JOIN
--	       TABLE ACCESS FULL C
--	       TABLE ACCESS FULL J
select J.licence, C.nom
from C, j
where J.cnum = C.cnum
and salaire > 100;

-- Le plan ici est :
-- SELECT STATEMENT
-- 	  HASH JOIN
--	       TABLE ACCESS FULL C
--	       TABLE ACCESS FULL J
select J.licence, C.nom
from C, j
where J.cnum = C.cnum
and salaire > 1000;

-- Le plan ici est :
-- SELECT STATEMENT
-- 	  HASH JOIN
--	       TABLE ACCESS FULL C
--	       TABLE ACCESS FULL J
select J.licence, C.nom
from C, j
where J.cnum = C.cnum
and salaire > 10000;



-- d)
--         	  Le cout sur C pour un TABLE ACCESS FULL est de 7.
--   	   	     Le cout sur J pour un INDEX RANGE SCAN sur salaire est de 2
--	  	  Le cout d'un TABLE ACCESS BY INDEX ROWID est de 50.
--          Le cout de la jointure par hashage est donc de 1 ( 60 - 52 - 7 = 1 )
-- Le cout global est de 60.

select J.licence, C.nom
from C, j
where J.cnum = C.cnum
and salaire < 10050; -- Sélectif



-- Question 2)
-- ===========

--a) 

------------------------------------------------------------------------------------------------
--| Id  | Operation		      | Name	    | Rows  | Bytes | Cost (%CPU)| Observation |
------------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	      | 	    |	  6 |	156 |	 14   (0)|
--|   1 |  NESTED LOOPS		      | 	    |	    |	    |		 | Pour chaque tuple j appartenant à J faire :
--|   2 |   NESTED LOOPS	      | 	    |	  6 |	156 |	 14   (0)| Pour chaque tuple c appartenant à C faire :
--|   3 |    TABLE ACCESS BY INDEX ROWID| J	    |	  6 |	 84 |	  8   (0)| Accès aux enregistrements grâce à l'index
--|*  4 |     INDEX RANGE SCAN	      | I_J_SALAIRE |	  6 |	    |	  2   (0)|
      	      	    --	  1 - Scan de l'index sur J pour récupérer les adresses des nuplets. Il doit lire les rowids sur des pages à par. Il récupère 6 rowid donc  6*1.
--|*  5 |    INDEX UNIQUE SCAN	      | I_C_CNUM    |	  1 |	    |	  0   (0)| 
      	     	   --	  2 - Scan de l'index sur C pour obtenir les adresses des nuplets. Il récupère les CNUM et il récupère les CNUM correspondant au 6 cellules. 
--|   6 |   TABLE ACCESS BY INDEX ROWID | C	    |	  1 |	 12 |	  1   (0)| Accès aux enregistrements grâce à l'index
      	    	  -- 	  3 - Il va chercher les 6 lignes avec les row ID donc 6*1 = 6
-----------------------------------------------------------------------------------------------

select J.licence, C.nom
from C, j
where J.cnum = C.cnum
and salaire < 10006;
-- Sélectif


-- b)
--------------------------------------------------------------------------------------------
--| Id  | Operation		     | Name	| Rows	| Bytes | Cost (%CPU)| Observation |
--------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	     |		| 50000 |  1269K| 50083   (1)| 
--|   1 |  NESTED LOOPS		     |		|	|	|	     | 
--|   2 |   NESTED LOOPS	     |		| 50000 |  1269K| 50083   (1)| Placement sur disque. (Matérialisation)
--|*  3 |    TABLE ACCESS FULL	     | J	| 50000 |   683K|    68   (0)| C'est la table J qui est parcourue séquentiellement une seule fois
--|*  4 |    INDEX UNIQUE SCAN	     | I_C_CNUM |     1 |	|     0   (0)| 
--|   5 |   TABLE ACCESS BY INDEX ROWID| C	|     1 |    12 |     1   (0)| 
-----------------------------------------------------------------------------------------
-- L'index choisi sur CNUM est celui de la table C.
-- Le cout de ce plan est : 

select /*+ USE_NL(J,C) */ J.licence, C.nom
FROM J, C
where J.cnum = C.cnum
and J.salaire > 10; 
-- Non sélectif

---------------------------------------------------------------------------------------------
--| Id  | Operation		     | Name	| Rows	| Bytes | Cost (%CPU)| Observations |
---------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	     |		| 50000 |  1269K| 55020   (1)| 
--|   1 |  NESTED LOOPS		     |		|	|	|	     | 
--|   2 |   NESTED LOOPS	     |		| 50000 |  1269K| 55020   (1)| 
--|   3 |    TABLE ACCESS FULL	     | C	|  5000 | 60000 |     7   (0)| 
--|*  4 |    INDEX RANGE SCAN	     | I_J_CNUM |    10 |	|     1   (0)| 
--|*  5 |   TABLE ACCESS BY INDEX ROWID| J	|    10 |   140 |    11   (0)| 
--------------------------------------------------------------------------------------------
select /*+ USE_NL(J,C) ORDERED */ J.licence, C.nom
from C,J
where J.cnum = C.cnum
and J.salaire > 10;


---------------------------------------------------------------------------------------------
--| Id  | Operation		     | Name	| Rows	| Bytes | Cost (%CPU)| Observations |	
---------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	     |		|     6 |   156 |    74   (0)|
--|   1 |  NESTED LOOPS		     |		|	|	|	     |	
--|   2 |   NESTED LOOPS	     |		|     6 |   156 |    74   (0)|
--|*  3 |    TABLE ACCESS FULL	     | J	|     6 |    84 |    68   (0)| 
--|*  4 |    INDEX UNIQUE SCAN	     | I_C_CNUM |     1 |	|     0   (0)| 
--|   5 |   TABLE ACCESS BY INDEX ROWID| C	|     1 |    12 |     1   (0)|
---------------------------------------------------------------------------------------------


--c)
--Sélectif
select /*+ no_index(J I_J_salaire) */ J.licence, C.nom
from J, C
where J.cnum = C.cnum
and J.salaire <10006;

-----------------------------------------------------------------------------------------
--| Id  | Operation		     | Name	| Rows	| Bytes | Cost (%CPU)| Time	|
-----------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	     |		|     6 |   156 |    74   (0)|		|
--|   1 |  NESTED LOOPS		     |		|	|	|	     |		|
--|   2 |   NESTED LOOPS	     |		|     6 |   156 |    74   (0)| 		|
--|*  3 |    TABLE ACCESS FULL	     | J	|     6 |    84 |    68   (0)| 		|
--|*  4 |    INDEX UNIQUE SCAN	     | I_C_CNUM |     1 |	|     0   (0)| 		|
--|   5 |   TABLE ACCESS BY INDEX ROWID| C	|     1 |    12 |     1   (0)| 		|
-----------------------------------------------------------------------------------------







-- ==========
-- EXERCICE 2
-- ==========


--========================
-- la requete R3
--========================

-- a)

--	FULL : parcours séquentiel
--	INDEX UNIQUE SCAN : accès par index sur l'attribut clé cnum
--	INDEX RANGE SCAN : accès par index sur un attibrut non clé. Exemple J.cnum n'est pas unique.
--	Ordre	-	Coût	-  Accès J     	  	 -  Accès C  -  Accès F
--	JCF	-	78	-  FULL	       	     	 -  IndexU	-  IndexU
--	JFC	-	25021	-  FULL	       		 -  IndexU	-  FULL
--	JFCbis	- 	78	-  FULL	       		 -  IndexU	-  IndexU
--	CJF	-	27519	-  IndexR      		 -  FULL	-  IndexU
--	CFJ	-	30014	-  TableIndexRow	 -  FULL	-  IndexU   
--	FCJ	-	32513	-  TableIndexRow    	 -  IndexU	-  FULL
--	FJC	-	357000	-  FULL			 -  TableIndexR -  FULL



--CJF Arbre
--	    0
--	    1 
--	   2 8	  
--	  3 7
--	 4 5
--	   6
-- boucles imbriquées sans ordre (pour voir si Oracle marche bien)
SELECT /*+ use_nl(J,C,F)  */ c.nom, f.budget
FROM J, C, F
WHERE J.cnum = C.cnum AND C.cnum = F.cnum
AND c.division=1 AND J.salaire > 59000  
AND j.sport = 'sport1';

-- boucles imbriquées et ordre J C F
SELECT /*+ use_nl(J,C,F) ordered  */ c.nom, f.budget
FROM J, C, F
WHERE J.cnum = C.cnum AND C.cnum = F.cnum
AND c.division=1 AND J.salaire > 59000  
AND j.sport = 'sport1';
  	    
-- Index C jointure avec J puis avec index F


-- boucles imbriquées et ordre J F C
SELECT /*+ use_nl(J,F,C) ordered */ c.nom, f.budget
FROM J, F, C
WHERE J.cnum = C.cnum AND C.cnum = F.cnum
AND c.division=1 AND J.salaire > 59000  
AND j.sport = 'sport1';

-- boucles imbriquées et ordre J F C
SELECT /*+ use_nl(J,F,C) ordered */ c.nom, f.budget
FROM J, F, C
WHERE J.cnum = C.cnum AND C.cnum = F.cnum AND J.cnum = F.cnum
AND c.division=1 AND J.salaire > 59000  
AND j.sport = 'sport1';

-- J(full) jointure avec F (full) puis index C et jointure C.


-- idem pour les autres ordres, remplacer la clause from par :
-- from C, J, F
SELECT /*+ use_nl(C,J,F) ordered */ c.nom, f.budget
FROM C, J, F
WHERE J.cnum = C.cnum AND C.cnum = F.cnum
AND c.division=1 AND J.salaire > 59000  
AND j.sport = 'sport1';

-- from C, F, J 4
select /*+ use_nl(C,F,J) ordered */ C.nom, F.budget 
from C, F, J
where J.cnum = C.cnum and C.cnum = F.cnum 
and C.division=1 and J.salaire > 59000  
and J.sport = 'sport1';

-- from F, C, J
select /*+ use_nl(F,C,J) ordered */ C.nom, F.budget 
from F, C, J
where J.cnum = C.cnum and C.cnum = F.cnum 
and C.division=1 and J.salaire > 59000  
and J.sport = 'sport1';

-- from F, J, C
select /*+ use_nl(F,J,C) ordered */ C.nom, F.budget 
from F, J, C
where J.cnum = C.cnum and C.cnum = F.cnum 
and C.division=1 and J.salaire > 59000  
and J.sport = 'sport1';



-- b)

-- Le cout de R3 serait de 78 alors que avec un forte sélectivité sur le salaire, il est de 5.

SELECT  c.nom, f.budget 
FROM J, C, F
WHERE J.cnum = C.cnum  AND C.cnum = F.cnum
AND c.division=1 AND J.salaire > 100000
AND j.sport = 'sport1';

SELECT /*+ no_index(J I_J_salaire) */ c.nom, f.budget 
FROM J, C, F
WHERE J.cnum = C.cnum  AND C.cnum = F.cnum
AND c.division=1 AND J.salaire > 100000
AND j.sport = 'sport1';
-- => Sans l'index, le coût passe à 70. Beaucoup plus élevé.



-- c)

select /*+ use_nl(J,C,F) index(C I_C_division) index(J I_J_salaire)*/ c.nom, f.budget 
from J, C, F
where J.cnum = C.cnum and C.cnum = F.cnum
and C.division=1 and J.salaire > 59000
and J.sport = 'sport1';

--Plan d'exécution
----------------------------------------------------------
--Plan hash value: 1027974613

-----------------------------------------------------------------------------------------------
--| Id  | Operation		       | Name	      | Rows  | Bytes | Cost (%CPU)| Time     |
-----------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT	       |	      |     5 |   200 |  1117	(0)| 00:00:14 |
--|   1 |  NESTED LOOPS		       |	      |       |       | 	   |	      |
--|   2 |   NESTED LOOPS	       |	      |     5 |   200 |  1117	(0)| 00:00:14 |
--|   3 |    NESTED LOOPS 	       |	      |     5 |   165 |  1112	(0)| 00:00:14 |
--|*  4 |     TABLE ACCESS BY INDEX ROWID| J	      |     5 |    90 |   997	(0)| 00:00:12 |
--|*  5 |      INDEX RANGE SCAN	       | I_J_SALAIRE  |   997 |       |     4	(0)| 00:00:01 |
--|*  6 |     TABLE ACCESS BY INDEX ROWID| C	      |     1 |    15 |    23	(0)| 00:00:01 |
--|*  7 |      INDEX RANGE SCAN	       | I_C_DIVISION |  2500 |       |     5	(0)| 00:00:01 |
--|*  8 |    INDEX UNIQUE SCAN	       | I_F_CNUM     |     1 |       |     0	(0)| 00:00:01 |
--|   9 |   TABLE ACCESS BY INDEX ROWID  | F	      |     1 |     7 |     1	(0)| 00:00:01 |
-------------------------------------------------------------------------------------------------

--Predicate Information (identified by operation id):
---------------------------------------------------

--  4 - filter("J"."SPORT"='sport1')
--   5 - access("J"."SALAIRE">59000)
--   6 - filter("J"."CNUM"="C"."CNUM")
--   7 - access("C"."DIVISION"=1)
--   8 - access("C"."CNUM"="F"."CNUM"

-- Le problème de l'attribut division c'est qu'il rapport beaucoup trop de ligne. Cela entraine beaucoup de rowid à lire alors que le cout séquentiel n'en est que de 7. On est obliger ensuite de comparer chaque ligne.


-- Ex 3

-- requete R4 :

select /*+ use_nl(J,C,F) */ C.nom, F.budget, J.licence
from J, C, F
where J.cnum = C.cnum and C.cnum = F.cnum
;


