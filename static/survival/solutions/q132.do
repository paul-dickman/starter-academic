// EXERCISE 132
// Time-dependent effects in flexible parametric models
//Load and stset the data
use melanoma, clear
keep if stage == 1
gen female = sex == 2
stset surv_mm, failure(status==1) exit(time 60.5) scale(12)

// (a) fit a Cox model 
// Assees the PH assumption for age group
stcox female year8594 i.agegrp,
forvalue i = 1/3 {
	local beta = _b[`i'.agegrp]
	estat phtest, plot(`i'.agegrp) name(sch_age`i', replace) ///
		yline(0 `beta') msize(small) msymbol(Oh) bw(0.4)		
}	
estat phtest, detail

// (b) fit flexible parametric model
tab agegrp, gen(agegrp)
stpm2 female year8594 agegrp2-agegrp4, df(4) scale(hazard) eform
estimates store ph

predict h_age1, hazard zeros per(1000)
predict h_age2, hazard at(agegrp2 1) zeros per(1000)
predict h_age3, hazard at(agegrp3 1) zeros per(1000)
predict h_age4, hazard at(agegrp4 1) zeros per(1000)

twoway	(line h_age1 _t, sort) ///
		(line h_age2 _t, sort) ///
		(line h_age3 _t, sort) ///
		(line h_age4 _t, sort) ///
		,xtitle("Time since diagnosis (years)") ///
		ytitle("Cause specific mortality rate (per 1000 py's)") ///
		legend(order(1 "<45" 2 "45-59" 3 "60-74" 4 "75+") ring(0) pos(1) cols(1)) ///
		name(hazard_ph, replace)
		
/* (c) Time-dependent effects for age group */
stpm2 female year8594 agegrp2-agegrp4, df(4) scale(hazard) ///
	tvc(agegrp2 agegrp3 agegrp4) dftvc(2)
estimates store nonph

lrtest ph nonph

/* (d) predict the hazard for each age group */
predict h_age1_tvc, hazard zeros per(1000)
predict h_age2_tvc, hazard at(agegrp2 1) zeros per(1000)
predict h_age3_tvc, hazard at(agegrp3 1) zeros per(1000)
predict h_age4_tvc, hazard at(agegrp4 1) zeros per(1000)

twoway	(line h_age1 h_age1_tvc _t, sort lcolor(red red) lpattern(solid dash)) ///
		(line h_age2 h_age2_tvc _t, sort lcolor(blue blue) lpattern(solid dash)) ///
		(line h_age3 h_age3_tvc _t, sort lcolor(magenta magenta) lpattern(solid dash)) ///
		(line h_age4 h_age4_tvc _t, sort lcolor(green green) lpattern(solid dash)) ///
		,xtitle("Time since diagnosis (years)") ///
		ytitle("Cause specific mortality rate (per 1000 py's)") ///
		legend(order(1 "<45" 3 "45-59" 5 "60-74" 7 "75+") ring(0) pos(1) cols(1)) ///
		name(hazard_tvc, replace)

/* (e) time-dependent hazard ratios */
predict hr2, hrnumerator(agegrp2 1) ci
predict hr3, hrnumerator(agegrp3 1) ci
predict hr4, hrnumerator(agegrp4 1) ci

twoway	(line hr2 hr3 hr4 _t, sort), ///
		yscale(log)  ylabel(1 2 10 20 50) ///
		legend(order(1 "Age 45-59" 2 "Age 60-74" 3 "Age 75+") ring(0) pos(1) cols(1)) ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Hazard ratio") ///
		name(hr, replace)
		
twoway (rarea hr4_lci hr4_uci _t, sort pstyle(ci)) ///
		(line hr4 _t, sort) ///
		,legend(off) yscale(log) ylabel(1 2 10 20 50) ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Hazard ratio") ///
		name("hr_age4", replace)

/* (f) Difference in hazard rates */
predict hdiff4, hdiff1(agegrp4 1) ci per(1000)
twoway (rarea hdiff4_lci hdiff4_uci _t, sort) ///
		(line hdiff4 _t, sort) ///
		,legend(off)  ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Difference in mortality rate (per 1000py)") ///
		name(hdiff, replace)

/* (g) Difference in survival functions */
predict s1, surv at(female 1 year8594 1) zeros
predict s2, surv at(agegrp4 1 female 1 year8594 1) zeros
twoway	line s1 s2 _t, sort ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("S(t)") ///
		legend(order(1 "<45" 2 "75+") ring(0) pos(1) cols(1)) ///
		name(surv_old_young, replace)
		
predict sdiff4, sdiff1(agegrp4 1 sex 2 year8594 1) ///
				sdiff2(agegrp4 0 sex 2 year8594 1) ci
twoway (rarea sdiff4_lci sdiff4_uci _t, sort) ///
		(line sdiff4 _t, sort) ///
		,legend(off)  ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Difference in survival functions") ///
		name(sdiff, replace)

/* (h) varying df for time-dependent effects */
forvalues i = 1/3 {
	stpm2 i.sex year8594 agegrp2-agegrp4, df(4) scale(hazard) ///
		tvc(agegrp2 agegrp3 agegrp4) dftvc(`i')
	estimates store dftvc`i'
	predict hr4_df`i', hrnumerator(agegrp4 1) ci
}
count if _d==1
estimates stats dftvc*, n(`r(N)')

twoway	(line hr4_df1 hr4_df1_lci hr4_df1_uci _t, sort lcolor(red..) lpattern(solid dash dash) lwidth(medthick thin thin)) ///
		(line hr4_df2 hr4_df2_lci hr4_df2_uci _t, sort lcolor(midblue..) lpattern(solid dash dash) lwidth(medthick thin thin)) ///
		(line hr4_df3 hr4_df3_lci hr4_df3_uci _t, sort lcolor(midgreen..) lpattern(solid dash dash) lwidth(medthick thin thin)) ///
		if _t>0.1, ///
		yscale(log) ///
		ylabel(1 2 4 8 20 50, angle(h)) ///
		legend(order(1 "1 df" 4 "2 df" 7 "3 df") ring(0) pos(1) cols(1)) ///
		xtitle("Time since diagnosis (years)") ///
		ytitle("Hazard Ratio") ///
		yscale(log) ///
		name(tvc_df_comp, replace)
		
/* (i) two time-dependent effects */
stpm2 female  agegrp2-agegrp4, df(4) scale(hazard) ///
	tvc(agegrp2 agegrp3 agegrp4 female) dftvc(3)
predict hr_f_age1, hrnum(female 1) ci
predict hr_f_age4, hrnum(female 1 agegrp4 1) hrdenom(agegrp4 1) ci
	
twoway (line hr_f_age1* hr_f_age4* _t if _t>0.1, sort yscale(log))	
	
// (j) note if we fit a model on the log hazard scale - we do not get this problem
// but the models take longer to fit as we need to use
// numerical integration.		
strcs female  agegrp2-agegrp4, df(4) ///
	tvc(agegrp2 agegrp3 agegrp4 female) dftvc(3) nodes(50)
predict hr_f_age1b, hrnum(female 1) ci
predict hr_f_age4b, hrnum(female 1 agegrp4 1) hrdenom(agegrp4 1) ci

twoway (line hr_f_age1b* hr_f_age4b* _t if _t>0.1, sort yscale(log))	

	
		
