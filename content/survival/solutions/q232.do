
//==================//
// EXERCISE 232
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

/* (b) Fit flexible parametric model using splines for age */
rcsgen age, gen(rcsage) df(4) orthog
matrix Rage = r(R)
global knotsage `r(knots)'
stpm2 rcsage1-rcsage4, scale(hazard) df(5) bhazard(rate)
estimates store peh

/* (c) Time-dependent effect of age 3df */
stpm2 rcsage1-rcsage4, scale(hazard) df(5) bhazard(rate) ///
	tvc(rcsage1-rcsage4) dftvc(2)
estimates store timedep
lrtest peh timedep

/* (d) Predicing hazard and survival functions */
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

/* (e) One year relative survival as a function of age */
gen t1 = 1
predict s1, survival timevar(t1) ci
twoway 	(rarea s1_lci s1_uci age, sort) ///
		(line s1 age, sort lpattern(solid)) ///
		, legend(off) ytitle("1 year relative survival") scheme(sj) ///
		ylabel(0(0.2)1,angle(h) format(%3.1f)) name(s1,replace)

/* (f) Five year relative survival as a function of age */
gen t5 = 5
predict s5, survival timevar(t5) ci
twoway 	(rarea s5_lci s5_uci age, sort) ///
		(line s5 age, sort lpattern(solid)) ///
		, legend(off) ytitle("5 year relative survival") scheme(sj) ///
		ylabel(0(0.2)1,angle(h) format(%3.1f)) name(s5,replace)

/* (g) Conditional relative survival */		
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
		
/* (h) Obtain the hazard ratio as a funtion of age with age 50 as the reference */		
rcsgen , scalar(50) rmatrix(Rage) gen(ref) knots($knotsage)
foreach age in 40 60 70 80 {
	rcsgen , scalar(`age') rmatrix(Rage) gen(c`age'_) knots($knotsage)
	predict hr`age', ///
		hrnum(rcsage1 `=c`age'_1' rcsage2 `=c`age'_2' rcsage3 `=c`age'_3' rcsage4 `=c`age'_4') ///
		hrdenom(rcsage1 `=ref1' rcsage2 `=ref2' rcsage3 `=ref3' rcsage4 `=ref4') ///
		timevar(temptime) ci
}

foreach age in 40 60 70 80 {
	twoway 	(rarea hr`age'_lci hr`age'_uci temptime, sort) ///
		(line hr`age' temptime, sort lpattern(solid)) ///
		, legend(off) ytitle("EMRR") scheme(sj) ///
		xtitle("Years from Diagnosis") ///
		ylabel(0.5 1 2 4 8,angle(h) format(%3.1f)) ///
		yscale(log range(0.5 8)) yline(1, lpatter(dash)) ///
		name(hr`age',replace)
}
graph combine hr40 hr60 hr70 hr80, nocopies name(hr_all,replace)

/* (i) survival differences and hazard differences */
foreach age in 40 60 70 80 {
	rcsgen , scalar(`age') rmatrix(Rage) gen(c`age'_) knots($knotsage)
	predict hdiff`age', ///
		hdiff1(rcsage1 `=c`age'_1' rcsage2 `=c`age'_2' rcsage3 `=c`age'_3' rcsage4 `=c`age'_4') ///
		hdiff2(rcsage1 `=ref1' rcsage2 `=ref2' rcsage3 `=ref3' rcsage4 `=ref4') ///
		timevar(temptime) ci per(1000)
	predict sdiff`age', ///
		sdiff1(rcsage1 `=c`age'_1' rcsage2 `=c`age'_2' rcsage3 `=c`age'_3' rcsage4 `=c`age'_4') ///
		sdiff2(rcsage1 `=ref1' rcsage2 `=ref2' rcsage3 `=ref3' rcsage4 `=ref4') ///
		timevar(temptime) ci
}


foreach age in 40 60 70 80 {
	twoway 	(rarea hdiff`age'_lci hdiff`age'_uci temptime, sort) ///
		(line hdiff`age' temptime, sort lpattern(solid)) ///
		, legend(off) ytitle("") scheme(sj) ///
		xtitle("Years from Diagnosis") ///
		ylabel(-100 0  100 200 400 600 800,angle(h) format(%3.0f)) ///
		yscale(range(-50 900)) yline(0, lpattern(dash)) ///
		name(hdiff`age',replace)
}
graph combine hdiff40 hdiff60 hdiff70 hdiff80, nocopies ///
	l1title("Difference in excess mortality rate (1000 py's)") name(hdiff,replace)


foreach age in 40 60 70 80 {
	twoway 	(rarea sdiff`age'_lci sdiff`age'_uci temptime, sort) ///
		(line sdiff`age' temptime, sort lpattern(solid)) ///
		, legend(off) ytitle("") scheme(sj) ///
		xtitle("Years from Diagnosis") ///
		ylabel(-0.2 -0.15 -0.1 -0.05 0,angle(h) format(%3.2f)) ///
		yscale(range(-0.2 0.05)) yline(0, lpattern(dash)) ///
		name(sdiff`age',replace)
}
graph combine sdiff40 sdiff60 sdiff70 sdiff80, nocopies ///
	l1title("Difference in Relative Survival") name(sdiff,replace)

/* (j) Sensitivity to the number of knots for time-dep effects */
forvalues i = 1/3 {
	stpm2 rcsage*, scale(hazard) df(5) bhazard(rate) tvc(rcsage*) dftvc(`i')
	estimates store m`i'
	predict hr_age_tvc_df`i', ///
		hrnum(rcsage1 `=c70_1' rcsage2 `=c70_2' rcsage3 `=c70_3' rcsage4 `=c70_4') ///
		hrdenom(rcsage1 `=ref1' rcsage2 `=ref2' rcsage3 `=ref3' rcsage4 `=ref4') ///
		timevar(temptime) ci
}

twoway	(line hr_age_tvc_df1* temptime, sort lwidth(medthick thin thin) lcolor(red..) lpattern(solid dash..)) ///
		(line hr_age_tvc_df2* temptime, sort lwidth(medthick thin thin) lcolor(blue..)  lpattern(solid dash..)) ///
		(line hr_age_tvc_df3* temptime, sort lwidth(medthick thin thin) lcolor(midgreen..)  lpattern(solid dash..)) ///
		, legend(order(1 "df 1" 4 "df 2" 7 "df 3") ring(0) pos(11) cols(1)) ///
		 yscale(range(0.5 8) log) yline(1) ylabel(0.5 1 2 4 8) ///
		name(df_tvc_compare,replace)

count if _d==1
estimates stats m1 m2 m3, n(`r(N)')		

