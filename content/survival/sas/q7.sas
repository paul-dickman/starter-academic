/*************************************************************************
Q9. Poisson regression analysis of localised skin melanoma diagnosed in
Finland 1975-94 and followed up to the end of 1995.
*************************************************************************/

libname survival 'c:\coursetemp\sas\';
options fmtsearch=(colon work library) orientation=portrait pageno=1;
%include 'c:\coursetemp\sas\lexis.sas';

data melanoma;
set survival.melanoma(where=(stage=1));
/* censor all survival times at 120 months */
if surv_mm gt 120 then do;
   surv_mm=120; status=0;
   end;
dead_cancer=(status=1);
entry=0; /* requird by lexis macro */
run;

/*****************************************************************
Split person-time into annual intervals.
The is transformed to years (scale=12).
****************************************************************/
%lexis (
data=melanoma,
out=melanoma_split,
breaks = %str( 0 to 10 by 1 ),
origin = 0,
entry = entry,
exit = surv_mm,
fail = dead_cancer,
scale = 12,
right = right,
risk = y,
lrisk = ln_y,
nint = fu
)
;

/**************************************************************
Now tabulate mortality rates for each timeband (exercise 7(e).
**************************************************************/
proc summary data=melanoma_split nway;
var y dead_cancer;
class fu;
output out=rates(drop=_type_ _freq_) sum=y dead_cancer;
run;

data rates;
set rates;
_rate=1000*(dead_cancer/y);
ci_low=_rate/exp(1.96*sqrt(1/dead_cancer));
ci_high=_rate*exp(1.96*sqrt(1/dead_cancer));
run;

proc print;
title1 '7(e) Table of cases, person-years, and rates per 1000 person-years';
var fu dead_cancer y _rate ci_low ci_high;
run;

/* Excercise 7 (i): model adjusted for time, sex, age, and period */
ods output parameterestimates=parmest /* parameter estimates */
           modelinfo=modelinfo        /* Model information */
           modelfit=modelfit          /* Model fit information */
           convergencestatus=converge /* Whether the model converged */
           type3=type3estimates;      /* Type III estimates */

proc genmod data=melanoma_split order=formatted;
title1 '7(i) Poisson regression model for cause-specific mortality';
class fu sex age yydx;
model dead_cancer = fu sex yydx age / error=poisson offset=ln_y type3;
format fu fu. age age. yydx yydx.;
run;

ods output close;

data parmest;
set parmest;
if df gt 0 then do;
rr=exp(estimate);
low_rr=exp(estimate-1.96*stderr);
hi_rr=exp(estimate+1.96*stderr);
end;
run;

proc print data=parmest label noobs;
title2 'Estimates for beta and relative risks (rr=exp(beta))';
    id parameter; by parameter notsorted;
    var level1 estimate stderr rr low_rr hi_rr;
    format estimate stderr rr low_rr hi_rr 6.3;
    label
        parameter='Parameter'
        level1='Level'
        estimate='Estimate'
        stderr='Standard Error'
        rr='Estimated RR'
        low_rr='Lower limit 95% CI'
        hi_rr='Upper limit 95% CI';
run;

