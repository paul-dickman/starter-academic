
//==================//
// EXERCISE 231
// REVISED MAY 2015
//==================//

/* (a) Load Data and merge in expected mortality */
use colon, clear

stset surv_mm, failure(status=1,2) scale(12) id(id) exit(time 60.5)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + _t)

sort _year sex _age
merge m:1 _year sex _age using popmort,  keep(match master)
keep if age<=90

/* (b) Fit flexible parametric model with no covariates*/
stpm2 , scale(hazard) df(5) bhazard(rate) eform

predict mg1, martingale
lowess mg1 age, name(mg1, replace)

/* (c) Add linear effect of age to model */
stpm2 age, scale(hazard) df(5) bhazard(rate) eform

/* (d) Excess mortality rate as a function of age */
partpred hr_age_lin, for(age) ref(age 50) ci(hr_age_lin_lci hr_age_lin_uci) eform
twoway 	(rarea hr_age_lin_lci hr_age_lin_uci age, sort) ///
		(line hr_age_lin age, sort lpattern(solid)) ///
		, legend(off) ytitle("Hazard Ratio") scheme(sj) ///
		ylabel(0.5 1 2 4 8,angle(h) format(%3.1f)) name(hr_age_lin,replace) ///
		yscale(log) yline(1)

/* (e) Calculate martingale residuals */		
predict mg2, martingale
lowess mg2 age, name(mg2, replace)
		
/* (f) Generate splines for age and fit model */		
rcsgen age, gen(rcsage) df(4) orthog
matrix Rage = r(R)
global knotsage `r(knots)'
stpm2 rcsage1-rcsage4, scale(hazard) df(5) bhazard(rate)

predict mg3, martingale
lowess mg3 age, name(mg3, replace) 


/* (g) Predicing hazard and survival functions */
range temptime 0 5 200
foreach age in 40 60 80 {
	rcsgen , scalar(`age') rmatrix(Rage) gen(c) knots($knotsage)
	predict h`age', hazard at(rcsage1 `=c1' rcsage2 `=c2' rcsage3 `=c3' rcsage4 `=c4') ///
		timevar(temptime) per(1000) 
	predict s`age', survival at(rcsage1 `=c1' rcsage2 `=c2' rcsage3 `=c3' rcsage4 `=c4') ///
		timevar(temptime) 
}

twoway (line h40 h60 h80 temptime), ///
		yscale(log) ytitle("Excess Mortality Rate (1000 py's)") ///
		xtitle("Years from Diagnosis") ///
		legend(order(1 "40 yrs" 2 "60 yrs" 3 "80 yrs") cols(1) ring(0) pos(1)) ///
		ylabel(50 100 200 400 600 800 1000,angle(h)) ///
		name(hazard, replace) scheme(sj)
twoway (line s40 s60 s80 temptime), ///
		ytitle("Relative Survival") ///
		xtitle("Years from Diagnosis") ///
		legend(order(1 "40 yrs" 2 "60 yrs" 3 "80 yrs") cols(1) ring(0) pos(1)) ///
		ylabel(0(0.2)1,angle(h) format(%3.1f)) ///
		name(survival, replace) scheme(sj)

/* (h) One year relative survival as a function of age */
		
gen t1 = 1
predict s1, survival timevar(t1) ci
twoway 	(rarea s1_lci s1_uci age, sort) ///
		(line s1 age, sort lpattern(solid)) ///
		, legend(off) ytitle("1 year relative survival") scheme(sj) ///
		ylabel(0(0.2)1,angle(h) format(%3.1f)) name(s1,replace)

/* (i) Five year relative survival as a function of age */
gen t5 = 5
predict s5, survival timevar(t5) ci
twoway 	(rarea s5_lci s5_uci age, sort) ///
		(line s5 age, sort lpattern(solid)) ///
		, legend(off) ytitle("5 year relative survival") scheme(sj) ///
		ylabel(0(0.2)1,angle(h) format(%3.1f)) name(s5,replace)

/* (j) Conditional relative survival */		
gen condsurv = s5/s1		
twoway 	(line condsurv age, sort lpattern(solid)) ///
		, legend(off) ytitle("5 year conditional relative survival") scheme(sj) ///
		ylabel(0(0.2)1,angle(h) format(%3.1f))  name(condsurv,replace)

predictnl condsurv2 = predict(survival timevar(t5))/predict(survival timevar(t1)) ///
		,ci(condsurv2_lci condsurv2_uci)		
twoway 	(rarea condsurv2_lci condsurv2_uci age, sort) ///
		(line condsurv2 age, sort lpattern(solid)) ///
		, legend(off) ytitle("5 year conditional relative survival") scheme(sj) ///
		ylabel(0(0.2)1,angle(h) format(%3.1f))  name(condsurv2,replace)
		
/* (k) Obtain the hazard ratio as a funtion of age with age 50 as the reference */		
rcsgen , scalar(50) rmatrix(Rage) gen(c) knots($knotsage)
partpred hr_age_rcs, for(rcsage1-rcsage4) ///
					 ref(rcsage1 `=c1' rcsage2 `=c2' rcsage3 `=c3' rcsage4 `=c4') ///
					 eform ci(hr_age_rcs_lci hr_age_rcs_uci)
twoway 	(rarea hr_age_rcs_lci hr_age_rcs_uci age, sort) ///
		(line hr_age_rcs age, sort lpattern(solid)) ///
		, legend(off) ytitle("Hazard Ratio") scheme(sj) ///
		ylabel(0.5 1 2 4 8,angle(h) format(%3.1f)) name(hr_age,replace) ///
		yscale(range(0.5 1) log) yline(1)
				 
/* (l) Sensitivity to the number of knots */
forvalues i = 3/5 {
	capture drop rcsage*
	rcsgen age, gen(rcsage) df(`i') orthog
	matrix Rage = r(R)
	global knotsage `r(knots)'
	stpm2 rcsage*, scale(hazard) df(5) bhazard(rate) eform
	estimates store m`i'
	rcsgen , scalar(50) rmatrix(Rage) gen(c) knots($knotsage)
	local reflist
	forvalues j = 1/`i' {
		local reflist `reflist' rcsage`j' `=c`j''
	}
	di "`reflist"'
	partpred hr_age_rcs_df`i', for(rcsage*) ref(`reflist') ///
				 eform ci(hr_age_rcs_df`i'_lci hr_age_rcs_df`i'_uci)	
}

twoway	(line hr_age_rcs_df3* age, sort lwidth(medthick thin thin) lcolor(red..) lpattern(solid dash..)) ///
		(line hr_age_rcs_df4* age, sort lwidth(medthick thin thin) lcolor(blue..)  lpattern(solid dash..)) ///
		(line hr_age_rcs_df5* age, sort lwidth(medthick thin thin) lcolor(midgreen..)  lpattern(solid dash..)) ///
		, legend(order(1 "df 3" 4 "df 4" 7 "df 5") ring(0) pos(11) cols(1)) ///
		 yscale(range(0.5 8) log) yline(1) ylabel(0.5 1 2 4 8) ///
		name(df_compare,replace)

count if _d==1
estimates stats m3 m4 m5, n(`r(N)')		

