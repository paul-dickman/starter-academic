/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/hazard_ratio_with_effect_modification.do

In this tutorial we will model cause-specific survival using flexible parametric models, 
with a focus on studying whether the effect of a binary exposure of interest (sex in this case) 
varies as a function of year of diagnosis (modelled as a restricted cubic spline).

See http://pauldickman.com/software/stata/hazard_ratio_with_effect_modification/ for details.

Paul Dickman, February 2021
***************************************************************************/

// read data from web; exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// outcome is cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// create dummy variables for modelling
generate male=(sex==1)
quietly tab agegrp, generate(agegrp)

// generate spline variables for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog

// interaction between sex and yearspl
generate maleyr1=male*yearspl1
generate maleyr2=male*yearspl2
generate maleyr3=male*yearspl3

// our model includes an interaction between sex and year of diagnosis, but assumes HR is constant over time-since diagnosis
stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
      tvc(agegrp2 agegrp3 agegrp4) dftvc(2)
estimates store interaction

// predict HR for males to females. Note that this depends on year of diagnosis but not time-since diagnosis
// For the numerator we want male=1, maleyr1=yearspl1, maleyr2=yearspl2, and maleyr3=yearspl3
//     (with all other covariates zero)
// For the demominator we want all covariates zero
// predict after stpm2 sets the value of any covariates not explicitly mentioned to zero
// predicting at "." specifies at the observed values of the covariates
// therefore, we predict only for males at the observed values of covariates
predict hr if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) ci
 
twoway (rarea hr_lci hr_uci yydx, sort color(red%25)) ///
                 (line hr yydx, sort lcolor(red)) /// 
                 , legend(off) ysize(8) xsize(11) ///
                 ylabel(,angle(h) format(%3.2f)) ///
                 ytitle("Hazard ratio (male/female)") name("hr", replace) ///
                 xtitle("Year of diagnosis")
				 
graph export hazard_ratio_with_effect_modification.svg
		
// test if the HR for sex depends on year of diagnosis
stpm2 yearspl* male agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
      tvc(agegrp2 agegrp3 agegrp4) dftvc(2)
lrtest interaction

// let's now relax the assumption that the HR for sex is constant over follow-up time
stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
      tvc(yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4) dftvc(2)

// predict the HR at 1, 5, and 10 years
generate t1=1
generate t5=5
generate t10=10
	  
predict hr1 if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) timevar(t1)
predict hr5 if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) timevar(t5) 
predict hr10 if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) timevar(t10)

twoway (line hr1 yydx, sort lcolor(red) lpattern(dash_dot)) /// 
       (line hr5 yydx, sort lcolor(blue) lpattern(solid)) /// 
       (line hr10 yydx, sort lcolor(green) lpattern(shortdash)) /// 
                 , ysize(8) xsize(11) ///
                 ylabel(,angle(h) format(%3.2f)) ///
                 ytitle("Hazard ratio (male/female)") name("hr2", replace) ///
                 xtitle("Year of diagnosis") ///
				 legend(label(1 "HR at 1 year") label(2 "HR at 5 years") label(3 "HR at 10 years"))
				 
graph export hazard_ratio_with_effect_modification_tvc.svg


				 

