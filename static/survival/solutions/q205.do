
//==========================================================================//
// Q205
// Created March 2018
// Estimating conditional survival
// Estimate probabilitity of surviving 5+ years following diagnosis
//          conditional on surviving 1 year
// (a) using life table 
//     (i) by S(5)/S(1)
//     (ii) by seeting time of entry to 1 year
// (b) using a flexible parametric model and predicting S(t)/S(1)
//==========================================================================//

use colon, clear

stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)

// Estimate conditional survival as S(5)/S(1) from a cohort life table
// Use hazard-transform (ht) option for comparability with next part (which uses late entry)
strs using popmort, br(0(1)10) mergeby(_year sex _age) ht save(replace)

// . di 0.4631/0.6684
// .69284859

// Now stset with entry at 12 months
// We are restricting the cohort to individuals who survived at least 1 year
stset exit, origin(dx) enter(time dx+365.24) fail(status==1 2) id(id) scale(365.24)

// We get the same conditional estimate, but now we get standard errors and confidence interval
strs using popmort, br(0(1)10) mergeby(_year sex _age) list(n d r cr_e2 lo_cr_e2 hi_cr_e2) save(replace)

// Now use a model
// Return to orginal stset (everyone at risk from diagnosis) and merge in expected rates
stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + _t)
sort _year sex _age
merge m:1 _year sex _age using popmort, keep(match master)

// Fit the model without covariates
stpm2, scale(hazard) df(5) bhazard(rate)
predict s, surv ci

// Create a temporary time variable to use for predictions
range timevar 1 5 100
gen t1 = 1 in 1/100

// Predict S(t) / S(1)
predictnl condsurv = predict(survival timevar(timevar)) / predict(survival timevar(t1)) 

// Should predict on the log scale to get the CIs correct					 
predictnl condsurv1 = ln(predict(survival timevar(timevar)) / ///
                     predict(survival timevar(t1))) , ///
					 ci(condsurv1_lci condsurv1_uci)  
replace condsurv1=exp(condsurv1)
replace condsurv1_lci=exp(condsurv1_lci)
replace condsurv1_uci=exp(condsurv1_uci)

// List S(5)/S(1)		 					 
list condsurv1 condsurv1_lci condsurv1_uci if timevar==5	


// RESULTS
//+--------------------------------+
//| condsurv   cond~lci   cond~uci |
//|--------------------------------|
//| .6903092   .6792465   .7015522 | model
//| .6928      .6801      .7053    | life table
//+--------------------------------+
	
// Plot comnditional survival (with CIs) for each value of t	
twoway  (rarea condsurv1_lci condsurv1_uci timevar, sort) ///
        (line condsurv1 timevar, sort lpattern(solid)) ///
        , legend(off) ytitle("Relative survival conditional on surviving 1 year") scheme(sj) ///
        ylabel(0(0.2)1,angle(h) format(%3.1f)) xlabel(0(1)5) name(condsurv1,replace)

// Now predict survival conditional on surviving 3 years		
gen t3 = 3 in 1/100		

predictnl condsurv3 = ln(predict(survival timevar(timevar)) / ///
                     predict(survival timevar(t3))) , ///
					 ci(condsurv3_lci condsurv3_uci)  
replace condsurv3=exp(condsurv3)
replace condsurv3_lci=exp(condsurv3_lci)
replace condsurv3_uci=exp(condsurv3_uci)

twoway  (rarea s_lci s_uci _t if _t<5, sort) ///
        (line s _t if _t<5, sort lpattern(solid)) ///
		(rarea condsurv1_lci condsurv1_uci timevar, sort) ///
        (line condsurv1 timevar, sort lpattern(solid)) ///
		(rarea condsurv3_lci condsurv3_uci timevar if timevar>=3, sort) ///
        (line condsurv3 timevar if timevar>=3, sort lpattern(solid)) ///
        , legend(off) ytitle("Relative survival") scheme(sj) ///
        ylabel(0(0.2)1,angle(h) format(%3.1f)) xlabel(0(1)5) name(condsurv,replace)

		
/***********
END OF FILE
***********/



