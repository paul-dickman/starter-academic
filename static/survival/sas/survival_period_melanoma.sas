/****************************************************************
SURVIVAL_PERIOD.SAS

Estimate relative survival using period analysis and produces
output data files that can be used for fitting relative survival
models.

Paul Dickman (paul.dickman@meb.ki.se)
Version 1.0 - June 2004
Version 1.1 - October 2010
Corrected an error in the standard errors for period analysis.
They are now estimated based on transforming the cum hazard.
See http://www.pauldickman.com/rsmodel/stata_colon/standard_errors.pdf
****************************************************************/
title; footnote;

title1 'Melanoma diagnosed in Finland 1975-1994 (follow-up to 1995)';

libname melanoma 'c:\rsmodel\sas_colon\';
options fmtsearch=(melanoma work library) orientation=landscape pageno=1;

/****************************************************************
Define the input and output files.
****************************************************************/
/* Population mortality file */
%let popmort=melanoma.popmort ;

/* Patient data file */
%let patdata=melanoma.melanoma ;

/* Output data file containing individual records */
%let individ=melanoma.individ ;

/* Output data file containing collapsed data */
%let grouped=melanoma.grouped ;

/****************************************************************
The macro variable VARS carries the variables over which the
life tables are stratified.
For example:
%let vars = sex yydx age;
Will result in a lifetable being estimated for each combination
of sex, yydx (year of diagnosis), and age. If, for example, the
variable age contains age at diagnosis in years then categories
can be constructed using a format.
****************************************************************/
%let vars = sex ;
%let formats = sex sex. ;

data &individ;
set &patdata;

/* Restrict to localised stage*/
if stage=1;

/* Create a unique ID for each individual */
id+1;

/****************************************************************
The variable SURV_MM contains survival time in completed months.
We will add 0.5 to all survival times, both to avoid problems
with individuals with time=0 (who are theoretically never at risk
and may be excluded from some analyses) and because this provides
a more accurate estimate of person-time at risk (for Poisson
regression analyses).
****************************************************************/
surv_mm = surv_mm + 0.5;

entry=dx;

/* Create an indicator variable for death due to any cause */
if status in (1,2) then d=1;
else d=0;

drop stage subsite status;
format entry date.;
label id='Unique subject ID';
run;

/*****************************************************************
It is preferable to put the lexis macro in the autocall library
rather than including it as is done here
****************************************************************/
%include 'c:\rsmodel\sas_colon\lexis.sas';

/*****************************************************************
Split by calendar time. ENTRY is the date at which individuals
become at risk. DX is the date of diagnosis. After this split,
the minimum entry date is 01jan1994 and the maximum exit date
is 31dec1995. The date of diagnosis is unchanged but only
person-time at risk between 01jan1994 and 31dec1995 is considered.
****************************************************************/
%lexis (
data=&individ.,
out=&individ.,
breaks = %str( '01jan1994'd,'31dec1995'd ),
origin=0,
entry = entry,
exit = exit,
fail = d
)
;

/*****************************************************************
Split by time since diagnosis. ENTRY is the date at which individuals
become at risk. DX is the date of diagnosis.
*****************************************************************/
%lexis (
data=&individ.,
out=&individ.,
breaks = %str( 0 to 10 by 1 ),
origin = dx,
entry = entry,
exit = exit,
fail = d,
scale = 365.25,
right = right,
risk = y,
lrisk = ln_y,
lint = length,
cint = w,
nint = fu
)
;

/****************************************************************
Create variables for attained age and calendar
year which are 'updated' for each observation for a single
individual. These are the variables by which we will merge in
the expected probabilities of death, so they must have the
same names and same format as the variables indexing the
POPMORT file (sex, _age, _year in this example).
****************************************************************/
data &individ;
set &individ;
length sex 8;

/*********************************************************************
Create a variable for attained age at the start of the interval).
This variable must have the same name and have the same format as the
corresponing variable in the popmort file.
*********************************************************************/
_age=floor(age+left);

/*******************************************************************
Create a variable for calendar period at the start of the interval.
This variable must have the same name and have the same format as the
corresponing variable in the popmort file.
*******************************************************************/
_year=floor(1900+yydx+left);

/* A variable to label the life table output */
range=put(left,4.1) || ' - ' || left(put(right,4.1));

drop entry left right;
run;

/****************************************************************
Now merge in the expected probabilities of death.
****************************************************************/
proc sort data=&individ;
by sex _year _age;
run;

proc sort data=&popmort;
by sex _year _age;
run;

data &individ;
*length d w fu 4 y ln_y length 5;
merge &individ(in=a) &popmort(in=b);
by sex _year _age;
if a;
/* Need to adjust for interval lengths other than 1 year */
p_star=prob**length;
/* Expected number of deaths */
d_star=-log(p_star)*(y/length);
keep &vars fu range length d w p_star y ln_y d_star prob;
label
d_star='Expected number of deaths'
d='Indicator for death during interval'
w='Indicator for censored during interval'
y='Person-time (years) at risk during the interval'
length='Interval length (potential not actual)'
ln_y='ln(person-time at risk)'
p_star='Expected survival probability'
_age='Attained age'
_year='Attained calendar year'
range='Life table interval'
fu='Follow-up interval'
sex='Sex'
;
run;

/****************************************************************
Collapse the data to produce the life table.
****************************************************************/
proc summary data=&individ nway;
var d w p_star y d_star;
id range length;
class &vars fu; /* Follow-up must be the last variable in this list */
output out=&grouped(drop=_type_ rename=(_freq_=l)) sum(d w y d_star)=d w y d_star mean(p_star)=p_star;
format &formats ;
run;

/****************************************************************
Calculate life table quantities.
****************************************************************/
data &grouped;
retain cp cp_star cr 1;
set &grouped;
if fu=1 then do;
  cp=1; cp_star=1; cr=1; var_cLambda=0;
  end;
/* Estimate survival by transforming the cumulative hazard */
p=exp(-(d/y)*length);
r=p/p_star;
cp=cp*p;
cp_star=cp_star*p_star;
cr=cp/cp_star;
ln_y=log(y);
excess=(d-d_star)/y;

/* Standard errors for the observed survivor function based on
   transforming the cumulative hazard */
var_Lambda=length**2*d/y**2; /* Interval-specific */
se_p=p*sqrt(var_Lambda);
var_cLambda+length**2*d/y**2;  /* Cumulative hazard */
se_cp=cp*sqrt(var_cLambda);

/* Standard errors for relative survival */
se_r=se_p/p_star;
se_cr=se_cp/cp_star;

/* Calculate confidence intervals on the log-hazard scale and back transform */
/* First for the interval-specific estimates */
if se_p ne 0 then do;
  /* SE on the log-hazard scale using Taylor series approximation */
  se_lh_p=sqrt( se_p**2/(p*log(p))**2 );
  /* Confidence limits on the log-hazard scale */
  lo_lh_p=log(-log(p))+1.96*se_lh_p;
  hi_lh_p=log(-log(p))-1.96*se_lh_p;
  /* Confidence limits on the survival scale (observed survival) */
  lo_p=exp(-exp(lo_lh_p));
  hi_p=exp(-exp(hi_lh_p));
  /* Confidence limits for the corresponding relative survival rate */
  lo_r=lo_p/p_star;
  hi_r=hi_p/p_star;
  /* Drop temporary variables */
  drop se_lh_p lo_lh_p hi_lh_p;
  /* Formats and labels */
  format lo_p hi_p lo_r hi_r 8.5;
  label
  lo_p='Lower 95% CI for P'
  hi_p='Upper 95% CI for P'
  lo_r='Lower 95% CI for R'
  hi_r='Upper 95% CI for R'
  ;
end;

/* Now for the cumulative estimates */
if se_cp ne 0 then do;
  /* SE on the log-hazard scale using Taylor series approximation */
  se_lh_cp=sqrt( se_cp**2/(cp*log(cp))**2 );
  /* Confidence limits on the log-hazard scale */
  lo_lh_cp=log(-log(cp))+1.96*se_lh_cp;
  hi_lh_cp=log(-log(cp))-1.96*se_lh_cp;
  /* Confidence limits on the survival scale (observed survival) */
  lo_cp=exp(-exp(lo_lh_cp));
  hi_cp=exp(-exp(hi_lh_cp));
  /* Confidence limits for the corresponding relative survival rate */
  lo_cr=lo_cp/cp_star;
  hi_cr=hi_cp/cp_star;
  /* Drop temporary variables */
  drop se_lh_cp lo_lh_cp hi_lh_cp;
  /* Formats and labels */
  format lo_cp hi_cp lo_cr hi_cr 8.5;
  label
  lo_cp='Lower 95% CI for CP'
  hi_cp='Upper 95% CI for CP'
  lo_cr='Lower 95% CI for CR'
  hi_cr='Upper 95% CI for CR'
  ;
end;

label
range='Interval'
fu='Interval'
l='Alive at start'
d='Deaths'
w='Withdrawals'
p='Interval-specific observed survival'
cp='Cumulative observed survival'
r='Interval-specific relative survival'
cr='Cumulative relative survival'
p_star='Interval-specific expected survival'
cp_star='Cumulative expected survival'
ln_y='ln(person-time) (using exact times)'
y='Person-time at risk (using exact times)'
d_star='Expected deaths (using exact times)'
excess='Empirical excess hazard'
se_p='Standard error of P'
se_r='Standard error of R'
se_cp='Standard error of CP'
se_cr='Standard error of CR'
;
run;

/****************************************************************
Print the lifetables. We first need to extract the last variable
in the varlist to use as the argument in the pageby command.
****************************************************************/
%let lastvar = %scan(&vars,-1);

proc print data=&grouped noobs label;
title2 'Life table estimates of patient survival using period analysis';
title3 'Period window is from 1 Jan 1994 until 31 Dec 1995';
by &vars;
pageby &lastvar;
var range l d y p se_p cp se_cp p_star cp_star r cr;
format fu 3.0 l d 4.0 y 8.1 p se_p cp se_cp p_star cp_star r cr se_p se_r se_cp se_cr 7.4;
label l='L' d='D' w='W';
run;
