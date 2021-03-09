
//==================//
// EXERCISE 284
// REVISED MAY 2015
//==================//

/* (a) Load melanoma data and stset*/
use melanoma, clear
gen patid = _n
stset surv_mm, failure(status=1 2) scale(12) exit(time 120.5) id(patid)


/* (b) Fit a flexible parametric model including year, age and sex */
rcsgen age, df(4) gen(sag) orthog	/*spline variables for age*/
rcsgen yydx, df(4) gen(syr) orthog	/*spline variables for year*/
gen fem = sex==2		/*create dummy variable for sex*/

gen _age = min(int(age + _t),99)	/*merge on expected rates at exittime*/
gen _year = int(yydx + _t)
sort _year sex _age
merge m:1 _year sex _age using popmort, keep(match master) keepusing(rate)
drop _age _year _merge 

stpm2 sag1-sag4 syr1-syr4 fem, scale(hazard) df(5) bhazard(rate) ///
		tvc(sag1-sag4 syr1-syr4 fem) dftvc(3)

		
/* (c)  Predict loss in expectation of life */
predict ll, lifelost mergeby(_year sex _age) diagage(age) diagyear(yydx) nodes(40) tinf(80) ///
				using(popmort) stub(surv) maxyear(2000) /*ci*/

				
/* (d) Create a graph that shows how the loss in expectation of life varies over age, for males diagnosed in 1994.*/  
twoway (line ll age if sex==1 & yydx==1994, sort) , legend(off) scheme(sj) name(q41_d, replace) ytitle("Years", size(*0.8)) ///
		xtitle("Age at diagnosis", size(*0.8)) ylabel(0 5 10 15 20 25 30 35 40 45, labsize(*0.7) angle(0)) yscale(range(0 45)) xlabel(, labsize(*0.7))
	

/* (e) List life expectancy and loss in expectation of life for a few selected ages, as well as total number of life years lost, for dx 1994*/

foreach age in 50 60 70 80 {
	foreach sex in 1 2 {
		list age sex yydx survexp survobs ll if age==`age' & sex==`sex' & yydx==1994, constant
	}
}
qui summ ll if yydx==1994 /*Total number of life years lost for the patients diagnosed 1994*/
display r(sum)



/* (f) Predict loss in expectation of life if males had the same relative survival as females */

replace fem=1

predict ll_alt, lifelost mergeby(_year sex _age) diagage(age) diagyear(yydx) nodes(40) tinf(80) ///
				using(popmort) stub(surv_alt) maxyear(2000) /*ci*/



/* (g) Calculate number of life years that could potentially be saved if males diagnosed in 1994 had the same relative survival as females*/

gen lldiff= ll-ll_alt
summ lldiff if yydx==1994
display r(sum)

foreach age in 50 60 70 80 {
  list ll ll_alt lldiff age if sex==1 & age==`age' & yydx==1994, constant
}

