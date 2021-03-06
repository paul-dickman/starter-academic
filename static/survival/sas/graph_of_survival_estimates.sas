/****************************************************************
GRAPH_OF_SURVIVAL_ESTIMATES.SAS

After estimating survival using the code in SURVIVAL.SAS, the 
following code illustrates how one can graph survival estimates.

Paul Dickman (paul.dickman@meb.ki.se)
June 2004
****************************************************************/
%let width = 2.0 ;  /* width of the plot lines */
%let height = 3.0 ; /* height of the plot symbols */
%let txt_ht = 3.2 ; /* height of the text */

goptions reset=all gunit=pct ftext="Arial"
         htitle=3.5 htext=&txt_ht noprompt
         rotate=landscape
;

symbol1 c=black v=dot  height=2.0 line=1;  /* solid line */
symbol2 c=black v=square  height=2.0 line=20; /* dashed line */

/* horizontal axis: follow-up */
axis1   label=('Follow-up time in years')
        order=(0 to 11 by 1)
        major=(height=0.5)
        minor=none
        ;

/* vertical axis: excess mortality  */
axis2   label=(j=r 'Excess' j=r 'deaths per' j=r 'person-year')
        /*order=(0 to 0.008 by 0.001)*/
        major=(height=0.5)
        minor=none
        ;

/* vertical axis: relative survival  */
axis3   label=(j=r 'Survival')
        order=(0 to 1 by 0.1)
        major=(height=0.5)
        minor=none
        ;

legend1 frame position=(top center inside) mode=protect;
legend2 frame position=(bottom center inside) mode=protect;

/* Plot of the excess mortality rate */
proc gplot data=&grouped(where=(yydx=85 and age=60));
title "Excess mortality for patients aged 60-74 diagnosed 1985-94";
plot excess*fu=sex / frame haxis=axis1 vaxis=axis2 legend=legend1;
run;
quit;


/* Add observations with cumulative survival=1 at time zero */
data temp;
set &grouped;
output;
if fu=1 then do;
fu=0; cr=1; cp=1; output;
end;
run;

proc sort data=temp;
by &vars fu;
run;

symbol1 c=black v=none i=j line=1;  /* solid line */
symbol2 c=black v=none i=j line=20; /* dashed line */

/* Cumulative observed survival stratified by sex */
proc gplot data=temp(where=(yydx=85 and age=60));
title 'Cumulative observed survival stratified by sex';
plot cp*fu=sex / frame haxis=axis1 vaxis=axis3 legend=legend2;
run;
quit;

/* Cumulative relative survival stratified by sex */
proc gplot data=temp(where=(yydx=85 and age=60));
title 'Cumulative relative survival stratified by sex';
plot cr*fu=sex / frame haxis=axis1 vaxis=axis3 legend=legend2;
run;
quit;

/* Relative and observed survival on the same graph */
symbol1 c=black v=none i=j line=1;  /* solid line */
symbol2 c=black v=none i=j line=20; /* dashed line */
symbol3 c=red v=none i=j line=1;  /* solid line */
symbol4 c=red v=none i=j line=20; /* dashed line */

proc gplot data=temp(where=(yydx=85 and age=60));
title 'Cumulative observed (black lines) and relative survival (red lines) stratified by sex';
plot cr*fu=sex / frame haxis=axis1 vaxis=axis3 legend=legend2;
plot2 cp*fu=sex / frame vaxis=axis3;
run;
quit;


