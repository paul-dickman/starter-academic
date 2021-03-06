/* create a dataset with one variable, X,
** which takes values 1 to 99 plus two obs
** with missing values */
data test;
do x=1 to 100;
output;
end;
x=.;
output; output;
run;

/* create the cutpoints for the quintiles */
proc univariate noprint data=test;
var x;
output out=quintile pctlpts=20 40 60 80 pctlpre=pct;
run;

/* write the cutpoints to macro variables */
data _null_;
set quintile;
call symput('q1',pct20) ;
call symput('q2',pct40) ;
call symput('q3',pct60) ;
call symput('q4',pct80) ;
run;

/* create a new variable containing the quintiles */
data test;
set test;
if x =. then x_quint = .;
else if x <= &q1 then x_quint=1;
else if x <= &q2 then x_quint=2;
else if x <= &q3 then x_quint=3;
else if x <= &q4 then x_quint=4;
else x_quint=5;
run;


/* test to make sure it worked */
proc means data=test missing;
class x_quint;
var x;
run;
