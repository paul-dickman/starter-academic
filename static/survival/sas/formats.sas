/********************************************************
This program creates SAS formats and stores them
in a permanent format catalogue (in the SURVIVAL library).
********************************************************/

libname survival 'c:\coursetemp\sas\';
options fmtsearch=(survival work library);

/* First delete the existing catalog */
proc datasets library=colon memtype=(catalog);
delete formats / memtype=catalog;
run;

proc format library=colon fmtlib;

value fu
1='1 '
2=' 2'
3=' 3'
4=' 4'
5=' 5'
6=' 6'
7=' 7'
8=' 8'
9=' 9'
10=' 10'
;

value sex
1='Male'
2=' Female'
;

value yydx
1975-1984='1975-84'
1985-1994=' 1985-94'
;

value age
0-44='0-44'
45-59=' 45-59'
60-74=' 60-74'
75-high=' 75+'
;

value status
0='Alive'
1='Dead: cancer'
2='Dead: other'
4='Lost to follow-up'
;

value stage
0='Unknown'
1='Localised'
2='Regional'
3='Distant'
;

/* colon subsite */
value colonsub
1='Coecum and ascending'
2='Transverse'
3='Descending and sigmoid'
4='Other and NOS'
;

run;
