/* Other scales */
/* EXERCISE 133 */

use melanoma, clear
gen female = sex == 2
stset surv_mm, failure(status=1) scale(12) exit(time 60.5)

// (a) PH Model
stpm2 female i.agegrp year8594, scale(hazard) df(4) eform
forvalues i = 0/3 {
	predict s_age`i'_ph, surv at(agegrp `i') zeros
	predict h_age`i'_ph, hazard at(agegrp `i') zeros
}
	estimates store ph
// (b) Proportional Odds Model
stpm2 female i.agegrp year8594, scale(odds) df(4) eform
forvalues i = 0/3 {
	predict s_age`i'_po, surv at(agegrp `i') zeros
	predict h_age`i'_po, hazard at(agegrp `i') zeros
}
	estimates store po
// (c) Compare survival and hazard functiona
twoway (line s_age0_ph _t, sort) ///
		(line s_age0_po _t, sort) ///
		(line s_age3_ph _t, sort) ///
		(line s_age3_po _t, sort) ///
		, name(survcomp, replace) 
*graph export "../eps/q133c_1.pdf", replace		

twoway (line h_age0_ph _t, sort) ///
		(line h_age0_po _t, sort) ///
		(line h_age3_ph _t, sort) ///
		(line h_age3_po _t, sort) ///
		, name(hazcomp,replace)
*graph export "../eps/q133c_2.pdf", replace		
		
// (d) Compare AIC and BIC
count if _d == 1
estimates stats ph po, n(`r(N)')	

// (e) Hazard ratio for female
predict hr_female_age0_7584, hrnum(female 1) hrdenom(female 0) ci
twoway	(rarea hr_female_age0_7584_lci hr_female_age0_7584_uci _t, sort pstyle(ci)) ///
		(line hr_female_age0_7584 _t, sort) ///
		,legend(off) ///
		xtitle("Years since diagnosis") ///
		ytitle("Hazard Ratio") ///
		title("HR for sex (age<45, diagnoised 1975-1984)") ///
		name(HR1, replace)
*graph export "../eps/q133e.pdf", replace		
		

// (f) Compare hazard ratios for different covariate patterns		
predict hr_female_age3_7584, hrnum(female 1 agegrp 3) hrdenom(female 0 agegrp 3) ci
twoway	(line hr_female_age0_7584 _t, sort) ///
		(line hr_female_age3_7584 _t, sort) ///
		,name(HR2, replace)
*graph export "../eps/q133f.pdf", replace		

// (g) Fit Aranda-Ordaz link function
stpm2 female i.agegrp year8594, scale(theta) df(4) 
estimates store ao
count if _d == 1
estimates stats ph po ao, n(`r(N)')

// (h) Show estimate of theta with 95% CI
lincom [ln_theta][_cons], eform		



