
--drop index I_J_cnum;
--drop index I_J_salaire;
--drop index I_C_division;
--drop index I_C_cnum;
--drop index I_F_cnum;


create index I_J_cnum on J(cnum);
--
create index I_J_salaire on J(salaire);
--
create index I_C_division on C(division);
--
--create index I_C_cnum on C(cnum);
--
--create index I_F_cnum on F(cnum);
