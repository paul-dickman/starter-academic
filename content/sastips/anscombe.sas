/* clear all graphs from the graphics catalog */
proc greplay nofs igout=work.gseg;
delete _all_;
run;
quit;
  
data anscombe;
input set x y;
datalines;
1 10 8.04
1 8 6.95
1 13 7.58
1 9 8.81
1 11 8.33
1 14 9.96
1 6 7.24
1 4 4.26
1 12 10.84
1 7 4.82
1 5 5.68
2 10 9.14
2 8 8.14
2 13 8.74
2 9 8.77
2 11 9.26
2 14 8.1
2 6 6.13
2 4 3.1
2 12 9.13
2 7 7.26
2 5 4.74
3 10 7.46
3 8 6.77
3 13 12.74
3 9 7.11
3 11 7.81
3 14 8.84
3 6 6.08
3 4 5.39
3 12 8.15
3 7 6.42
3 5 5.73
4 8 6.58
4 8 5.76
4 8 7.71
4 8 8.84
4 8 8.47
4 8 7.04
4 8 5.25
4 8 5.56
4 8 7.91
4 8 6.89
4 19 12.5

;
run;

/* set the graphics environment */
goptions reset=all gunit=pct hsize=24cm vsize=19cm
         htitle=4.0 htext=3 noprompt
         rotate=landscape horigin=1.5cm vorigin=1cm
         device=win target=winprtg ftext=swiss
;

/* define horizontal axis characteristics for follow-up graphs */
axis1   offset=(0)
        order=(0 to 20 by 2)
        minor=none
        major=(height=1.5)
        ;


/* vertical axis characteristics */
axis2   offset=(0)
        order=(0 to 16 by 2)
        major=(height=1.0)
        minor=none
        ;

symbol1 cv=black i=none width=3 height=3 i=r value=dot;

proc gplot;
title 'Plots of the Anscombe data with fitted regression line';
plot y*x / haxis=axis1 vaxis=axis2;
by set;
run;
quit;

proc reg;
title1 'Regression models fitted to the Anscombe data';
title2 'The SAS code is available at http://www.pauldickman.com/teaching/sas/anscombe.sas';
model y=x;
by set;
output out=outstats cookd=cookd student=student;
run;
quit;


proc print;
run;

/* New vertical axis characteristics */
axis3   offset=(0)
        order=(-4 to 4 by 1)
        major=(height=1.0)
        minor=none
        ;

symbol1 cv=black i=none width=3 height=3 i=none value=dot;

proc gplot data=outstats;
title 'Plots of studentized residuals vs X';
plot student*x / haxis=axis1 vaxis=axis3;
by set;
run;
quit;


/** Different symbols on the same plot **/

symbol1 cv=black i=none width=3 height=3 i=none value=dot;
symbol2 cv=black i=none width=3 height=3 i=none value=circle;

legend1 frame label=('Data set') value=(j=l) mode=protect position=(bottom center inside);

proc gplot data=outstats(where=(set in (2,3)));
title 'Plots of studentized residuals vs X for sets 1 and 2';
plot student*x=set / haxis=axis1 vaxis=axis3 legend=legend1;
run;
quit;


/* New vertical axis characteristics */
axis4   offset=(0)
        order=(0 to 6 by 1)
        label=('Cook''s D')
        major=(height=1.0)
        minor=none
        ;

proc gplot data=outstats;
title 'Plots of Cook''s distance vs X';
plot cookd*x / haxis=axis1 vaxis=axis4;
by set;
run;
quit;


/* create the annotate data set */
data ann;
   length function $ 8 text $ 30;
   retain xsys ysys hsys '3' function 'label'
   size 3 x 66 y 75;
   text='Outlier';
   output;
run;

symbol1 cv=black i=none width=3 height=3 i=r value=dot;

proc gplot data=anscombe(where=(set=3));
title 'Plots of the Anscombe data (set 3) with fitted regression line';
plot y*x / haxis=axis1 vaxis=axis2 annotate=ann;
run;
quit;


/* replay four graphs into a template */
proc greplay nofs tc=sashelp.templt igout=gseg;
template l2r2;
treplay 1:gplot
        2:gplot1
        3:gplot2
        4:gplot3
        ;
treplay 1:gplot4
        2:gplot5
        3:gplot6
        4:gplot7
        ;
treplay 1:gplot9
        2:gplot10
        3:gplot11
        4:gplot12
        ;
run;
quit;
