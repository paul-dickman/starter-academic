
//======================================================//
// EXERCISE 180
// Outcome-selective sampling designs
// REVISED MAY 2016
// Written by Anna Johansson (anna.johansson@ki.se)
//======================================================//

use melanoma, clear

*************************************
* Full cohort analysis
*************************************

* stset the data
stset exit, fail(status==1) enter(dx) origin(dx) scale(365.24) id(id)

* Kaplan-Meier curves
sts graph
sts graph, by(sex)

* Cox regression
stcox i.sex
estimates store crude

stcox i.sex i.agegrp i.year8594 i.stage
estimates store cox

stcox i.sex i.agegrp i.year8594 i.stage i.subsite
estimates store adj2

estimates table crude cox adj2, eform b(%9.6f)


* Flexible parametric model
stpm2 i.sex i.agegrp i.year8594 i.stage, df(5) scale(hazard) eform
estimates store fpm

* Poisson regression
stsplit fuband, at(0(5)20)
tab fuband

streg i.sex i.agegrp i.year8594 i.stage i.fuband, dist(exp) 
estimates store pois

estimates table cox fpm pois, eform b(%7.3f) se(%7.3f) eq(1)


*************************************
* Nested Case-Control
*************************************

use melanoma, clear

* Stset the data
stset exit, fail(status==1) enter(dx) origin(dx) scale(365.24) id(id)

* Sample 1 control per case (death)
set seed 339487731  // makes sampling reproducible
sttocc, match(agegrp) n(1)
*sttocc, n(1)

* Check the data
list id _case _set _time  in 1/10

tab _case
tab agegrp _case, missing col

* Logistic regression
clogit _case i.sex i.year8594 i.stage, group(_set) or


*************************************
* Case-Cohort
*************************************

use melanoma, clear

* Stset the data
stset exit, fail(status==1) enter(dx) origin(dx) scale(365.24) id(id)

gen case=_d

* sample subcohort
set seed 339487731  // makes sampling reproducible 
gen u = runiform()   // assign random number to all obs
gen subcoh = 1 if (u <= 0.25) // generate dummy subcohort
replace subcoh = 0 if (u>0.25)

tab case subcoh

* Generate Borgan II weights
gen wt = 1 if case==1
replace wt = 1 / (1470/5862) if case==0 & subcoh==1

tab wt

* STSET using pweights option
stset exit [pw=wt], fail(status==1) enter(dx) origin(dx) scale(365.24) id(id)
						  
* Cox model for case-cohort - Borgan II
stcox i.sex i.agegrp i.year8594 i.stage, vce(robust)
estimates store cox_cc

* FPM model for case-cohort - Borgan II 
stpm2 i.sex i.agegrp i.year8594 i.stage, scale(h) df(5) eform vce(robust) nolog
estimates store fpm_cc

* Poisson regression - Borgan II
stsplit fuband, at(0(5)20)

streg i.sex i.agegrp i.year8594 i.stage i.fuband, dist(exp) vce(robust)
estimates store pois_cc

estimates table cox cox_cc fpm_cc pois_cc, eform b(%7.3f) se(%7.3f) eq(1)

* end of file *
