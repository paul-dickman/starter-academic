
//==================//
// EXERCISE 251
// REVISED MAY 2015
//==================//

/* (a) Load melanoma data and merge in the expected mortality  */
use melanoma, clear
stset surv_mm, failure(status=1,2) scale(12) id(id) exit(time 60.5)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + _t)


sort _year sex _age
merge m:1 _year sex _age using popmort,  keep(match master)

tab agegrp, gen(agegrp)
stpm2 agegrp2-agegrp4, scale(hazard) bhazard(rate) df(5) ///
	tvc(agegrp2-agegrp4) dftvc(3)

range temptime 0 10 1000
predict nm1, failure zeros	timevar(temptime)
predict nm2, failure at(agegrp2 1)	zeros timevar(temptime)
predict nm3, failure at(agegrp3 1)	zeros timevar(temptime)
predict nm4, failure at(agegrp4 1)	zeros timevar(temptime)



twoway (line nm1 nm2 nm3 nm4 temptime) ///
		, legend(order(1 "0-44" 2 "45-59" 3 "60-74" 4 "75+") ring(0) pos(11) cols(1)) ///
		ylabel(0(0.1)0.5, angle(h) format(%3.1f)) name("nm,replace") ///
		xtitle("Time since diagnosis") ytitle("Net probability of death")

/* (b)  estimate and plot crude mortality */

stpm2cm using popmort, at(agegrp2 0 agegrp3 0 agegrp4 0) ///
						mergeby(_year sex _age) ///
						diagage(40) diagyear(1985) ///
						sex(1) stub(cm1) nobs(1000) ///
						tgen(cm1_t)

stpm2cm using popmort, at(agegrp2 1 agegrp3 0 agegrp4 0) ///
						mergeby(_year sex _age) ///
						diagage(55) diagyear(1985) ///
						sex(1) stub(cm2) nobs(1000) ///
						tgen(cm2_t)
						
stpm2cm using popmort, at(agegrp2 0 agegrp3 1 agegrp4 0) ///
						mergeby(_year sex _age) ///
						diagage(70) diagyear(1985) ///
						sex(1) stub(cm3) nobs(1000) ///
						tgen(cm3_t)

stpm2cm using popmort, at(agegrp2 0 agegrp3 0 agegrp4 1) ///
						mergeby(_year sex _age) ///
						diagage(80) diagyear(1985) ///
						sex(1) stub(cm4) nobs(1000) ///
						tgen(cm4_t)
						
twoway (line cm1_d cm2_d cm3_d cm4_d temptime) ///
		, legend(order(1 "40" 2 "55" 3 "70" 4 "80") ring(0) pos(11) cols(1)) ///
		ylabel(0(0.1)0.5, angle(h) format(%3.1f)) name("cm,replace") ///
		xtitle("Time since diagnosis") ytitle("crude probability of death")

/* (c) crude prob of death due to other causes */
twoway (line cm1_o cm2_o cm3_o cm4_o temptime) ///
		, legend(order(1 "40" 2 "55" 3 "70" 4 "80") ring(0) pos(11) cols(1)) ///
		ylabel(0(0.1)0.7, angle(h) format(%3.1f)) name("cm_oth,replace") ///
		xtitle("Time since diagnosis") ytitle("crude probability of death")
						
/* (d) stacked graphs */
gen cm1_do = cm1_d + cm1_o
gen cm2_do = cm2_d + cm2_o
gen cm3_do = cm3_d + cm3_o
gen cm4_do = cm4_d + cm4_o
						
forvalues i = 1/4 {
	twoway	(area cm`i'_d cm`i'_t) ///
			(rarea cm`i'_do cm`i'_d cm`i'_t) ///
			(area cm`i'_do cm`i'_t, base(1)) ///
			, ylabel(0(0.2)1.0, angle(h) format(%3.1f)) ///
			xtitle("Time since diagnosis") ytitle("crude probability of death") ///
			legend(order(1 "P(Dead Cancer)" 2 "P(Dead Other Causes)" 3 "P(Alive)") ///
				cols(3)) ///
			name(cm_stack`i',replace)
}					
grc1leg cm_stack1 cm_stack2 cm_stack3 cm_stack4, nocopies	
						
/* (e) Advanced: splines for age */
rcsgen age, gen(rcsage) df(4) orthog
global knots `r(knots)'
matrix Rage = r(R)
stpm2 rcsage1-rcsage4, scale(hazard) df(5) bhazard(rate) ///
	tvc(rcsage1-rcsage4) dftvc(2)

rcsgen , scalar(40) knots($knots) rmatrix(Rage) gen(c)
stpm2cm using popmort, at(rcsage1 `=c1' rcsage2 `=c2' rcsage3 `=c3' rcsage4 `=c4') ///
						mergeby(_year sex _age) ///
						diagage(40)  diagyear(1985) ///
						sex(1) stub(cm1_rcs) nobs(1000) ///
						tgen(cm1_t_rcs)

rcsgen , scalar(55) knots($knots) rmatrix(Rage) gen(c)
stpm2cm using popmort, at(rcsage1 `=c1' rcsage2 `=c2' rcsage3 `=c3' rcsage4 `=c4') ///
						mergeby(_year sex _age) ///
						diagage(55)  diagyear(1985) ///
						sex(1) stub(cm2_rcs) nobs(1000) ///
						tgen(cm2_t_rcs)

rcsgen , scalar(70) knots($knots) rmatrix(Rage) gen(c)
stpm2cm using popmort, at(rcsage1 `=c1' rcsage2 `=c2' rcsage3 `=c3' rcsage4 `=c4') ///
						mergeby(_year sex _age) ///
						diagage(70)  diagyear(1985) ///
						sex(1) stub(cm3_rcs) nobs(1000) ///
						tgen(cm3_t_rcs)

rcsgen , scalar(80) knots($knots) rmatrix(Rage) gen(c)
stpm2cm using popmort, at(rcsage1 `=c1' rcsage2 `=c2' rcsage3 `=c3' rcsage4 `=c4') ///
						mergeby(_year sex _age) ///
						diagage(80)  diagyear(1985) ///
						sex(1) stub(cm4_rcs) nobs(1000) ///
						tgen(cm4_t_rcs)

twoway (line cm1_d cm2_d cm3_d cm4_d temptime, lcolor(red midblue midgreen magenta)) ///
		(line cm1_rcs_d cm2_rcs_d cm3_rcs_d cm4_rcs_d temptime, lcolor(red midblue midgreen magenta) ///
		lpattern(dash..)) ///
		, scheme(s2color) legend(order(1 "40" 2 "55" 3 "70" 4 "80") ring(0) pos(11) cols(1)) ///
		ylabel(0(0.1)0.5, angle(h) format(%3.1f)) name("cm_rcs,replace") ///
		xtitle("Time since diagnosis") ytitle("crude probability of death")
						
