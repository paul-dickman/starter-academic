
//==================//
// EXERCISE 230
// REVISED MAY 2015
//==================//

clear

****************************************************************
* (a) Load Data, merge expected mortality and fit inital model *
****************************************************************
use melanoma
stset surv_mm, failure(status=1 2) scale(12) exit(time 120.5) id(id)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + _t)
sort _year sex _age
merge m:1 _year sex _age using popmort,  keep(match master)
tab agegrp, gen(agegrp)
gen female = sex == 2
/* Fit initial model */
stpm2, df(3) scale(hazard) bhazard(rate) 
predict h1, hazard per (1000) ci
predict s1, survival ci

********************************************************
* (b) Plot the predicted hazard and survival functions *
********************************************************
twoway	(rarea h1_lci h1_uci _t, sort pstyle(ci)) ///
		(line h1 _t, sort), name(h1,replace) legend(off) ///
		xtitle("time since diagnosis") ///
		ytitle("excess mortality rate (per 1000 py's)")
						
twoway	(rarea s1_lci s1_uci _t, sort pstyle(ci)) ///
			(line s1 _t, sort), name(s1,replace) legend(off) ///
		xtitle("time since diagnosis") ///
		ytitle("relative survival")

********************************************
* (c) Compare fitted values for various df *
********************************************

foreach df in 2 4 6 {
	stpm2, df(`df') scale(hazard) bhazard(rate)
	predict h_df`df', hazard 
	replace h_df`df' = h_df`df' * 1000
	predict s_df`df', survival 
	estimates store df`df'
}

/*Plot the excess hazard functions*/
twoway (line h_df2 h_df4 h_df6 _t, sort lcolor(red blue black))

/*Plot the survival functions*/
twoway (line s_df2 s_df4 s_df6 _t, sort lcolor(red blue black)) 


estimates stats df2 df4 df6, n(2773)

***********************************************
* (d) Fit a proportional excess hazards model *
***********************************************

stpm2 agegrp2 agegrp3 agegrp4 female year8594, bhazard(rate) ///
   df(3) scale(hazard) eform
predict h2, hazard per(1000) ci
predict s2, survival ci

*****************************************
* (e)	Plot predicted excess hazard rate *	
*****************************************

twoway	(line h2 _t if agegrp1 == 1 & female == 0 & year8594 == 1, sort) ///
			(line h2 _t if agegrp4 == 1 & female == 0 & year8594 == 1, sort) /// 
			,legend(label (1 "Youngest") label (2 "Oldest")) scheme(sj) ///
			xtitle("Excess hazard rate") ytitle("Time since diagnosis")


twoway	(line h2 _t if agegrp1 == 1 & female == 0 & year8594 == 1, sort) ///
			(line h2 _t if agegrp4 == 1 & female == 0 & year8594 == 1, sort) ///
			,yscale(log) legend(label (1 "Youngest") label (2 "Oldest")) scheme(sj) ///
			xtitle("Excess hazard rate") ytitle("Time since diagnosis (log)")

********************************************
* (f) Time-dependent effects for age group *
********************************************

stpm2 agegrp2 agegrp3 agegrp4 female year8594, bhazard(rate) df(3) scale(hazard) ///
			tvc(agegrp2 agegrp3 agegrp4) dftvc(2)
predict h3, hazard per(1000) ci
predict s3, survival ci

twoway	(line h3 _t if agegrp1 == 1 & female == 0 & year8594 == 1, sort) ///
			(line h3 _t if agegrp4 == 1 & female == 0 & year8594 == 1, sort) ///
			, legend(label (1 "Youngest") label (2 "Oldest")) scheme(sj) ///
			xtitle("Excess hazard rate") ytitle("Time since diagnosis")

twoway	(line h3 _t if agegrp1 == 1 & female == 0 & year8594 == 1, sort) ///
			(line h3 _t if agegrp4 == 1 & female == 0 & year8594 == 1, sort) ///
			,yscale(log) legend(label (1 "Youngest") label (2 "Oldest")) scheme(sj) ///
			xtitle("Excess hazard rate") ytitle("Time since diagnosis (log)")


*******************************************************
* (g) predicted (time-dependent) excess hazard ratios *
*******************************************************
predict hr2, hrnum(agegrp2 1) ci
predict hr3, hrnum(agegrp3 1) ci
predict hr4, hrnum(agegrp4 1) ci

twoway	(line hr2 _t if agegrp2 == 1 & female == 0 & year8594 == 1, sort) ///
		(line hr3 _t if agegrp3 == 1 & female == 0 & year8594 == 1, sort) ///
		(line hr4 _t if agegrp4 == 1 & female == 0 & year8594 == 1, sort) ///
		, legend(label (1 "Agegrp2") label (2 "Agegrp3") label(3 "Agegrp4")) ///
		xtitle("Time since diagnosis") ytitle("Excess mortality rate") scheme(sj)

			
twoway	(rarea hr4_lci hr4_uci _t, sort pstyle(ci)) ///
		(line hr4 _t, sort), yline(1) legend(off) ///
        xtitle("Years from Diagnosis") ///
        ytitle("Excess Mortality Rate Ratio")
 
			
***************************************
* (h) difference in relative survival *
***************************************
predict sdiff4, sdiff1(agegrp4 1 female 0 year8594 1) ///
                sdiff2(agegrp4 0 female 0 year8594 1) ci
twoway  (rarea sdiff4_lci sdiff4_uci _t, sort pstyle(ci)) ///
        (line sdiff4 _t, sort), yline(0) legend(off) ///
        xtitle("Years from Diagnosis") ///
        ytitle("Difference in Relative Survival")
 

*******************************************
* (i) difference in excess mortality rate *
*******************************************						

predict hdiff4, hdiff1(agegrp4 1 female 0 year8594 1) ///
                hdiff2(agegrp4 0 female 0 year8594 1) ci
replace hdiff4 = hdiff4*1000
replace hdiff4_lci = hdiff4_lci*1000
replace hdiff4_uci = hdiff4_uci*1000
                
twoway  (rarea hdiff4_lci hdiff4_uci _t, sort pstyle(ci)) ///
        (line hdiff4 _t, sort), yline(0) legend(off) ///
        xtitle("Years from Diagnosis") ///
        ytitle("Difference in Excess Mortality Rate")
 





