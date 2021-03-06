
//==================//
// EXERCISE 112
// REVISED MAY 2015
//==================//

/* Data set used */
use diet, clear

/* Stset. Timescale: Attained age */
stset dox, id(id) fail(chd) origin(dob) enter(doe) scale(365.24)

/* Hazard function (overall and by hieng) */
sts graph, hazard					
sts graph, by(hieng) hazard	

/* Stset. Timescale: Time-in-study */
stset dox, id(id) fail(chd) origin(doe) enter(doe) scale(365.24)

/* Hazard function (overall and by hieng) */
sts graph, hazard
sts graph, by(hieng) hazard	

/* Modelling the rate, no adjustment for timescale */
poisson chd hieng, e(y) irr

/* Adjustment for confounders job and bmi */
gen bmi=weight/(height/100*height/100)

/* Poisson regression */
poisson chd hieng job bmi, e(y) irr


**************************************************
* Modelling the rate, adjusting for timescale age
**************************************************

/* Stset */
stset dox, id(id) fail(chd) origin(dob) enter(doe) scale(365.24)

/* Split ageband */
stsplit ageband, at(30,50,60,72) trim
list id _t0 _t ageband y in 1/10

/* Generate a risk time variable */
gen risktime=_t-_t0
list id _t0 _t ageband y risktime in 1/10

tab ageband chd, missing
tab ageband _d, missing

/* Poisson regression adjusted for ageband */
poisson _d hieng i.ageband, e(risktime) irr

* Adjustment for confounders job, bmi
poisson _d hieng i.job bmi i.ageband, e(risktime) irr


**************************************************
* Modelling the rate, adjusting for timescale time-in-study
**************************************************

/* Data set used */
use diet, clear

/* Create variable for BMI */
gen bmi=weight/(height/100*height/100)

/* New stset with time-of-follow-up */
stset dox, id(id) fail(chd) origin(doe) enter(doe) scale(365.24)

/* Split follow up time */
stsplit fuband, at(0,5,10,15,22) trim
list id _t0 _t fuband y in 1/10

gen risktime=_t-_t0
list id _t0 _t fuband y risktime in 1/10

tab fuband chd, missing
tab fuband _d, missing

/* Poisson regression */
poisson _d hieng i.fuband, e(risktime) irr

/* Adjustment for confounders job and bmi */
poisson _d hieng i.job bmi i.fuband, e(risktime) irr
