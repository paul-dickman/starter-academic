/*************************************************************************
Cox regression analysis of localised colon carcinoma diagnosed in
Finland 1975-94 and followed up to the end of 1995.
*************************************************************************/

libname survival 'c:\coursetemp\sas\';

data colon;
set survival.colon;

** make indicator variables for age **;
age_gr1=0; age_gr2=0; age_gr3=0; age_gr4=0;
if age=. then put 'ERROR: Age is missing ' _n_= ;
else if age le 44 then age_gr1=1;
else if age le 59 then age_gr2=1;
else if age le 74 then age_gr3=1;
else if age le 99 then age_gr4=1;
else put 'ERROR: Age out of range ' _n_= age= ;

** make indicator variables for stage **;
 stage0=0; stage1=0; stage2=0; stage3=0;
if age=. then put 'ERROR: Stage is missing ' _n_= ;
else if stage=0 then stage0=1;
else if stage=1 then stage1=1;
else if stage=2 then stage2=1;
else if stage=3 then stage3=1;
else put 'ERROR: Stage out of range ' _n_= stage= ;

label
age_gr1='Indicator for age 0-44'
age_gr2='Indicator for age 45-59'
age_gr3='Indicator for age 60-74'
age_gr4='Indicator for age 75+'
stage0='Indicator for stage unknown'
stage1='Indicator for localised stage'
stage2='Indicator for regional stage'
stage3='Indicator for distant stage'
;
run;

proc tphreg data=colon(where=(stage=1));
title2 'Cox proportional hazards model fitted to cause-specific survival data';
title3 'Localised colon carcinoma';
class agegrp;
model surv_mm*status(0,2,4) = sex agegrp year8594 / risklimits;
run;

proc phreg data=colon(where=(stage=1));
title2 'Cox proportional hazards model fitted to cause-specific survival data';
title3 'The effect of age is allowed to depend on time since diagnosis (as a step function)';
title4 'Survival time is calculated in completed years';
model surv_yy*status(0,2,4) = sex age_gr2-age_gr4 t_age2-t_age4 year8594 t_yr8594 / risklimits;
t_yr8594=0; t_age2=0; t_age3=0; t_age4=0;
if surv_yy ge 2 then do;
t_yr8594=year8594; t_age2=age_gr2; t_age3=age_gr3; t_age4=age_gr4;
end;
Age: Test age_gr2=age_gr3=age_gr4=0;
t_by_age: Test t_age2=t_age3=t_age4=0;
run;
