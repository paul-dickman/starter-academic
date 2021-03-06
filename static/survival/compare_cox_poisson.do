/************************************************************************
COLON_COX_POISSON.DO
Paul Dickman (paul.dickman@ki.se)

Compares estimates from Cox and Poisson regression models fitted to
the Finnish colon cancer data.

First fit the Poisson model using broad intervals and then fit a
Poisson model that is equivalent to the Cox model by splitting at
each failure time. 

Models are fitted to the first 10 years of follow-up only.
*************************************************************************/
set more off
use melanoma, clear
keep if stage == 1
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow

/* Fit the Cox model */
xi: stcox sex year8594 i.agegrp
est store Cox
 
/* Now split and fit the Poisson model */
/* Change the at option to vary the interval length */
stsplit fu, at(0(12)120) trim
xi: streg i.fu sex year8594 i.agegrp, dist(exp)
est store Poisson

/* Compare the estimates */
est table Cox Poisson, eform equations(1) b(%9.6f) se(%9.6f) ///
keep(sex year8594 _Iagegrp_1 _Iagegrp_2 _Iagegrp_3) ///
title("Hazard ratios and standard errors for Cox and Poisson models")

/* THIS WILL TAKE SEVERAL MINUTES TO RUN */
/* Now split very finely (one interval for each failure time) and fit the Poisson model */
/* This is equivalent to the Cox model (Whitehead 1980); estimates and SEs will be identical */
use melanoma, clear
keep if stage == 1
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow
stsplit, at(failures) riskset(riskset)
quietly tab riskset, gen(interval)

/* THIS WILL TAKE SEVERAL MINUTES TO ESTIMATE */
xi: streg interval* sex year8594 i.agegrp, dist(exp)
est store Poisson_fine

/* Compare the estimates and SEs */
est table Cox Poisson_fine Poisson, eform equations(1) ///
keep(sex year8594 _Iagegrp_1 _Iagegrp_2 _Iagegrp_3) ///
se b(%9.6f) se(%9.6f) modelwidth(12) ///
title("Hazard ratios and standard errors for various models")
