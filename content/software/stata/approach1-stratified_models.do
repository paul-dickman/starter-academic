/***************************************************************************
APPROACH 1 - FITTING STRATIFIED MODELS

1. Estimate internally age-standardised 5-year survival for males and females
   for each year of diagnosis

Paul Dickman & Paul Lambert, February 2021
***************************************************************************/

// read data from web; exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// generate spline variables for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog
global yearknots `r(knots)'
matrix R = r(R)

// Now create a data set in which to make the predictions
clear
range yydx 1975 1994 20
// create spline variables using patient data projection matrix and knots
rcsgen yydx, gen(yearspl) rmatrix(R) knots($yearknots)
generate t1=1 
generate t5=5 
generate _t=.
generate _d=.
expand 2, generate(male)
// interaction between sex and yearspl
generate maleyr1=male*yearspl1
generate maleyr2=male*yearspl2
generate maleyr3=male*yearspl3
save predictions, replace

// read data from web; exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// outcome is cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// Reclassify age groups according to International Cancer Survival Standard (ICSS 2)
// Overview: https://seer.cancer.gov/stdpopulations/survival.html
// Original publication: https://www.sciencedirect.com/science/article/abs/pii/S0959804904005283
drop agegrp
label drop agegrp
drop if age < 15
egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
label define agegrp 1 "15-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+" 
label values agegrp agegrp

// Generate a veraiable with ICSS weights (we use ICSS 2 for melanoma)
recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt)

// create dummy variables for modelling
generate male=(sex==1)
quietly tab agegrp, generate(agegrp)

// generate spline variables for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog

// interaction between sex and yearspl
generate maleyr1=male*yearspl1
generate maleyr2=male*yearspl2
generate maleyr3=male*yearspl3

// Fit the model for each age group
// Predict 1 and 5-year survival for selected values of year and save the predictions
// We are sequentionally adding predictions to the data set predictions.dta
forvalues j = 1/5 {
stpm2 male maleyr1 maleyr2 maleyr3 yearspl? if agegrp==`j', scale(h) df(4) eform
preserve
use predictions, clear
predict stand5_`j', s timevar(t5)
save predictions, replace
restore
}

// Now calculate and plot the age-standardised estimates
use predictions, clear
gen rs_stand5yr = 0.28*stand5_1 + 0.17*stand5_2 + 0.21*stand5_3 + 0.20*stand5_4 + 0.14*stand5_5

twoway 	(line rs_stand5yr yydx if male==0, sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
        (line rs_stand5yr yydx if male==1, sort lpattern(dash) lwidth(medthick) lcolor(blue)) ///
		, legend(label(1 "female") label(2 "male") ring(0) pos(6) col(1)) scheme(sj) name(approach1, replace) ysize(8) xsize(11) ///
		subtitle("`text`i''", size(*1.0)) ytitle("5-year survival proportion", size(*1.0)) xtitle("Year of diagnosis", size(*1.0)) ///
		ylabel(0.5 0.6 0.7 0.8 0.9, labsize(*1.0) angle(0) format(%3.2f)) yscale(range(0.5 0.9)) xlabel(, labsize(*1.0))

exit

**************************** END OF FILE **********************************************************************



				 

