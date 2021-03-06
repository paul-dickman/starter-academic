
//==================//
// EXERCISE 123
// REVISED MAY 2015
//==================//

/* Data set used */
use melanoma, clear

stset surv_mm, failure(status==1)

/* Cox regression */
stcox sex

/* Cox regression controlling for possible confounders */
stcox sex i.agegrp i.stage i.subsite year8594

/* Cox regression with interactions */
stcox i.agegrp i.sex#i.agegrp

/* Test of whether the HR's for sex differ across age groups */
test 2.sex#0.agegrp = 2.sex#1.agegrp = 2.sex#2.agegrp = 2.sex#3.agegrp

/* Cox regression with main effects and interactions */
stcox year8594 i.subsite i.stage i.agegrp i.sex#i.agegrp

/* Test of whether the HR's for sex differ across age groups */
test 2.sex#0.agegrp = 2.sex#1.agegrp = 2.sex#2.agegrp = 2.sex#3.agegrp

/* Cox regression, "best model" */
stcox sex year8594 i.agegrp i.subsite i.stage
estat phtest, detail

stcox sex year8594 i.agegrp i.subsite, strata(stage)
est store A

stcox sex year8594 i.agegrp, strata(stage)
lrtest A

stcox i.sex#i.agegrp year8594 i.agegrp i.subsite, strata(stage)
test 2.sex#0.agegrp = 2.sex#1.agegrp = 2.sex#2.agegrp = 2.sex#3.agegrp
