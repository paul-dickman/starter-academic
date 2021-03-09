
//==================//
// EXERCISE 111
// REVISED MAY 2015
//==================//

/* Data used */
use melanoma, clear
keep if stage == 1

/* Stset */
stset surv_mm, failure(status==1) scale(12) id(id)

/* Survivor function */
sts graph, by(year8594) name(kaplanmeier, replace)

/* Hazard function */
sts graph, by(year8594) hazard name(hazard, replace)

/* Hazard rate and Poisson regression */
strate year8594, per(1000)
streg year8594, dist(exp)

/* Re-load data */
use melanoma if stage==1, clear

/* Stset data and restrict follow-up to 10 years */
stset surv_mm, failure(status==1) scale(12) id(id) exit(time 120)

/* Hazard rate and Poisson regression */
strate year8594, per(1000)
streg year8594, dist(exp)

/* Poisson modelling using other syntax */
gen risktime=_t-_t0
poisson _d year8594 if _st==1, exp(risktime) irr
glm _d year8594 if _st==1, family(poisson) eform lnoffset(risktime)

/* Split follow-up into 1-year intervals */
stsplit fu, at(0(1)10) trim

/* Tabulate (and produce a graph of) the rates by follow-up time */
strate fu, per(1000) graph

/* Compare the plot of the estimated rates to a plot of the hazard rate */
sts graph, hazard

/* Estimate incidence rate ratios as a function of follow-up */
streg i.fu, dist(exp)

/* Poisson regression adjusting for time since diagnosis */
streg i.fu year8594, dist(exp)

/* Poisson regression adjusting for age, calendar period and sex */
streg i.fu i.agegrp year8594 sex, dist(exp)

/* Wald test */
test 1.agegrp 2.agegrp 3.agegrp

/* Poisson regression */
streg i.fu i.agegrp i.year8594##sex, dist(exp)

/* Calculate effect of sex for year8594==2 */
di 0.6031338*0.9437245

/* Effect of sex for year8594==2 */
lincom 2.sex + 1.year8594#2.sex, eform

/* Creating dummies and using Stata 10 syntax */
gen sex_early=(sex==2)*(year8594==0)
gen sex_latter=(sex==2)*(year8594==1)
streg i.fu i.agegrp year8594 sex_early sex_latter, dist(exp)

/* Poisson regression giving us the effect of sex for year8594==2 */
streg i.fu i.agegrp i.year8594 year8594#sex, dist(exp)

/* Poisson regression stratified on calendar period */
streg i.fu i.agegrp sex if year8594==0, dist(exp)
streg i.fu i.agegrp sex if year8594==1, dist(exp)

/* Poisson regression with only interactions */
streg i.fu##year8594 i.agegrp##year8594 year8594##sex, dist(exp)



