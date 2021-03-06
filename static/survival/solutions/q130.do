
//==================//
// EXERCISE 130
// REVISED MAY 2015
//==================//

clear
use melanoma 
gen female = sex == 2
stset surv_mm, failure(status=1,2) scale(12) exit(time 120) id(id)
***********************************************************************
* (a) Split the data with narrow (1 month) time intervals *
***********************************************************************
//
stsplit fu, every(`=1/12')
gen risktime = _t - _t0
collapse (sum) d = _d risktime (min) start=_t0 (max) end=_t, ///
 by(fu female year8594 agegrp)

// Fit a model with a parameter for each interval
egen interval = group(start)
gen midtime = (start + end)/2
glm d ibn.interval, family(poisson) link(log) lnoffset(risktime) nocons

// predict the baseline (one parameter for each interval)
predict haz_grp, nooffset
replace haz_grp = haz_grp*1000
twoway	(scatter haz_grp midtime)  ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		name(piecewise, replace)

di "Total number of parameters is `e(k)'"		
		
// (b) linear splines (1 knot at knots at 1.5 years)
gen lin_s1 = midtime
gen lin_int2 = (midtime>1.5)
gen lin_s2 = (midtime - 1.5)*(midtime>1.5)

// Fit two separate linear regression lines (4 parameters)
glm d lin_s1 lin_int2 lin_s2 , family(poisson) link(log) lnoffset(risktime) 

predict haz_lin1, nooffset
replace haz_lin1 = haz_lin1*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_lin1 midtime if midtime<=1.5, lcolor(red)) ///
		(line haz_lin1 midtime if midtime>1.5, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline(1.5, lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(linear1, replace)

di "the gradient up to 1.5 years is: " _b[lin_s1]
di "the gradient after 1.5 years is: " _b[lin_s1] + _b[lin_s2]
		
	
// (c) Force the functions to join at the knot (3 parameters)		
glm d lin_s1 lin_s2 , family(poisson) link(log) lnoffset(risktime) 

predict haz_lin2, nooffset
replace haz_lin2 = haz_lin2*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_lin2 midtime, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline(1.5, lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(linear2, replace)

di "the gradient up to 1.5 years is: " _b[lin_s1]
di "the gradient after to 1.5 years is: " _b[lin_s1] + _b[lin_s2]		
		
// (d) Now use cubic polynomials with 1 knot at 2 years
gen cubic_s1 = midtime	
gen cubic_s2 = midtime^2	
gen cubic_s3 = midtime^3
gen cubic_int = midtime>2
gen cubic_lin = (midtime - 2)*(midtime>2)
gen cubic_quad = ((midtime - 2)^2)*(midtime>2)
gen cubic_s4 = ((midtime - 2)^3)*(midtime>2)

glm d cubic* , family(poisson) link(log) lnoffset(risktime) 
predict haz_cubic1, nooffset
replace haz_cubic1 = haz_cubic1*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_cubic1 midtime if midtime<=2, lcolor(red)) ///
		(line haz_cubic1 midtime if midtime>2, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline(2, lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(cubic1, replace)

// (e) constrain to join at knots (drop separate intercept)	
glm d cubic_s* cubic_lin cubic_quad, family(poisson) link(log) lnoffset(risktime) 
predict haz_cubic2, nooffset
replace haz_cubic2 = haz_cubic2*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_cubic2 midtime, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline(2, lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(cubic2, replace)

// (f) continuous 1st derivative (drop second linear term)
glm d cubic_s* cubic_quad, family(poisson) link(log) lnoffset(risktime) 
predict haz_cubic3, nooffset
replace haz_cubic3 = haz_cubic3*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_cubic3 midtime, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline(2, lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(cubic3, replace)

// (g) continuous 2nd derivative (drop second quadratic term)
glm d cubic_s*, family(poisson) link(log) lnoffset(risktime) 
predict haz_cubic4, nooffset
replace haz_cubic4 = haz_cubic4*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_cubic4 midtime, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline(2, lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(cubic4, replace)
		
// restricted cubic splines
// (h) generate splines with 5 knots (4 df)
rcsgen midtime, gen(rcs) df(4) fw(d)
global knots `r(knots)'

// (i) first just add the linear term (rcs1)
glm d rcs1, family(poisson) link(log) lnoffset(risktime)
estimates store rcs1 
predict haz_rcs1, nooffset
replace haz_rcs1 = haz_rcs1*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_rcs1 midtime, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(rcs1, replace)

// (j) now add remaining spline terms
glm d rcs*, family(poisson) link(log) lnoffset(risktime) 
estimates store rcs2 
lrtest rcs1 rcs2
predict haz_rcs2, nooffset
replace haz_rcs2 = haz_rcs2*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_rcs2 midtime, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline($knots , lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(rcs2, replace)

// (k) look at impact of moving boundary knots within data
drop rcs*
rcsgen midtime, gen(rcs) knots(1 2 3) fw(d)
global knots `r(knots)'
glm d rcs*, family(poisson) link(log) lnoffset(risktime) 
predict haz_rcs3, nooffset
replace haz_rcs3 = haz_rcs3*1000 
twoway	(scatter haz_grp midtime)  ///
		(line haz_rcs3 midtime, lcolor(red)) ///
		, xtitle("Years from diagnosis") ///
		ytitle("Baseline hazard (1000 pys)") ///
		xline($knots , lcolor(black) lpattern(dash)) ///
		ylabel(5 10 20 50 100 150, angle(h)) ///
		legend(off) ///
		name(rcs3, replace)

		
