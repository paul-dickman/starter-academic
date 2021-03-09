/***********************************************************
* SAS code accompanying the video lecture:
*
* Introduction to Cox regression
*
* http://pauldickman.com/video/cox-regression/
*
* Paul Dickman
* September 2020
***********************************************************/

/* Download data (in Stata format) from WWW and save it locally */
/* PROC IMPORT does not allow reading the input file from the web (so it has to be saved locally) */
/* You will probably need to update the local file location in the filename statement */
filename dtafile "z:\colon.dta";

proc http
 method="GET"
 url="https://pauldickman.com/data/colon.dta"
 out=dtafile;
run;

/* Convert the Stata file (now saved locally) to a SAS dataset */
proc import datafile=dtafile out=colon replace dbms=dta; run;

/* Create indicator variables for distant stage and age group 75+ */
data distant;
set colon;
distant = (stage=3); 
agegrp3 = (agegrp=3);
run; 

/* Fit a Cox model with one expolanatory variable (distant)*/
proc phreg data=distant;
title1 'Cox proportional hazards model with cause-specific death as the outcome';
model surv_mm*status(0,2,4) = distant / risklimits ties=efron;
run;

/* Now adjust for age (two categories) */
proc phreg data=distant;
title1 'Cox proportional hazards model with cause-specific death as the outcome';
model surv_mm*status(0,2,4) = distant agegrp3 / risklimits ties=efron;
run;

/* Fit a Cox model to just those individuals diagnosed with localised stage*/
/* Request both Wald and LR tests */
proc phreg data=colon(where=(stage=1));
title1 'Cox proportional hazards model with cause-specific death as the outcome';
title2 'Localised colon carcinoma';
class agegrp;
model surv_mm*status(0,2,4) = sex agegrp year8594 / risklimits ties=efron type3(wald lr);
run;

/* Now model age as a continuous variable */
proc phreg data=colon(where=(stage=1));
title1 'Cox proportional hazards model with cause-specific death as the outcome';
title2 'Localised colon carcinoma';
model surv_mm*status(0,2,4) = sex age year8594 / risklimits ties=efron type3(wald lr);
run;

