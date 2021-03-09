/************************************************************************
COLON_COMPARE_ALL_PEH_MODELS.DO
Paul Lambert (paul.lambert@le.ac.uk)

Fits various cure models to model the baseline hazard function and compare
graphically.

Also a comparison of excess hazard ratios.

Models are fitted to the first 5 years of follow-up only.
*************************************************************************/
set more off
/* Load Colon Data */
clear 
set memory 200m
use colon, clear
stset surv_mm, failure(status=1,2) scale(12) exit(time 12 * 5) id(id)

tab agegrp, gen(agegrp)
gen female = sex == 2

/* set up data for piecewise models */
strs using popmort, br(0(1)5) mergeby(_year sex _age) by(female year8594 agegrp) notables savgroup(colon_grouped, replace)

/* set up data for fractional polynomial and spline models */
strs using popmort, br(0(0.08333)5) mergeby(_year sex _age) by(female year8594 agegrp) notables savgroup(colon_grouped_fine, replace)

/* merge in expected mortality rates at event times for use with strsrcs and strsnmix */
gen _age = cond((age + _t)>99,99,int(age + _t))
gen _year = int(yydx + mmdx/12 + _t)
sort  _year  sex  _age
merge  _year  sex  _age using popmort, nokeep 	
gen brate = -ln(prob)

/* Proportional Excess Hazards */
/* Splines on Log-Cumulative Hazard Scale */
strsrcs agegrp2 agegrp3 agegrp4 female year8594, df(4) bhazard(brate) scale(hazard)
estimates store strsrcs
predict h_strsrcs, hazard
replace h_strsrcs = h_strsrcs*1000

/* Non-Mixture Cure Models */
/* Only the non-mixture cure model has proportional excess hazards as a special case */
/* This does not apply to the mixture cure model */
strsnmix agegrp2 agegrp3 agegrp4 female year8594, dist(weibull) link(loglog) bhazard(brate)
estimates store strsnmix
predict h_strsnmix, hazard
replace h_strsnmix = h_strsnmix*1000

/* Piecewise Models */
preserve
use colon_grouped, clear
tab end, gen(end)
tab agegrp, gen(agegrp)
glm d end1-end5 agegrp2 agegrp3 agegrp4 female year8594, fam(pois) link(rs d_star) lnoffset(y) nocons
estimates store piecewise
xpredict lnh_pw, with(end1-end5) eq(d)
gen h_pw = exp(lnh_pw)*1000
bysort end: gen unique = _n == 1
rename end end_pw
keep if unique
keep end_pw h_pw
save pw_h, replace
restore

/* Fractional Polynomial Models */
preserve
use colon_grouped_fine, clear
gen midtime = (start + end)/2
tab agegrp, gen(agegrp)
mfp glm d midtime (agegrp2 agegrp3 agegrp4 female year8594), fam(pois) link(rs d_star) lnoffset(y) df(6)
estimates store FP
xpredict lnh_fp, with(Imidt*) eq(d) constant
gen h_fp = exp(lnh_fp)*1000
bysort midtime: gen unique = _n == 1
rename midtime midtime_fp
keep if unique
keep midtime_fp h_fp
save fp_h, replace
restore

/* Spline Models */
preserve
use colon_grouped_fine, clear
gen midtime = (start + end)/2
rcs midtime, knots(0.1 0.5 1 3 4.5) gen(rcs)
tab agegrp, gen(agegrp)
glm d rcs1-rcs4 (agegrp2 agegrp3 agegrp4 female year8594), fam(pois) link(rs d_star) lnoffset(y) 
estimates store splines
xpredict lnh_splines, with(rcs*) eq(d) constant
gen h_splines = exp(lnh_splines)*1000
bysort midtime: gen unique = _n == 1
rename midtime midtime_splines
keep if unique
keep midtime_splines h_splines
save splines_h, replace
restore

estimates 	table strsrcs strsnmix piecewise FP splines, equations(1) ///
			keep(agegrp2 agegrp3 agegrp4 female year8594) b(%7.4f) se(%7.4f) ///
			modelwidth(9) title("log excess hazard ratios and standard errors for various PEH models")

drop _merge
merge using pw_h fp_h splines_h

estimates restore piecewise
forvalues i = 1/5 {
	local bh = h_pw[`i']
	local im1 = `i' - 1
	local fcn `fcn' (function y = `bh', range(`im1' `i') lcolor(black) lpattern(solid))
}

twoway	(line h_strsrcs _t if female == 0 & agegrp == 0 & year8594 == 0, sort) ///
		(line h_strsnmix _t if female == 0 & agegrp == 0 & year8594 == 0, sort) ///
		(line h_fp midtime_fp, sort) ///
		(line h_spline midtime_spline, sort) ///
		`fcn' ///
		,xtitle("Years from Diagnosis") ytitle("Excess Mortality Rate (per 1000 person years)") ///
		title("Comparison of Baseline Excess Hazard Rates from Five Different Models", size(*0.7)) ///
		ylabel(,angle(horizontal)) ///
		legend(order(1 "Splines on Cumulative Excess Hazard Scale" 2 "Non-Mixture Cure Model" ///
		3 "Fractional Polynomial Using Split-Time Data" 4 "Splines Using Split-Time Data" 5 "Piecewise") ///
		pos(1) ring(0) cols(1))