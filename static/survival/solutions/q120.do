
//==================//
// EXERCISE 120
// REVISED MAY 2015
//==================//

/* Data set used */
use melanoma if stage==1, clear

/* Stset data */
stset surv_mm, failure(status==1) id(id) exit(time 120)

/* Cox regression */
stcox year8594

/* Log-rank test */
sts test year8594

/* Cox regression including sex and age */
stcox sex year8594 i.agegrp

/* Wald test */
test 1.agegrp 2.agegrp 3.agegrp

/* Cox regression stored as model A */
stcox sex year8594 i.agegrp
est store A

/* Cox regression to compare with */
stcox sex year8594

/* LR test */
lrtest A

/* Comparison of Poisson and Cox regression models */
stcox year8594 sex i.agegrp
est store Cox

stsplit fu, at(0(12)120) trim
streg i.fu year8594 sex i.agegrp, dist(exp)
est store Poisson
est table Cox Poisson, eform equations(1)


/* Re-load data */
use melanoma, clear
keep if stage == 1

/* Stset data */
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow

/* Fit the Cox model */
stcox sex year8594 i.agegrp
est store Cox
 
/* Now split and fit the Poisson model */
/* Change the at option to vary the interval length */
stsplit fu, at(0(12)120) trim
streg i.fu sex year8594 i.agegrp, dist(exp)
est store Poisson

/* Compare the estimates */
est table Cox Poisson, eform equations(1) b(%9.6f) se(%9.6f) ///
keep(sex year8594 1.agegrp 2.agegrp 3.agegrp) ///
title("Hazard ratios and standard errors for Cox and Poisson models")


/* THIS MIGHT TAKE A COUPLE OF MINUTES TO RUN */
/* Now split very finely (one interval for each failure time) and fit the Poisson model */
/* This is equivalent to the Cox model (Whitehead 1980); estimates and SEs will be identical */
use melanoma, clear
keep if stage == 1
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow
stsplit, at(failures) riskset(riskset)
quietly tab riskset, gen(interval)

/* THIS MIGHT TAKE A COUPLE OF MINUTES  TO ESTIMATE */
streg interval* sex year8594 i.agegrp, dist(exp)
est store Poisson_fine

/* Compare the estimates and SEs */
est table Cox Poisson_fine Poisson, eform equations(1) ///
keep(sex year8594 1.agegrp 2.agegrp 3.agegrp) ///
se b(%9.6f) se(%9.6f) modelwidth(12) ///
title("Hazard ratios and standard errors for various models")


/* Re-load data */
use melanoma if stage==1, clear
stset surv_mm, failure(status==1) id(id) exit(time 120)

/* Split on time since diagnosis (1-month intervals) */
stsplit fu, at(0(1)120) trim

/* Create basis for restricted cubic spline */
mkspline fu_rcs=fu, cubic

/* Run Poisson model incl. the splines */
streg fu_rcs* year8594 sex i.agegrp, dist(exp)

/* Predict the log hazard and plot it against follow-up time */
predict xb, xb
twoway line xb fu if year8594==0 & sex==1 & agegrp==1, sort


