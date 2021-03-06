/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/parameterising-interactions.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/parameterising-interactions/

Illustrates Stata factor variable notation and how to reparameterise
a model to get the effect of an exposure for each level of a modifier.

Paul Dickman, Caroline Weibull, May 2019
***************************************************************************/
// exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// This option is needed to reproduce the output on the web page
// I recommend keeping it on permanently
set showbaselevels on

// spline variables for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog

codebook sex subsite

// cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// main effects model
stcox i.sex i.subsite i.agegrp i.stage yearspl*
estimates store main

// default parameterisation of interaction
stcox i.sex##i.subsite i.agegrp i.stage yearspl*
estimates store inter

// test significance of the interaction effect
lrtest main
test 2.sex#2.subsite 2.sex#3.subsite 2.sex#4.subsite

// effect of sex for level 2 of subsite
lincom 2.sex + 2.sex#2.subsite, eform

// effect of sex for level 3 of subsite
lincom 2.sex + 2.sex#3.subsite, eform

// effect of sex for level 4 of subsite
lincom 2.sex + 2.sex#4.subsite, eform

// effect of sex for each level of subsite
stcox i.sex#i.subsite i.subsite i.agegrp i.stage yearspl*

// test significance of the interaction effect
test 2.sex#1.subsite=2.sex#2.subsite=2.sex#3.subsite=2.sex#4.subsite

// stratified model for subsite 2
stcox i.sex i.agegrp i.stage yearspl* if subsite==2

// Analogue to the stratified models
stcox i.sex#i.subsite i.subsite i.agegrp#i.subsite ///
  i.stage#i.subsite c.yearspl*#i.subsite, strata(subsite)



