/* Kaplan-Meier, life table, and log-rank test using PROC LIFETEST */
title;
libname survival 'c:\coursetemp\sas\';

goptions noprompt gunit=percent rotate=landscape 
device=win ftext="Arial" htext=3 htitle=4;
;

symbol1 c=black v=none line=1;  /* solid line */
symbol2 c=black v=none line=20; /* dashed line */

proc lifetest data=survival.colon_sample plots=(s);
time surv_mm*status(0,4);
run;

proc lifetest data=survival.colon_sample plots=(s)
     nocens graphics method=act width=12;
time surv_mm*status(0,4);
run;

proc lifetest data=survival.colon_sample plots=(s);
time surv_mm*status(0,4);
where yydx ge 85;
strata sex;
run;

