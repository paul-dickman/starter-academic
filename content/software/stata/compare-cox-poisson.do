
/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/compare-cox-poisson.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/compare-cox-poisson/

This code illustrates how to both approximate and replicate
a Cox model using Poisson regression.

First fit the Poisson model using broad intervals and then fit a
Poisson model that is equivalent to the Cox model by splitting at
each failure time. 

Models are fitted to the first 10 years of follow-up only.

Paul Dickman, March 2019
***************************************************************************/

set more off
use http://pauldickman.com/data/colon.dta if stage == 1, clear

stset surv_mm, failure(status==1) exit(time 120) id(id) noshow

/* Fit the Cox model */
stcox i.sex i.year8594 i.agegrp
estimates store Cox
 
/* Now split and fit the Poisson model */
/* Change the at option to vary the interval length */
stsplit fu, at(0(12)120) trim
streg i.fu i.sex i.year8594 i.agegrp, dist(exp)
estimates store Poisson

/* Compare the estimates */
estimates table Cox Poisson, eform equations(1) b(%9.6f) se(%9.6f) ///
keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
title("Hazard ratios and standard errors for Cox and Poisson models")

/* THIS MAY TAKE SEVERAL MINUTES TO RUN */
/* Now split very finely (one interval for each failure time) and fit the Poisson model */
/* This is equivalent to the Cox model (Whitehead 1980); estimates and SEs will be identical */
use http://pauldickman.com/data/colon.dta if stage == 1, clear
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow
stsplit, at(failures) riskset(riskset)
quietly tab riskset, gen(interval)

/* THIS MAY TAKE SEVERAL MINUTES TO RUN */
streg interval* i.sex i.year8594 i.agegrp, dist(exp)
estimates store Poisson_fine

/* Compare the estimates and SEs */
estimates table Cox Poisson_fine Poisson, eform equations(1) ///
keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
se b(%9.6f) se(%9.6f) modelwidth(12) ///
title("Hazard ratios and standard errors for various models")

// Now compare with flexible parametric model
use http://pauldickman.com/data/colon.dta if stage == 1, clear
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow

stpm2 i.sex i.year8594 i.agegrp, scale(h) df(5) eform 
estimates store fpm

/* Compare the estimates and SEs */
estimates table Cox fpm Poisson, eform equations(1) ///
keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
se b(%9.6f) se(%9.6f) modelwidth(12) ///
title("Hazard ratios and standard errors for various models")
