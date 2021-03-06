/*************************************************************************
Q9. Cox regression analysis of localised skin melanoma diagnosed in
Finland 1975-94 and followed up to the end of 1995.
*************************************************************************/

libname survival 'c:\coursetemp\sas\';

data melanoma;
set survival.melanoma(where=(stage=1));
/* censor all survival times at 120 months */
if surv_mm gt 120 then do;
   surv_mm=120; status=0;
   end;
run;

proc tphreg data=melanoma;
title1 'Q9a Cox model for cause-specific mortality, localised melanoma';
model surv_mm*status(0,2,4) = year8594 / risklimits;
run;

proc tphreg data=melanoma;
title1 'Q9c Cox model for cause-specific mortality, localised melanoma';
class agegrp / ref=first;
model surv_mm*status(0,2,4) = sex agegrp year8594 / risklimits;
run;

