/****************************************************************
TABLE_OF_SURVIVAL_ESTIMATES.SAS

After estimating survival using the code in SURVIVAL.SAS, the 
following code illustrates how one can extract selected 
estimates (for example, RSR at 1,5,10, and 20 years with CIs).

Note that the following code assumes that survival has been 
estimated for annual life-table intervals. 

Paul Dickman (paul.dickman@meb.ki.se)
June 2004
****************************************************************/

data summary;
retain l_zero cr1 cr5 cr10 cr20 cicr1 cicr5 cicr10 cicr20;
length cicr5 $ 12;
set &grouped;
by &vars fu;
if fu=1 then do;
  l_zero=l; cr1=.; cr5=.; cr10=.; cr20=.;
  end;
if fu=1 then do; cr1=cr; cicr1='('||put(lo_cr,4.2)||', '||left(put(hi_cr,4.2))||')'; end;
if fu=5 then do; cr5=cr; cicr5='('||put(lo_cr,4.2)||', '||left(put(hi_cr,4.2))||')'; end;
if fu=10 then do; cr10=cr; cicr10='('||put(lo_cr,4.2)||', '||left(put(hi_cr,4.2))||')'; end;
if fu=20 then do; cr20=cr; cicr20='('||put(lo_cr,4.2)||', '||left(put(hi_cr,4.2))||')'; end;
if last.&lastvar then output;
label
l_zero='l_zero'
cr1='1-year cum RSR'
cr5='5-year cum RSR'
cr10='10-year cum RSR'
cr20='20-year cum RSR'
;
run;

proc print data=summary noobs;
var &vars l_zero cr5 cicr5 cr10 cicr10 cr20 cicr20 ;
format cr5 cr10 cr20 4.2 age yydx 8.;
run;
