
//==================//
// EXERCISE 242
// REVISED MAY 2015
//==================//

/* (a) Load Data and merge in expected mortality */
use melanoma, clear
keep if stage == 1
stset surv_mm, failure(status=1,2) scale(12) id(id) exit(time 120.5)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + _t)

sort _year sex _age
merge m:1 _year sex _age using popmort,  keep(match master)

stpm2, scale(hazard) df(5) bhazard(rate)
range temptime 0 10 100
predict rs_noage, survival timevar(temptime) ci
list rs_noage* if temptime == 10

/* (b) Fit PEH model and predict relative survival in each age group */
tab agegrp, gen(agegrp)
stpm2 agegrp2-agegrp4, scale(hazard) df(5) bhazard(rate) eform
predict rs0, survival zeros timevar(temptime)
predict rs1, survival at(agegrp2 1) zeros timevar(temptime)
predict rs2, survival at(agegrp3 1) zeros timevar(temptime)
predict rs3, survival at(agegrp4 1) zeros timevar(temptime)

twoway	(line rs0 rs1 rs2 rs3 temptime, sort) ///
		(line rs_noage temptime, lcolor(black) lpattern(dash)) ///
		, scheme(s2color) ///
		legend(order(1 "0-44" 2 "45-59" 3 "60-74" 4 "75+" 5 "All age") ///
			pos(7) cols(1) ring(0)) ///
		xtitle("Years since diagnosis") ///
		ytitle("Relative Survival") ///
		ylabel(,angle(h) format(%3.1f))
		

/* (c) Tabulate agegrp and obtain weighted average of 4 relative survival curves */	
tab agegrp
gen rs_stand1 = 0.2751*rs0 + 0.2962*rs1 + 0.2888*rs2 + 0.1399*rs3

twoway	(line rs0 rs1 rs2 rs3 temptime, sort) ///
		(line rs_noage temptime, lcolor(black) lpattern(longdash)) ///
		(line rs_stand1 temptime, lcolor(black) lpattern(shortdash)) ///
		, scheme(s2color) ///
		legend(order(1 "0-44" 2 "45-59" 3 "60-74" 4 "75+" 5 "All age" 6 "Age Standardized") ///
			pos(7) cols(1) ring(0)) ///
		xtitle("Years since diagnosis") ///
		ytitle("Relative Survival") ///
		ylabel(,angle(h) format(%3.1f))

		
/* (d) Age standardized relative survival at 10 years */
list rs_stand1 if temptime == 10 
		
		
/* (e) Use the meansurv option */
predict rs_stand2, meansurv timevar(temptime) 

twoway line rs_stand1 rs_stand2 temptime, sort

/* (f) Obtaining confidence intervals */
predict rs_stand3, meansurv timevar(temptime) ci
list rs_stand3* if temptime == 10

/* (g) Fit a PEH model for age group and calendar period */
stpm2 agegrp2-agegrp4 year8594, scale(hazard) df(5) bhazard(rate)

predict rs, survival
table agegrp year8594, c(mean rs) format(%5.3f)

/* (h) Change in age distribution between calendar periods */
tab agegrp year8594 , col

/* (i) Predict relative survival for each calendar period */
/* Standardize to age distribution in first calendar period */
predict rs_7584 if year8594 == 0, meansurv at(year8594 0) timevar(temptime) 
predict rs_8594 if year8594 == 0, meansurv at(year8594 1) timevar(temptime) 

twoway	(line rs_7584 rs_8594 temptime, sort) ///
		, scheme(s2color) ///
		legend(order(1 "1975-1984" 2 "1985-1994") ///
			pos(7) cols(1) ring(0)) ///
		xtitle("Years since diagnosis") ///
		ytitle("Relative Survival") ///
		ylabel(,angle(h) format(%4.2f))

list rs_7584 rs_8594 if temptime == 10

	
/* (j) Standardize to age distribution in second calendar period */
predict rs_8594b if year8594 == 1, meansurv at(year8594 1) timevar(temptime)

twoway	(line rs_7584 rs_8594 rs_8594b temptime, sort) ///
		, scheme(s2color) ///
		legend(order(1 "1975-1984 (Reference 1975-1984)" 2 "1985-1994 (Reference 1975-1984)" ///
		3 "1985-1994 (Reference 1985-1994)") pos(1) cols(1) ring(0)) ///
		xtitle("Years since diagnosis") ///
		ytitle("Relative Survival") ///
		ylabel(,angle(h) format(%4.2f))


