/************************************************************************
COLON_COMPARE_ALL_NONPEH_MODELS.DO
Paul Lambert (paul.lambert@le.ac.uk)

Fits various cure models to model the time-dependent excess hazard ratio 
for the oldest vs the youngest age group

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

/* Splines on Log-Cumulative Hazard Scale */
strsrcs female year8594, df(4) bhazard(brate) scale(hazard) strata(agegrp2 agegrp3 agegrp4)
gen tmpt = _t 
qui predictnl double lhr_strsrcs= ///
	 ln(_d_rcs1*([s1][_cons] + [s1][agegrp4]) + _d_rcs2*([s2][_cons] + [s2][agegrp4]) + ///
		_d_rcs3*([s3][_cons] + [s3][agegrp4]) + _d_rcs4*([s4][_cons] + [s4][agegrp4])) ///
	+ [xb][agegrp4] + [s1][agegrp4]*_rcs1 + [s2][agegrp4]*_rcs2 + [s3][agegrp4]*_rcs3 + [s4][agegrp4]*_rcs4 - ///
     ln(_d_rcs1*([s1][_cons]) + _d_rcs2*([s2][_cons]) + ///
		_d_rcs3*([s3][_cons]) + _d_rcs4*([s4][_cons])) ///
	 , ci(lhr_lci lhr_uci) 

/* Piecewise Models */
preserve
use colon_grouped, clear
tab end, gen(end)
tab agegrp, gen(agegrp)
forvalues i = 1/5 {
	forvalues j = 2/4 {
		gen end`i'age`j' = end`i' * agegrp`j'
	}
}
glm d end1-end5 end?age? female year8594, fam(pois) link(rs d_star) lnoffset(y) nocons
estimates store pw_nonpeh
xpredict lhr_pw, with(end?age4) eq(d)
bysort end agegrp4: gen unique = _n == 1
rename end end_pw
keep if unique & agegrp4 == 1
keep end_pw lhr_pw
save pw_hr, replace
restore

/* Fractional Polynomial Models */
preserve
use colon_grouped_fine, clear
gen midtime = (start + end)/2
tab agegrp, gen(agegrp)
forvalues i = 2/4 {
	gen midtime_age`i' = midtime*agegrp`i'
}

mfp glm d midtime midtime_age4 midtime_age3 midtime_age2 (agegrp2 agegrp3 agegrp4 female year8594), ///
	fam(pois) link(rs d_star) lnoffset(y) df(4,midtime:6) zero(midtime_age4 midtime_age3 midtime_age2) xorder(n) ///
	alpha(-1) adjust(no)
xpredict lnhr_fp, with(agegrp4 Imidta_1) eq(d) 
bysort midtime agegrp4: gen unique = _n == 1
rename midtime midtime_fp
keep if unique & agegrp4 == 1
keep midtime_fp lnhr_fp
save fp_hr, replace
restore

/* Spline Models */
preserve
use colon_grouped_fine, clear
gen midtime = (start + end)/2
rcs midtime, knots(0.1 0.5 1 3 4.5) gen(rcs)
tab agegrp, gen(agegrp)
forvalues i = 1/4 {
	forvalues j = 2/4 {
		gen rcs`i'age`j' = rcs`i'*agegrp`j'
	}
}
glm d rcs1-rcs4 rcs?age? (agegrp2 agegrp3 agegrp4 female year8594), fam(pois) link(rs d_star) lnoffset(y) 
xpredict lnhr_splines, with(agegrp4 rcs1age4 rcs2age4 rcs3age4 rcs4age4) eq(d) 
bysort midtime agegrp4: gen unique = _n == 1
rename midtime midtime_splines
keep if unique & agegrp4 == 1
keep midtime_splines lnhr_splines
save splines_hr, replace
restore

drop _merge
merge using pw_hr fp_hr splines_hr

estimates restore pw_nonpeh
forvalues i = 1/5 {
	local bh = lhr_pw[`i']
	local im1 = `i' - 1
	local fcn `fcn' (function y = `bh', range(`im1' `i') lcolor(black) lpattern(solid))
}

twoway	(line lhr_strsrcs _t , sort) ///
		(line lnhr_fp midtime_fp, sort) ///
		(line lnhr_spline midtime_spline, sort) ///
		`fcn' ///
		,xtitle("Years from Diagnosis") ytitle("Log Excess Mortality Rate Ratio") ///
		title("Comparison of Log Excess Mortality Rate Ratios from Four Different Models", size(*0.7)) ///
		ylabel(,angle(horizontal)) ///
		legend(order(1 "Splines on Cumulative Excess Hazard Scale"  ///
		2 "Fractional Polynomial Using Split-Time Data" 3 "Splines Using Split-Time Data" 4 "Piecewise") ///
		pos(1) ring(0) cols(1))
