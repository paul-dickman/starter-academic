
/* Generate some normally distributed data */
data norm;
do i=1 to 500;
x=rannor(-5);
output;
end;
run;

/* A simple example */
proc capability data=norm graphics normaltest;
title 'Histogram using default settings';
var x;
histogram x;
run;


/* A more advanced example */
/* First set some graphics options */
goptions reset=all gunit=pct rotate=landscape
         htitle=3.0 htext=2.5 noprompt
         horigin=0.4in vorigin=0.4in
         vsize=7.0in hsize=10.0in
         device=win target=winprtg ftext=swiss
;

proc capability data=norm graphics normaltest;
title 'Histogram using additional options';
var x;
histogram x /
    midpoints=-3.5 to 3.5 by 0.1
    normal;
inset min median max mean std / format=6.3;
run;

proc capability data=norm graphics normaltest;
title 'Test of normality';
var x;
qqplot x / normal (mu=est sigma=est);
run;
quit;
