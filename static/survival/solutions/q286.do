clear	

// Code by Paul C Lambert
// Note: Requires stpm2_standsurv version 1.1.1 or higher
// which is not publically available as at 11Nov2017

// This exercise requires the Stata user-written commands -survsim-, -stpm2-, 
// and -moremata-, all of which can be installed using ssc install -packagename-.

set seed 9874326
set obs 100000

// generate survival data without frailty
// true hazard ratio is 1.3
gen trt = runiform()<0.5
survsim t1 d1, dist(weibull) lambda(0.2) gamma(0.8) maxt(5) cov(trt `=log(1.3)')
stset t1, f(d1==1)
sts graph, by(trt) name(km1, replace)

// Cox model gives true hazard ratio
stcox trt

// Now generate frailty variable, z 
// large underlying variation between individuals
// generate survival data again
gen z = rnormal(0,1)
survsim t2 d2, dist(weibull) lambda(0.2) gamma(0.8) maxt(5) cov(trt `=log(1.3)' z 1)

stset t2, f(d2==1) 
// Note KM curves are closer together
sts graph, by(trt) name(km2, replace)

// Even though randomised unadjusted HR is biased
stcox trt

// controlling for Z makes things OK
// but can't do this if Z is unobserved!
// There will always be unobserved hetergeneity
stcox trt z

// Look at hazard functions etc
// look at model with no frailty
stset t1, f(d1==1)
stpm2 trt, scale(h) df(4) tvc(trt) dftvc(3)

range timevar 0 5 50
// survival functions
predict s1, surv at(trt 0) timevar(timevar)
predict s2, surv at(trt 1) timevar(timevar)
twoway (line s1 s2 timevar), name(s1, replace)

// difference in survival functions
predict sdiff1, sdiff1(trt 1) sdiff2(trt 0) timevar(timevar) ci
twoway line sdiff1* timevar, name(sdiff1, replace)

// hazard ratio
// see how close it is to true HR of 1.3
predict hr1, hrnum(trt 1) timevar(timevar) ci
twoway line hr1* timevar,  yline(1.3) name(hr1, replace)
 
// now the data with frailty
// but not modelling it
stset t2, f(d2==1)
stpm2 trt, scale(h) df(4) tvc(trt) dftvc(3)

// survival functions
predict s1b, surv at(trt 0) timevar(timevar)
predict s2b, surv at(trt 1) timevar(timevar)
twoway (line s1b s2b timevar), name(s2, replace)

// difference in survival functions
// note different to sdiff1.
predict sdiff2, sdiff1(trt 1) sdiff2(trt 0) timevar(timevar) ci
twoway line sdiff2* timevar, name(sdiff2, replace)

// hazard ratio
// see how different it is to true HR of 1.3
predict hr2, hrnum(trt 1) timevar(timevar) ci
twoway line hr2* timevar,  yline(1.3) name(hr2, replace) ylab(1(0.05)1.35)
 
// Now assume we actually measure the covariate z and so can model it
// Now each subject will have a different predicted survival function
// so will need to standardize to report 1.

stpm2 trt z, scale(h) df(4) tvc(trt) dftvc(3)

// hazard ratio
// Now we have included Z we are back to the hazard ratio of 1.3
// (remember this a randomsised study!!!)
// so Z is not a counfounder.
predict hr3, hrnum(trt 1) timevar(timevar) ci
twoway line hr3* timevar,  yline(1.3) name(hr3, replace) ylab(1(0.05)1.35)

// to look at survival we need to standardise
stpm2_standsurv, at1(trt 0) at2(trt 1) timevar(timevar) ci contrast(difference) ///
	atvar(s1c s2c) contrastvar(sdiff3)

// plot standadrized survival	
twoway line sdiff3* timevar, name(sdiff3, replace)

// comparison between difference in survival
// Note the point estimatess are the same  for sdiff2 and sdiff3
// but narrower CI as we are modelling some of the variation.
// Important thing is that with unobserved heterogeneity, the survival 
// difference is the same, but the hazard ratio is not.
graph combine sdiff1 sdiff2 sdiff3, cols(3) name(sdiffcomb, replace)

// Can also get the hazard ratio of the standardized survival function
stpm2_standsurv, at1(trt 0) at2(trt 1) timevar(timevar) ci contrast(ratio) ///
	atvar(h1c h2c) contrastvar(hr4) hazard
	
// This is essentially the same as the HR from the model that does not adjust for
// heterogeneity	
// Not sure how useful this is....
//  but it shows how the hazard ratio is non-collapsable
// i.e. there is a difference between the conditional HR (1.3 conditional on Z)
// and the marginal HR
twoway line hr4* timevar,  yline(1.3) name(hr4, replace) ylab(1(0.05)1.35)
	
// Another important point is that in an observational cohort study if we
// sufficiently adjust for counfounding the difference in survival functions
// would be the same as we would see in a randomised study, but the HR may not be.
	
// Could use other meaures based on the survival function
// e.g. restricted mean survival time...

gen t5 = 5 in 1
stpm2_standsurv, at1(trt 0) at2(trt 1) timevar(t5) ci contrast(difference) ///
		atvar(rmst1c rmst2c) contrastvar(rmst_diff) rmst
list rmst1* in 1
list rmst2* in 1
list rmst_diff* in 1

// or centiles of the standardized survival function

stpm2_standsurv, at1(trt 0) at2(trt 1) centile(10(10)50) ci contrast(difference) ///
		atvar(cen1 cen2) contrastvar(cent_diff)
list _centvals cen1* in 1/5
list _centvals cen2* in 1/5
list _centvals cent_diff* in 1/5
