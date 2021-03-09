***********************************************************
* Stata code accompanying the video lecture:
*
* Understanding the proportional hazards assumption in the Cox model
*
* http://pauldickman.com/video/proportional-hazards/
*
* Paul Dickman, Enoch Chen
* August 2020
***********************************************************
//Start of Stata code //
use "https://pauldickman.com/data/colon.dta" if stage==1, clear

// status==1 is dead due to cancer
stset surv_mm, failure(status == 1) id(id)

// Split follow-up time at 24 months 
stsplit timeband, at(0 24 1000) trim

// Have a look at the split data for the firs 10 observations
// Note that timeband is coded as 0 and 24 (need to use i.timeband)
list id surv_mm _t0 _t timeband in 1/10

// Cox model with an interaction between calendar period and timeband
stcox i.agegrp i.sex i.year8594##i.timeband, efron

// Alternative parameterisation to get the estimated HRs for
// period for each timeband
stcox i.agegrp i.sex i.timeband i.year8594#i.timeband, efron

// Test the interaction (Wald test)
stcox i.agegrp i.sex i.year8594##i.timeband, efron
test 1.year8594#24.timeband

// Test the interaction (Likelihood ratio test)
estimates store interaction
stcox i.agegrp i.sex i.year8594, efron
lrtest interaction

// Now fit the interaction model using the tvc() option (analogous to tt() in R)
// This is the same model we fitted previously, just with a different syntax
// We will return to the original (non-split) data to save time
use "https://pauldickman.com/data/colon.dta" if stage==1, clear
stset surv_mm, failure(status == 1) id(id)
stcox i.agegrp i.sex i.year8594, efron tvc(i.year8594) texp(_t >= 24)

// Test PH assumption
stcox i.agegrp i.sex i.year8594, efron
estat phtest, km detail

// Plot of scaled Schoenfeld residuals for period
estat phtest, plot(1.year8594) 

// Plot of scaled Schoenfeld residuals for sex
estat phtest, plot(2.sex) 

// Include stage as well
// Drop unknown stage
use "https://pauldickman.com/data/colon.dta", clear
replace stage = . if stage == 0 // Drop unlnown stage

stset surv_mm, failure(status == 1) id(id)
stcox i.agegrp i.sex i.year8594 i.stage, efron
estat phtest, km detail

// Estimates the hazard function using kernel-based methods
stset surv_mm, failure(status == 1) id(id)
sts graph, haz by(stage) kernel(epan2) /// default is epanechnikov, same as muhaz2() in R
xscale(range(0 250)) ///
yscale(range(0 0.04))

// Cox PH using stage as covariate
stcox i.stage, efron

// Hazard estimates for coxph
sts graph, haz by(stage) kernel(epanechnikov) /// default is epanechnikov, same as muhaz2() in R
xscale(range(0 250)) ///
yscale(range(0 0.04))

// Log scale of the hazard estimates above
sts graph, haz by(stage) kernel(epanechnikov) /// default is epanechnikov, same as muhaz2() in R
xscale(range(0 250)) ///
yscale(log) ylabel(0 0.0001 0.01)

// Test PH assumption 
stcox i.stage, efron
estat phtest, plot(3.stage) ///
xlabel(0 5 10 20 50 100 200)

// Statified by agegrp
keep if stage == 1 // Only localised stage
stcox i.sex i.year8594, strata(agegrp) efron

//End of Stata code //
