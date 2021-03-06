//==================//
// EXERCISE 131
// REVISED APRIL 2016
//==================//

// Load the Melanoma data, keep those with localized stage
use melanoma, clear
keep if stage == 1
gen female = sex == 2
stset surv_mm, failure(status==1) exit(time 120.5) scale(12)

// (a) Kaplan-Meier curve
sts graph

// (b) Weibull model (using stpm2)
stpm2, scale(hazard) df(1)
predict s1, surv
predict h1, hazard

sts graph, addplot(line s1 _t, sort) name(km1, replace) ylabel(0.6(0.1)1)

// (c) Plot hazard function
sts graph, hazard kernel(epan2) addplot(line h1 _t, sort) name(hazard1, replace)

// (d) try stpm2 with 4 df
stpm2, scale(hazard) df(4)
predict s4, surv
predict h4, hazard
sts graph, addplot(line s4 _t, sort) name(km4, replace)
sts graph, hazard kernel(epan2) addplot(line h4 _t, sort) name(hazard4, replace) 

// (e) Fit a Cox Model
stcox year8594,  

/* (f) Flexible parametric model */
stpm2 year8594, scale(hazard) df(4) eform

/* (g) predicted values */
predict s1ph, survival
predict h1ph, hazard per(1000)

twoway	(line s1ph _t if year8594 == 0, sort) ///
		(line s1ph _t if year8594 == 1, sort) ///
		, legend(order(1 "1975-1984" 2 "1985-1994") ring(0) pos(1) col(1)) ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Survival")
		
twoway	(line h1ph _t if year8594 == 0, sort) ///
		(line h1ph _t if year8594 == 1, sort) ///
		, legend(order(1 "1975-1984" 2 "1985-1994") ring(0) pos(1) col(1)) ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Cause specific mortality rate (per 1000 py's)")

/* (h) hazard on log scale */
twoway	(line h1ph _t if year8594 == 0, sort) ///
		(line h1ph _t if year8594 == 1, sort) ///
		, legend(order(1 "1975-1984" 2 "1985-1994") ring(0) pos(1) col(1)) ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Cause specific mortality rate (per 1000 py's)") ///
		yscale(log)
		
/* (i) sensitivity to knots */
forvalues i = 1/6 {
	stpm2 year8594, scale(hazard) df(`i') eform
	estimates store df`i'
	predict h_df`i', hazard per(1000)
	predict s_df`i', survival
}	
estimates table df*, eq(1) keep(year8594) se stats(AIC BIC)

/* (j) compare hazard and survival */
line s_df* _t if year8594 == 0, sort  ///
	legend(ring(0) cols(1) pos(1)) ///
	xtitle("Time since diagnosis (years)") ///
	ytitle("Survival")

line h_df* _t if year8594 == 0, sort ///
	legend(ring(0) cols(1) pos(1)) ///
	xtitle("Time since diagnosis (years)") ///
	ytitle("Cause specific mortality rate (per 1000 py's)")
	
	
/* (k) knot locations */
// run the following code to fit 10 models with 5df (6 knots) where
// the 4 internal knots are selected at random centiles of the 
// distribution of event times.
//
// As there are many ties in this data we add a small random number to the survival times
// (otherwise we risk having knots in the same location)
replace _t = _t + runiform()*0.001
set seed 12345
global legorder
forvalues i = 1/10 {
	local plist
	forvalues j = 1/4 {
		local z`j': display %3.1f runiform()*100
		local plist  `plist' `z`j''
	}
	numlist "`plist'", sort
	local plist `r(numlist)'
	stpm2 year8594, scale(hazard) knots(`plist') knscale(centile) failconvlininit 
	predict sp`i', surv zeros
	predict hp`i', hazard per(1000) zeros
	estimates store mp`i'
	global legorder ${legorder} `i' `""`plist'""'
}

// compare log hazard ratios and standard errors
estimates table mp*, keep(year8594) se(%5.4f) b(%5.4f)

// compare baseline hazard curves
twoway (line hp* _t, sort), legend(order(${legorder}) ring(0) pos(1) cols(1)) name(hp,replace)	

// compare baseline survival curves
twoway (line sp* _t, sort), legend(order(${legorder}) ring(0) pos(1) cols(1)) name(sp,replace)	

	

/* (l) Include effect of age group and sex */
stcox female year8594 i.agegrp
estimate store cox
stpm2 female year8594 i.agegrp, df(4) scale(hazard) eform
estimates store stpm2_ph

// compare to Cox model

estimates table cox stpm2_ph,  equation(1) keep(#1:)  se

/* (n) obtaining predictions */
/* predict using at option*/
estimates restore stpm2_ph
range temptime 0 10 200
predict S0, survival zeros timevar(temptime)
line S0 temptime, sort

predict S_F_8594_age75, survival ///
  at(female 1 year8594 1 agegrp 3) timevar(temptime) ci

twoway	(rarea S_F_8594_age75_lci S_F_8594_age75_uci temptime, pstyle(ci)) ///
		(line S_F_8594_age75 temptime) ///
		, legend(off) ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("S(t)") ///
		title("Female age 75+ diagnosed 1985-1994")
