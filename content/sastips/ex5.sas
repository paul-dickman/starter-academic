data t1;
  label y='BP (mmHg)' x='Time (hours)';
  retain seed 3240877;
  do x=1 to 10;
    y=x+normal(seed);
    output;
  end;
run;
data t2; /* As t1 but two treatment groups */
  label y='BP (mmHg)' x='Time (hours)' group='Treatment' z='Pain';
  retain seed 3240877;
  do group=1 to 2;
    do x=1 to 10;
      y=x+normal(seed);
      z=-x-normal(seed);
      output;
    end;
  end;
run;

*-- Empty the default graph output catalog;
proc datasets lib=work mt=cat nolist;delete gseg;quit;

title1 j=L '1a) Low resolution graph';
proc plot data=t1;
  plot y*x;
run;quit;

* 1b) First example. Default graph ;
goptions reset=all;
title1 j=L '1a) Default graph';
proc gplot data=t1;
  plot y*x;
run;quit;

* 1c) 1b + apply some general options ;
goptions reset=all;
goptions targetdevice=cgmof97l
         ftext="Arial" htext=2.2
         display
         rotate=l
;
title1 j=L '1c) 1b+apply some general options';
proc gplot data=t1;
  plot y*x;
run;quit;


* 1d) 1c + symbols ;
title1 j=L '1c) 1b + apply symbol statement';
proc gplot data=t1;
  symbol1 c=blue i=join v=circle;
  plot y*x=1;
run;quit;

* 2a) Different plot symbols for different treatment groups (controlled by =group);
title1 j=L h=2 '2a) Different plot symbols for different treatment groups (controlled by =group)';
proc gplot data=t2;
  symbol1 c=blue i=join v=circle;
  symbol2 c=red  i=splines v==;
  plot y*x=group;
run;quit;

* 2b) 2a + modify axis lines;
title1 j=L h=2 '2b) 2a + modify axis lines';
proc gplot data=t2;
  symbol1 c=blue i=join v=circle;
  symbol2 c=red  i=splines v==;
  axis1 minor=none offset=(0,0) label=(a=90); *-- To be used as y-axis ;
  axis2 minor=none offset=(0,0);              *-- To be used as x-axis ;
  plot y*x=group
  / vaxis=axis1 haxis=axis2;
run;quit;

* 2c) 2b + modify symbols description label (the legend);
title1 j=L h=2 '2c) 2b + modify symbols + legend statment + rotate axis values';
proc gplot data=t2;
  symbol1 c=blue i=stepj   v=square  l=2;
  symbol2 c=red  i=splines v==       h=3;
  axis1 minor=none offset=(0,0) label=(a=90); *-- To be used as y-axis ;
  axis2 minor=none offset=(0,0) value=(a=60);              *-- To be used as x-axis ;
  legend1 position=(inside top left) frame label=('Trt:');
  plot y*x=group
  / vaxis=axis1 haxis=axis2 legend=legend1;
run;quit;

* 2d) 2c + use SAS format for the legend ;
title1 j=L h=2 '2d) 2c + modify legend (apply SAS format)';
proc format;
  value grpfmt 1='New treatment' 2='Old treatment';
run;
proc gplot data=t2;
  symbol1 c=blue i=join v=circle;
  symbol2 c=red  i=splines v==;
  axis1 minor=none offset=(0,0) label=(a=90); *-- To be used as y-axis ;
  axis2 minor=none offset=(0,0);              *-- To be used as x-axis ;
  legend1 position=(inside bottom right) frame label=none shape=symbol(0.0001,2.6) down=2 value=(j=L);
  plot y*x=group
  / vaxis=axis1 haxis=axis2 legend=legend1;
  format group grpfmt.;
run;quit;

* 2e) 2d + overlay second graph on the right y-axis and change order on the left y-axis;
title1 j=L h=2 '2e)' move=(5pct,97pct) '2d + overlay second graph on the right y-axis';
title2 j=L h=2       move=(5pct,93pct) 'set title2 line and change order of left y-axis';
proc gplot data=t2;
  symbol1 c=blue i=join    v=circle;
  symbol2 c=red  i=splines v==;
  symbol3 c=blue i=join    v=dot;
  symbol4 c=red  i=splines v=square;
  axis1 minor=none offset=(0,0) label=(a=90) order=0 to 15 by 3; *-- To be used as y-axis ;
  axis2 minor=none offset=(0,0);              *-- To be used as x-axis ;
  axis3 minor=none offset=(0,0) label=(a=90); *-- To be used as right y-axis ;
  legend1 position=(inside middle left) frame label=none shape=symbol(0.0001,2.6) down=2 value=(j=L);
  plot y*x=group
  / vaxis=axis1 haxis=axis2 legend=legend1;
  format group grpfmt.;

  plot2 z*x=group / nolegend haxis=axis2 vaxis=axis3;
run;quit;




* 3) pointlabel ;
data t3;
  drop seed;
  retain seed 23477;
  set t1;
  lbl=int(uniform(seed)*10);
run;


title1 j=L '3a) Pointlabel in symbol statement';
proc gplot data=t3;
  symbol1 c=blue i=join v=circle pointlabel=('#lbl');
  plot y*x=1 / vaxis=axis1 haxis=axis2;
run;quit;

title1 j=L '3b) 3a + formatted';
proc format;
  value lblfmt 0-5='M' 6-9=' ';
run;
proc gplot data=t3;
  symbol1 c=blue i=join v=circle pointlabel=(c=red h=2 f="Arial" '#lbl');
  plot y*x=1 / vaxis=axis1 haxis=axis2;
  format lbl lblfmt.;
run;quit;

goptions reset=all;
goptions device=win display htext=2 ftext=german;
title1 j=L '4a) By statement';
proc gplot data=t2;
  symbol1 c=black i=join v=square;
  symbol2 c=black i=join v=circle;
  axis1 minor=none offset=(0,0) label=(a=90);
  axis2 minor=none offset=(0,0);
  plot y*x=group  / vaxis=axis1 haxis=axis2 nolegend;
  by group;
run;quit;

title1 j=L "4a) By statement using '#byval' and '#byvar'";
title2 j=L "The variable #byvar1' takes the value #byval1";
proc gplot data=t2 uniform;
  symbol1 c=black i=join v=square;
  symbol2 c=black i=join v=circle;
  axis1 minor=none offset=(0,0) label=(a=90);
  axis2 minor=none offset=(0,0);
  plot y*x=1  / vaxis=axis1 haxis=axis2 nolegend;
  by group;
run;quit;


*%toword1(xs=31,ys=35);
