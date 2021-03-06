/*************************************************************************
Cox regression analysis of localised colon carcinoma diagnosed in
Finland 1975-94 and followed up to the end of 1995.
*************************************************************************/
libname rsmodel 'C:\rsmodel\sas_colon';

proc format;
value sex
1='Male'
2='Female'
;
value yydx
75-84='1975-84'
85-94='1985-94'
;
value age
0-44='0-44'
45-59='45-59'
60-74='60-74'
75-high='75+'
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
value colonsub
1='Coecum and ascending'
2='Transverse'
3='Descending and sigmoid'
4='Other and NOS'
;
run;

/**************************************************************************
Modelling year of diagnosis as a metric variable.
**************************************************************************/
proc phreg data=rsmodel.colon(where=(stage=1));
model surv_mm*status(0,2,4) = sex yydx / risklimits;
run;

/**************************************************************************
Categorising year of diagnosis into two periods using a dummy variable.
**************************************************************************/
proc phreg data=rsmodel.colon(where=(stage=1));
model surv_mm*status(0,2,4) = sex year8594 / risklimits;
run;

/**************************************************************************
Categorising year of diagnosis into two periods using a SAS format.
**************************************************************************/
proc tphreg data=rsmodel.colon(where=(stage=1));
class yydx / ref=first;
model surv_mm*status(0,2,4) = sex yydx / risklimits;
format yydx yydx.;
run;

/**************************************************************************
Adjusting for age as a metric variable.
**************************************************************************/
proc tphreg data=rsmodel.colon(where=(stage=1));
class yydx / ref=first;
model surv_mm*status(0,2,4) = sex yydx age / risklimits;
format yydx yydx.;
run;

/**************************************************************************
Grouping age into categories using a SAS format.
**************************************************************************/
proc tphreg data=rsmodel.colon(where=(stage=1));
class yydx age / ref=first;
model surv_mm*status(0,2,4) = sex yydx age / risklimits;
format yydx yydx. age age.;
run;

/**************************************************************************
Specifying a different reference category for age.
**************************************************************************/
proc tphreg data=rsmodel.colon(where=(stage=1));
class yydx age(ref='45-59') / ref=first;
model surv_mm*status(0,2,4) = sex yydx age / risklimits;
format yydx yydx. age age.;
run;

/**************************************************************************
Modelling an interaction between period and stage.
**************************************************************************/
proc tphreg data=rsmodel.colon;
title 'Interaction';
class yydx age(ref='45-59') stage(ref='Localised') subsite / ref=first;
model surv_mm*status(0,2,4) = sex yydx age stage subsite yydx*stage / risklimits;
format yydx yydx. age age.;
run;

/**************************************************************************
Try to estimate the effect of period for each level of a stage by 
leaving out the main effect of period. This does not work!
**************************************************************************/
proc tphreg data=rsmodel.colon;
class yydx age(ref='45-59') stage(ref='Localised') subsite / ref=first;
model surv_mm*status(0,2,4) = sex age stage subsite yydx*stage / risklimits;
format yydx yydx. age age.;
run;

/**************************************************************************
Estimate the effect of period for each level of stage using
the contrast statement.
**************************************************************************/
proc tphreg data=rsmodel.colon;
class yydx age(ref='45-59') stage(ref='Localised') subsite / ref=first;
model surv_mm*status(0,2,4) = sex yydx age stage subsite yydx*stage / risklimits;
format yydx yydx. age age.;
contrast 'Effect of period for localised' YYDX 1 / estimate=exp;
contrast 'Effect of period for distant' YYDX 1 YYDX*STAGE 1 0 0 / estimate=exp;
contrast 'Effect of period for regional' YYDX 1 YYDX*STAGE 0 1 0 / estimate=exp;
contrast 'Effect of period for unknown' YYDX 1 YYDX*STAGE 0 0 1 / estimate=exp;
run;

/**************************************************************************
Residual plots using ODS graph.
Does not work with JRE versions higher than 1.4.1_02
See http://support.sas.com/techsup/unotes/SN/015/015237.html
**************************************************************************/
ods html;
ods graphics on;
proc phreg data=rsmodel.colon(where=(stage=1));
assess var=(age) ph;
model surv_mm*status(0,2,4) = sex yydx age / risklimits;
format yydx yydx. age age.;
run;
quit;
ods graphics off;
ods html close;

/**************************************************************************
Including a time-varying effect of exposure.
Estimate separate hazard ratios for the effect of calendar period before 
and after 2 years (24 months).
**************************************************************************/
proc tphreg data=rsmodel.colon(where=(stage=1));
class age / ref=first;
model surv_mm*status(0,2,4) = sex age year8594 t_yr8594 / risklimits;
if surv_mm ge 24 then t_yr8594=year8594;
else t_yr8594=0;
format age age.;
run;

/**************************************************************************
A stratified Cox model.
**************************************************************************/
proc tphreg data=rsmodel.colon(where=(stage=1));
class yydx / ref=first;
model surv_mm*status(0,2,4) = sex yydx / risklimits;
strata age (45,60,75);
format yydx yydx.;
run;

/**************************************************************************
Using calendar time as the timescale
**************************************************************************/
proc tphreg data=rsmodel.colon(where=(stage=1));
class age(ref='45-59') / ref=first;
model exit*status(0,2,4) = sex age / risklimits entry=dx;
format age age.;
run;

