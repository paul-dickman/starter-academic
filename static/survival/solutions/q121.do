
//==================//
// EXERCISE 121
// REVISED MAY 2015
//==================//

/* Data set used */
use melanoma if stage == 1, clear

/* Stset data */
stset surv_mm, id(id) failure(status==1) exit(time 120) scale(12)

/* Hazard function */
sts graph, hazard by(year8594)

/* Hazard function on log scale */
sts graph, hazard by(year8594) yscale(log)

/* Log cumulative hazard function */
stphplot, by(year8594)

/* Cox regression */
stcox year8594

/* Cox regression adjusted for sex, calendar period and age */
stcox sex i.year8594 i.agegrp
estat phtest, plot(1.year8594)

/* Re-do the above for agegrp */

/* Hazard function */
sts graph, hazard by(agegrp)

/* Log cumulative hazard function */
stphplot, by(agegrp)

/* Hazard function on log scale */
sts graph, hazard by(agegrp) yscale(log)

/* Cox regression */
stcox i.agegrp

/* Cox regression adjusted for sex, calendar period and age */
stcox sex i.year8594 i.agegrp
estat phtest, plot(1.agegrp)
estat phtest, plot(2.agegrp)
estat phtest, plot(3.agegrp)

/* Formally test the PH assumption */
stcox sex i.year8594 i.agegrp
estat phtest, detail

/* Alternative 1: Cox regression using tvc option */
tab agegrp, gen(agegrp)
stcox sex year8594 agegrp2 agegrp3 agegrp4, tvc(agegrp2 agegrp3 agegrp4) texp(_t>=2)

/* Alternative2: Split data */
stsplit fuband, at(0,2)
list id _t0 _t fu in 1/10

/* Cox regression with interaction */
stcox sex year8594 i.agegrp##i.fuband

/* Test interaction */
testparm i.agegrp#i.fuband

/* Effect of exposure for each level of the modifier */
stcox sex year8594 i.fuband i.fuband#i.agegrp

/* Fit an analogous Poisson regression model */
use melanoma if stage == 1, clear
stset surv_mm, id(id) failure(status==1) exit(time 120) scale(12)
stsplit fu, at(0(1)10) trim
egen fuband = cut(fu), at(0,2,10)
streg i.fu sex year8594 i.fuband i.fuband#i.agegrp, dist(exp)

