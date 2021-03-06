data bronchit;
input events trials smk ses age;
label
events='no. with bronchitis'
trials='no. at risk'
smk='smoking status'
ses='socioeconomic status'
;
cards;
38  111 0 1 0
48  134 0 1 1
28   95 0 0 0
40  124 0 0 1
84  173 1 1 0
102 148 1 1 1
47  143 1 0 0
59  112 1 0 1
;
run;

proc format;
value sesf
     0='low'
     1='high';

value agef
     0='<40'
     1='40-59';

value smkf
     0='never'
     1='ever';
run;

/***
We first fit the independent risk factor model.
****/

proc genmod data=bronchit order=formatted;
format age agef. ses sesf. smk smkf.;
class smk age ses;
model events/trials = smk age ses / error=bin link=logit type3;
make 'parmest' out=parmest;
run;

/* PROC GENMOD does not report the odds ratio directly,
** only the estimated betas (log odds ratios), but we can
** exponentiate these in a data step to get estimated odds ratios */
data parmest;
set parmest;
if parm='scale' then delete;
or=exp(estimate);
low_or=exp(estimate-1.96*stderr);
hi_or=exp(estimate+1.96*stderr);
run;

proc print data=parmest label noobs;
title 'estimated odds ratios and 95% confidence intervals';
var parm level1 or low_or hi_or;
format or low_or hi_or 6.3;
label
parm='variable'
level1='par1'
or='estimated or'
low_or='lower limit 95% ci'
hi_or='upper limit 95% ci'
;
run;

/****
In order to test for effect modification between smoking and age,
a smk*age term is added to the model. The significance test for the
presence of effect modification is found for this term in the table
of type3 LR tests (with 1 df).
*****/

proc genmod data=bronchit order=formatted;
format age agef. ses sesf. smk smkf.;
class smk age ses;
model events/trials = smk age ses smk*age / error=bin link=logit type3;
make 'parmest' out=parmest;
run;

data parmest;
set parmest;
if parm='scale' then delete;
or=exp(estimate);
low_or=exp(estimate-1.96*stderr);
hi_or=exp(estimate+1.96*stderr);
run;

proc print data=parmest label noobs;
title 'estimated odds ratios and 95% confidence intervals';
var parm level1 level2 or low_or hi_or;
format or low_or hi_or 6.3;
label
parm='variable'
level1='par1'
level2='par2'
or='estimated or'
low_or='lower limit 95% ci'
hi_or='upper limit 95% ci'
;
run;

/***
In order to estimate odds ratios for the compound variable
(smk*age) it is neccessary to do some manipulation. For example,
the estimated OR for old smokers compared to the reference group
(young never smokers)is given by exp(0.408+0.104+0.729)=3.455.

If you want to display the nature of the effect modification,
remove the corresponding main effects (smk and age) and leave
only the term smk*age in the model. This is the exact same
model as the previous model, except it is parameterised in a
way which simplifies interpretation of the compound factor.
The odds ratios for the compound factor can now be compared
with the expected pattern from the independent risk factor model.
****/

proc genmod data=bronchit order=formatted;
format age agef. ses sesf. smk smkf.;
class smk age ses;
model events/trials = ses smk*age / error=bin link=logit type3;
make 'parmest' out=parmest;
run;

data parmest;
set parmest;
if parm='scale' then delete;
or=exp(estimate);
low_or=exp(estimate-1.96*stderr);
hi_or=exp(estimate+1.96*stderr);
run;

proc print data=parmest label noobs;
title 'estimated odds ratios and 95% confidence intervals';
var parm level1 level2 or low_or hi_or;
format or low_or hi_or 6.3;
label
parm='variable'
level1='par1'
level2='par2'
or='estimated or'
low_or='lower limit 95% ci'
hi_or='upper limit 95% ci'
;
run;
