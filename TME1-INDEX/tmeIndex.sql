-- Compte rendu du TME sur les index : compléter ce fichier
-- ==================================

-- NOM, Prénom 1 : SALLERON Nicolas

-- Préparation : création de la relation Annuaire
-- ===========
@vider
@annuaire

@liste

-- schéma des relations :
desc Annuaire
desc BigAnnuaireSimple
desc BigAnnuaire




-- Exercices 
-- ==========


-- Exercice 1
-- ==========
-- J'ai lu l'ensemble des requêtes.

-- Exercice 2: plan simple sans index
-- ==================================

-- Requêtes sur la table BigAnnuaireSIMPLE

--R1: temps 00:11:58
SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaireSIMPLE;

--    AgeEgal : temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS FULL
--    prédicat : filter("AGE=18")
--    L'opération filter est une recherche sur l'ensemble de la table sans usage de l'index.
set autotrace trace explain
select * from BigAnnuaireSIMPLE 
where age = 18;

--    AgeInf :  temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS FULL et filter AGE<25
set autotrace trace explain
select * from BigAnnuaireSIMPLE 
where age < 25;


--    AgeSup : temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS FULL
--    prédicat : filter(AGE>18)
set autotrace trace explain
select * from BigAnnuaireSIMPLE 
where age > 18;

--    AgeEntre : temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : filter("AGE">=18 AND "AGE"<= 25)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where age BETWEEN 18 AND 25;

--    CodeEgal: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : filter("CP"=75000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where cp = 75000;

--    CodeInf: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : filter("CP"<25000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where cp < 25000;

--    CodeSup: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : filter("CP">75000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where cp > 75000;

--    CodeEntre: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : filter("CP">=15000 AND "CP"<=25000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where cp BETWEEN 15000 AND 25000;

--    AgeEgalCodeEgal : temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : BITMAP CONVERSION TO ROWIDS
--    opération : BITMAP AND
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : INDEX RANGE SCAN
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : INDEX RANGE SCAN
--    prédicat : filter("CP"=75000 AND "AGE"=18)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where age = 18 AND cp = 75000;

--    AgeEgalCodeInf : temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : BITMAP CONVERSION TO ROWIDS
--    opération : BITMAP AND
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : INDEX RANGE SCAN
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    prédicat : filter("AGE = 18 AND "CP"<25000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where age = 18 AND cp < 25000;

--    AgeInfCodeEgal: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : filter("AGE"<25 AND "CP"=75000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where age < 25 AND cp = 75000;

--    AgeInfCodeInf: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : BITMAP CONVERSION TO ROWIDS
--    opération : BITMAP AND
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    opération : BITMAP CONVERSION FROM ROWID
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    prédicat : filter("AGE"<25 AND "CP"<25000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where age < 25 AND cp < 25000;

--    AgeInfCodeEntre: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : BITMAP CONVERSION TO ROWIDS
--    opération : BITMAP AND
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    opération : BITMAP CONVERSION FROM ROWID
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    prédicat : filter("CP"<=25000 AND "AGE"<25 AND "CP">= 15000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where age < 25 AND (cp BETWEEN 15000 AND 25000);

--    AgeEntreCodeInf: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : BITMAP CONVERSION TO ROWIDS
--    opération : BITMAP AND
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    opération : BITMAP CONVERSION FROM ROWID
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    prédicat : access("AGE">=18 AND "AGE"<=25)
--    prédicat : access("CP"<25000)
--    prédicat : filter("CP"<25000)
set autotrace trace explain
select * from BigAnnuaireSIMPLE
where (age BETWEEN 18 AND 25) AND cp < 25000;

--    AgeInfCompte: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : SORT AGGREGATE
--    opération : INDEX FAST FULL SCAN
--    prédicat : filter("AGE"<60)
set autotrace trace explain
select COUNT(*) FROM BigAnnuaireSIMPLE where age < 60;
-- On remarque que l'on parcours l'ensemble de la table à chaque fois car cette table n'utilise pas d'indexes.


-- Exercice 3: plan avec index
-- ===========================



-- Requêtes sur la table BigAnnuaire
--    All : temps 00:14:11
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS FULL
set autotrace trace explain
select * from BigAnnuaire;

--    AgeEgal : temps 00:00:27
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX
--    opération : INDEX RANGE SCAN
--    prédicat : access(AGE=18)
--    Rows : 2200 pages
--    Cette requête est plus rapide, il y a un access à l'annuaire.
set autotrace trace explain
select * from BigAnnuaire 
where age = 18;


--    AgeInf :  temps 00:10:42
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : access(AGE<25)
--    Cette requête est plus rapide, il y a un access à l'annuaire.
set autotrace trace explain
select  * from BigAnnuaire 
where age < 25;


--    AgeSup : temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS FULL
--    prédicat : filter(AGE>18)
--    L'index n'est pas utilisé
set autotrace trace explain
select * from BigAnnuaire
where age > 18;

--    AgeEntre : temps 00:04:01
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : access("AGE">=18 AND "AGE"<= 25)
--    Cette requête est plus rapide, il y a un access à l'annuaire.
set autotrace trace explain
select * from BigAnnuaire
where age BETWEEN 18 AND 25;

--    CodeEgal: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : access("CP"=75000)
--    Cette requête est plus rapide, il y a un access à l'annuaire.
set autotrace trace explain
select * from BigAnnuaire
where cp = 75000;

--    CodeInf: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : access("CP"<25000)
--    Cette requête est plus rapide, il y a un access à l'annuaire.
set autotrace trace explain
select * from BigAnnuaire
where cp < 25000;

--    CodeSup: temps 00:11:58
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : INDEX RANGE SCAN
--    prédicat : access("CP">75000)
--    Cette requête est plus rapide, il y a un access à l'annuaire.
set autotrace trace explain
select * from BigAnnuaire
where cp > 75000;

--QUESTION B°)
set autotrace trace explain
select * from BigAnnuaire
WHERE age = 18 AND cp = 75000;
-- L'arbre :
--		0
--	   	1	   
--		2
--		3
--	4		6
--	5		7
--
--------------------------------------------------------------------------------------------------
--| Id  | Operation			 | Name        | Rows  | Bytes | Cost (%CPU)| Time     |
------------------------------------------------------------------------------------------------
--|   0 | SELECT STATEMENT		 |	       |     2 |  8068 |    10	 (0)| 00:00:01 |
--|   1 |  TABLE ACCESS BY INDEX ROWID	 | BIGANNUAIRE |     2 |  8068 |    10	 (0)| 00:00:01 |
--|   2 |   BITMAP CONVERSION TO ROWIDS	 |	       |       |       |	    |	       |
--|   3 |    BITMAP AND			 |	       |       |       |	    |	       |
--|   4 |     BITMAP CONVERSION FROM ROWIDS|	       |       |       |	    |	       |
--|*  5 |      INDEX RANGE SCAN		 | INDEXCP     |   220 |       |     1	 (0)| 00:00:01 |
--|   6 |     BITMAP CONVERSION FROM ROWIDS|	       |       |       |	    |	       |
--|*  7 |      INDEX RANGE SCAN		 | INDEXAGE    |   220 |       |     5	 (0)| 00:00:01 |
------------------------------------------------------------------------------------------------
--
-- On récupère les résultats des index que l'on convertis en BITMAP
-- On réalise un & entre ces deux éléments, il ne va en ressortir que ceux qui possède AGE = 18 et CP=75000
-- On reconverti ces résultats en ROWID
--
--

--QUESTION C°)

--    Prédicat	Rows	Durée		Accès
--    age<10	20000	00:04:01	INDEX RANGE SCAN
--    age<20	42222	00:08:28	INDEX RANGE SCAN
--    age<30	64444	00:12:56	INDEX RANGE SCAN
--    age<80	175K	00:14:11	TABLE ACCESS FULL

--QUESTION D°)
-- Il y aura tellement de ROWID que ce nombre dépasse meme le nombre de page. Si nous avons 40 rowid, cela fera 40 lectures du 8 pages. C'est non efficace.

--    Note :  Forcé index : /*+ index(BigAnnuaire INDEXAGE) */

--    AgeInf : temps 00:14:11
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS FULL
--    prédicat : AGE<18
set autotrace trace explain
select * from BigAnnuaire 
where age < 80;


-- Exercice 4: Coût de l'accès aux données
-- =======================================
-- Affiche le nombre le pages de la table
SET autotrace off
COLUMN TABLE_NAME format A20
SELECT TABLE_NAME, blocks, num_rows 
FROM user_tables;

SET autotrace trace EXPLAIN
SELECT * FROM Annuaire;

SET autotrace off
SELECT TABLE_NAME, blocks, num_rows FROM all_tables
WHERE TABLE_NAME = 'BIGANNUAIRE';

SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaire;

-- Le cout de Big Annuaire est de 70893
-- Le nombre de pages pour bigAnnuaire est de 261530
-- On veut connaitre la valeur de C donc 70893/261530 = 0.271070241

-- La valeur de C est constante car pour la table Annuaire, nous avions COST = 102 et BLOCKS = 370
-- Le cout de C pour la table Annuaire était donc 0.275675676

-- C'est la lecture des nuplet qui coûte, annuaireSimple possède de plus gros nuplet


-- Exercice 5: Coût d'une sélection pour le choix d'un index
-- =========================================================

-- info sur la taille des index
set autotrace off
column table_name A10
column index_name A10
--
select table_name, index_name, blevel, distinct_keys, leaf_blocks,
avg_leaf_blocks_per_key, avg_data_blocks_per_key
from user_indexes
where table_name = 'ANNUAIRE';

set autotrace off
select table_name, index_name, blevel, distinct_keys, leaf_blocks,
avg_leaf_blocks_per_key, avg_data_blocks_per_key
from all_indexes
where table_name = 'BIGANNUAIRE';

-- Index utilisé
SET autotrace trace EXPLAIN
select * from BigAnnuaire 
where age = 18;

-- Index utilisé
SET autotrace trace EXPLAIN
select * 
from BigAnnuaire 
where age <= 10;

--    AgeEgal : Index utilisé
set autotrace trace explain
select * from BigAnnuaire 
where age = 18;


--    AgeInf : Index utilisé
set autotrace trace explain
select * from BigAnnuaire 
where age < 25;


--    AgeSup : Index non utilisé, on doit parcourir plusieurs fois l'index, c'est donc moins éfficace
set autotrace trace explain
select * from BigAnnuaire
where age > 18;

--    AgeEntre : Index utilisé
set autotrace trace explain
select * from BigAnnuaire
where age BETWEEN 18 AND 25;

--    CodeEgal: Index utilisé
set autotrace trace explain
select * from BigAnnuaire
where cp = 75000;

--    CodeInf: Index utilisé
set autotrace trace explain
select * from BigAnnuaire
where cp < 25000;

--    CodeSup: Index utilisé
set autotrace trace explain
select * from BigAnnuaire
where cp > 75000;

--    CodeEntre: Index utilisé
set autotrace trace explain
select * from BigAnnuaire
where cp BETWEEN 15000 AND 25000;

--    AgeEgalCodeEgal : Index utilisé
--    prédicat : access("CP"=75000)
--    prédicat : access("AGE"=18)
set autotrace trace explain
select * from BigAnnuaire
where age = 18 AND cp = 75000;

--    AgeEgalCodeInf : Index utilisé
--    prédicat : access("AGE"=18)
--    prédicat : access("CP"<25000)
--    prédicat : filter("CP"<25000)
set autotrace trace explain
select * from BigAnnuaire
where age = 18 AND cp < 25000;

--    AgeInfCodeEgal: Index utilisé
--    prédicat : filter("AGE"<25)
--    prédicat : access("CP"=75000)
set autotrace trace explain
select * from BigAnnuaire
where age < 25 AND cp = 75000;

--    AgeInfCodeInf: Index utilisé
--    prédicat : access("AGE"<25)
--    prédicat : filter("AGE"<25)
--    prédicat : access("CP"<25000)
--    prédicat : filter("CP"<25000)
set autotrace trace explain
select * from BigAnnuaire
where age < 25 AND cp < 25000;

--    AgeInfCodeEntre: Index utilisé
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : BITMAP CONVERSION TO ROWIDS
--    opération : BITMAP AND
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    opération : BITMAP CONVERSION FROM ROWID
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    prédicat : access("CP">=15000 AND "CP"<=25000)
--    prédicat : access("AGE"<25)
--    prédicat : filter("AGE"<25)
set autotrace trace explain
select * from BigAnnuaire
where age < 25 AND (cp BETWEEN 15000 AND 25000);

--    AgeEntreCodeInf: index utilisé
--    opération : SELECT STATEMENT
--    opération : TABLE ACCESS BY INDEX ROWID
--    opération : BITMAP CONVERSION TO ROWIDS
--    opération : BITMAP AND
--    opération : BITMAP CONVERSION FROM ROWIDS
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    opération : BITMAP CONVERSION FROM ROWID
--    opération : SORT ORDER BY
--    opération : INDEX RANGE SCAN
--    prédicat : access("AGE">=18 AND "AGE"<=25)
--    prédicat : access("CP"<25000)
--    prédicat : filter("CP"<25000)
set autotrace trace explain
select * from BigAnnuaire
where (age BETWEEN 18 AND 25) AND cp < 25000;

--    AgeInfCompte : index non utilisé
--    opération : SELECT STATEMENT
--    opération : SORT AGGREGATE
--    opération : INDEX FAST FULL SCAN
--    prédicat : filter("AGE"<60)
set autotrace trace explain
select COUNT(*) FROM BigAnnuaire where age < 60;


-- Question a)
-- Les requêtes ou l'index n'est pas utilisé sont :
--     - ageSup : Quand on change par 18 par 99, il l'utilise.
--     	 	  Le coût quand > 18 est de 78000.
--		  Le coût quand > 99 est de 2200.
--		  Quand l'index coûte trop pour la requête il est ignoré.
--     - AgeInfCompte : Il est obliger de lire l'ensemble pour pouvoir les compter.
--			L'index n'est pas utilisable car on perdrait plus de temps à le traverser plusieurs fois.

-- Question b)
-- Requête initiale : Durée 00:02:15
SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaire WHERE age < 25 AND cp < 12000;

-- Durée : 00:04:52
SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaire WHERE age < 99 AND cp < 12000;

-- Ici X = 99 requiert un trop grand nombre de parcours d'index, il n'est donc pas utilisé car il n'est pas assez selectif

-- Durée : 00:10:42
SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaire WHERE age < 25 AND cp < 90000;

-- Ici Y = 90000 demande un trop grand nombre de parcours d'index, il n'est donc pas utilisé car il n'est pas assez selectif

-- Durée : 00:14:11
SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaire WHERE age < 99 AND cp < 90000;

-- Dans ce cas, aucun index n'est utilisé, car pas assez sélectif. Les durées explosent car l'on est obliger de parcourir toute la table.

--Question c)

-- N'utilise pas l'index
SET autotrace trace EXPLAIN
select * from BigAnnuaire where age < 35;
-- N'utilise pas l'index
SET autotrace trace EXPLAIN
select * from BigAnnuaire where cp < 38000; 
-- Utilise l'index
SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaire WHERE age < 35 AND cp < 38000;
-- Il réalise un tri pour faire ensuite une intersection plus éfficace


--Question d)

-- Préciser la taille des index
SET autotrace off
COLUMN TABLE_NAME format A10
COLUMN index_name format A10
SELECT TABLE_NAME, index_name, blevel, distinct_keys, leaf_blocks,
avg_leaf_blocks_per_key, avg_data_blocks_per_key
FROM all_indexes
WHERE TABLE_NAME = 'BIGANNUAIRE';
SET autotrace trace EXPLAIN

-- leaf_block représente le nombre total de blocs correspondant à des feuilles
-- avg_leaf_blocks_per_key représente le nombre total de blocs par entrée (feuille).

-- Combien de pages faut-il lire pour obtenir les ROWID des personnes ayant plus de 18 ans?
set autotrace trace explain
select * from BigAnnuaire
where age = 18;
-- Il faut 2200 lignes le coût est de 2206
--    2. index range scan coute 5
--    1. table access by index rowid coute 2200 + 5 + 1(calcul)

-- La liste contient 2200 pointeur vers des gens de 18 ans

-- L'index de l'age est de 430 pages(=LEAF_BLOCKS)
-- On a 100 valeurs d'age (=DISTINCT_KEYS) donc environ 4.3 pages par age (=AVG_LEAF_BLOCKS_PER_KEY)



-- AGE = 30
set autotrace trace explain
select * from BigAnnuaire
where age = 30;

-- Le cout est le même que précédent.


-- Exercice 6. Comparaison de plans d'exécutions équivalents
-- ===============================================

SET autotrace trace EXPLAIN
select *
from BigAnnuaire where age = 18 and cp < 75000;


select /*+ index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */ *
from BigAnnuaire 
where age = 18 and cp = 75000;


select /*+ index(BigAnnuaire IndexCP) no_index(BigAnnuaire IndexAge)  */ *
from BigAnnuaire 
where age = 18 and cp = 75000;


select /*+ no_index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */ *
from BigAnnuaire 
where age = 18 and cp = 75000;

select /*+ index_combine(BigAnnuaire IndexAge IndexCp)  */ *
from BigAnnuaire 
where age = 18 and cp < 75000;


-- Question a)

-- Plan 1 : Cout 2206
SELECT /*+ index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age = 18 AND cp = 75000;

-- Plan 2 : Cout 221
SELECT /*+ no_index(BigAnnuaire IndexAge) index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age = 18 AND cp = 75000;

-- Plan 3 : Cout 70893
SELECT /*+ no_index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age = 18 AND cp = 75000;

-- Plan 4 : Cout 221 
SELECT /*+ index(BigAnnuaire IndexAge) index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age = 18 AND cp = 75000;

-- Plan sans directive : Cout 10
SELECT  * 
FROM BigAnnuaire WHERE age = 18 AND cp = 75000;

-- Le plan sans directive est celui qui est le plus petit

-- AgeInfCodeInf

-- Plan 1 : Cout 37862
SELECT /*+ index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 18 AND cp = 75000;

-- Plan 2 : Cout 221
SELECT /*+ no_index(BigAnnuaire IndexAge) index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 18 AND cp = 75000;

-- Plan 3 : Cout 70893
SELECT /*+ no_index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 18 AND cp = 75000;

-- Plan 4 : Cout 221 
SELECT /*+ index(BigAnnuaire IndexAge) index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 18 AND cp = 75000;

-- Plan sans directive : Cout 148
SELECT  * 
FROM BigAnnuaire WHERE age < 18 AND cp = 75000;

-- Le plan sans directive est celui qui est le plus petit

-- AgeInfCodeEntre
-- Cost 53453
SELECT /*+ index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 25 AND (cp BETWEEN 15000 AND 25000);
-- Cost 22516
SELECT /*+ no_index(BigAnnuaire IndexAge) index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 25 AND (cp BETWEEN 15000 AND 25000);
-- Cost 70893
SELECT /*+ no_index(BigAnnuaire IndexAge) no_index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 25 AND (cp BETWEEN 15000 AND 25000);
-- Cost 22516
SELECT /*+ index(BigAnnuaire IndexAge) index(BigAnnuaire IndexCp)  */  * 
FROM BigAnnuaire WHERE age < 25 AND (cp BETWEEN 15000 AND 25000);

-- Exercice 7

--Vérifier qu'il est possible d'évaluer R13 en lisant seulement l'index, sans accéder aux nuplets d'Annuaire. Expliquer pourquoi c'est possible. Proposer d'autres requêtes pouvant être traitées sans accéder aux nuplets :

  --  avec un distinct
  --  avec un group by et une agrégation
  --  avec un order by
  --  avec les 2 attributs age et cp dans la clause select

-- R13?
SET autotrace trace EXPLAIN
SELECT * FROM BigAnnuaire
WHERE age < 25 AND cp < 25000;

-- Il est possible d'évaluer les nuplets d'Annuaire sans en utilisant d'abord les résultats fourni par les deux index.

SET autotrace trace EXPLAIN
SELECT DISTINCT age FROM BigAnnuaire
WHERE age < 25 ;

SET autotrace trace EXPLAIN
SELECT age, AVG(age) FROM BigAnnuaire 
WHERE age < 25 GROUP BY age;

SET autotrace trace EXPLAIN
SELECT age FROM BigAnnuaire 
WHERE age < 25 ORDER BY age;

SET autotrace trace EXPLAIN
SELECT age,cp FROM BigAnnuaire 
WHERE age < 25;
