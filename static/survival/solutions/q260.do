
//==================//
// EXERCISE 260
// REVISED MAY 2015
//==================//

clear

** Load the Data, stset and merge in expected mortality **
use colon
stset surv_mm, failure(status=1 2) scale(12) exit(time 120.5)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + _t)
sort _year sex _age
merge m:1 _year sex _age using popmort,  keep(match master)

***********************************************************
* (b) Fit a mixture model to those diagnosed in 1975-1984 *
***********************************************************

strsmix if year8594==0, dist(weibull) link(identity) bhazard(rate)

/*predictions*/
predict rs7584, survival
predict rs7584u, survival uncured
/* predicted relative survival */
twoway line rs7584 _t, sort name(all, replace)
/* predicted relative survival for uncured */
twoway line rs7584u _t, sort name(uncured, replace)

***********************************************************
* (c) Fit a mixture model to those diagnosed in 1985-1994 *
***********************************************************
strsmix if year8594==1, dist(weibull) link(identity) bhazard(rate)
predict rs8594, survival
predict rs8594u, survival uncured
twoway line rs8594 _t, sort 
twoway line rs8594u _t, sort 

**************************************************
* (d) Include period of diagnosis as a covariate *
**************************************************
*(i)
strsmix year8594, dist(weibull) link(identity) bhazard(rate)

predict rs_i_s, survival
predict rs_i_u, survival uncured
twoway 	(line rs_i_s _t if year8594==0, sort) ///
		(line rs_i_s _t if year8594==1, sort) ///
		, legend(order(1 "1975-84" 2 "1985-1994") ring(0) pos(1) cols(1)) ///
		name(d_i_surv, replace)

twoway 	(line rs_i_u _t if year8594==0, sort) ///
		(line rs_i_u _t if year8594==1, sort) ///
		, legend(order(1 "1975-84" 2 "1985-1994") ring(0) pos(1) cols(1)) ///
		name(d_i_unc, replace)
		
*(ii) lambda and gamma vary by covariates
strsmix year8594, dist(weibull) link(identity) bhazard(rate) ///
	k1(year8594) k2(year8594)
predict rs_ii_s, survival
predict rs_ii_u, survival uncured
twoway 	(line rs_ii_s _t if year8594==0, sort) ///
		(line rs_ii_s _t if year8594==1, sort) ///
		, legend(order(1 "1975-84" 2 "1985-1994") ring(0) pos(1) cols(1)) ///
		name(d_ii_surv, replace)

twoway 	(line rs_ii_u _t if year8594==0, sort) ///
		(line rs_ii_u _t if year8594==1, sort) ///
		, legend(order(1 "1975-84" 2 "1985-1994") ring(0) pos(1) cols(1)) ///
		name(d_ii_unc, replace)

*******************************************
* (e) Add age of diagnosis as a covariate *
*******************************************
tab agegrp, gen(cage)
strsmix year8594 cage1 cage2 cage3 cage4, dist(weibull) link(logit) bhazard(rate) k1(year8594 cage1 cage2 cage3 cage4) k2(year8594 cage1 cage2 cage3 cage4) eform
predict med, centile
predict cure, cure
bysort agegrp year8594: gen flag = (_n==1)
list agegrp year8594 med cure if flag==1, noobs sepby(agegrp)

 
