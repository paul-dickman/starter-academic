/***********************************************************************
This code available at:
http://pauldickman.com/software/strs/life_table_algorithm.do

The tutorial based on this code is available at:
http://pauldickman.com/software/strs/life_table_algorithm/

This code illustrates the algorithm used by strs for estimating 
relative survival using the Ederer II approach.

We estimate observed, expected, and relative survival from first principles.
Estimates are the same as strs. The basic algorith is:

1. Split person-time into life-table intervals
2. Generate attained (updated) age and calendar year
3. Merge with popmort file to get the expected probabilities
4. Collapse to one observation for each life table interval
   (summing deaths and censoring and averaging expected survival)
5. Calculate interval specific survival
6. Multiply interval-specific estimates to get cumulative estimates

Paul Dickman, June 2019
************************************************************************/

use http://pauldickman.com/data/melanoma if stage==1 , clear

stset surv_mm, fail(status==1 2) id(id) scale(12)

// Split into annual intervals
stsplit start, at(0(1)25) 

// Generate attained (updated) age and calendar year
gen _age=floor(age+_t0)
gen _year=floor(yydx+_t0)

// Merge with popmort file to get the expected probabilities of death
merge m:1 sex _age _year using http://pauldickman.com/data/popmort, keep(match master) nogenerate keepusing(prob)
sort id start

// List relevant variables for 2 patients
list id _t0 _t _d age _age yydx _year prob if inlist(id,1,2), sepby(id) noobs

// generate an indicator for censored during the interval
// identify individuals who did not survive the last interval but did not die
bysort id : gen w = (_d[_N]==0 & _n==_N & (_t-_t0)!=1)

// collapse to get one observation for each life table interval
collapse (sum) d=_d w (count) n=_d (mean) p_star=prob, by(start)

// effective number at risk
gen n_prime=n-w/2

// interval-specific observed survival
gen p=1-d/n_prime

// interval-specific relative survival
gen r=p/p_star

// multiply the interval-specific probabilities to get the cumulative probabilities
// we use a*b = exp(ln(a)+ln(b)) since Stata can sum across observation but not multiply
gen cp_e2=exp(sum(ln(p_star)))
gen cp=exp(sum(ln(p)))
gen cr_e2=exp(sum(ln(r)))

format p p_star r cp cp_e2 cr_e2 %9.4f

// List the estimates. This is our life table 
list start n d w p p_star r cp cp_e2 cr_e2

// We get the same results using strs
use http://pauldickman.com/data/melanoma if stage==1 , clear
stset surv_mm, fail(status==1 2) id(id) scale(12)
strs using http://pauldickman.com/data/popmort, br(0(1)25) mergeby(_year sex _age)



