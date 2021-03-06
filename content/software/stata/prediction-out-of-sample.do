/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/prediction-out-of-sample.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/prediction-out-of-sample/

Paul Dickman, October 2019
***************************************************************************/

/***********************************************************************
Create a data set in which to do the predictions
This data set will have 49 observations, 1 observation for each
year from 1975 to 1999 in 0.5 year increments.
We have data for patients diagnosed 1975 to 1994, so the last
5 years will be out-of-sample predictions.
We will fit a separate model for each age group and then predict
survival at each value of year. Technically, we are predicting at 
the values of the spline variables for year (so need to create them).
The variable _t must exist, but is not used in the predictions.
**********************************************************************/

// Need to save the projection matrix and knots for the spline variables
// created in the patient data
use https://pauldickman.com/data/colon.dta if stage==1, clear
rcsgen yydx, df(3) gen(yearspl) orthog
matrix Ryydx = r(R)
global knotyydx `r(knots)'

// Now create a data set in which to make the predictions
clear
range yydx 1975 1999 49
// create spline variables using patient data projection matrix and knots
rcsgen yydx, gen(yearspl) rmatrix(Ryydx) knots($knotyydx)
generate t1=1 
generate t5=5 
generate _t=.
generate _d=.
save predictions, replace

use https://pauldickman.com/data/colon.dta if stage==1, clear
stset surv_mm, fail(status==1,2) scale(12)

// spline variable for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog

// New age groups according to the International Cancer Survival Standard (ICSS)
drop agegrp
label drop agegrp
egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
label variable agegrp "Age group"
label define agegrp 1 "15-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+" 
label values agegrp agegrp

// Fit the model for each age group
// Predict 1 and 5-year survival for selected values of year and save the predictions
// We are sequentionally adding predictions to the data set predictions.dta
forvalues j = 1/5 {
stpm2 yearspl? if agegrp==`j', scale(h) df(4) eform tvc(yearspl?) dftvc(1)
preserve
use predictions, clear
predict stand1_`j', s timevar(t1)
predict stand5_`j', s timevar(t5)
save predictions, replace
restore
}

// Now calculate the age-standardised estimates
use predictions, clear
gen rs_stand1yr = 0.07*stand1_1 + 0.12*stand1_2 + 0.23*stand1_3 + 0.29*stand1_4 + 0.29*stand1_5
gen rs_stand5yr = 0.07*stand5_1 + 0.12*stand5_2 + 0.23*stand5_3 + 0.29*stand5_4 + 0.29*stand5_5

twoway 	(line stand1_1 yydx , sort lpattern(shortdash) lwidth(medthick) lcolor(black)) ///
		(line stand1_2 yydx , sort lpattern(dash_dot) lwidth(medthick) lcolor(black)) ///
		(line stand1_3 yydx , sort lpattern(longdash) lwidth(medthick) lcolor(black)) ///
		(line stand1_4 yydx , sort lpattern(longdash_dot) lwidth(medthick) lcolor(black)) ///
		(line stand1_5 yydx , sort lpattern(solid) lwidth(medthick) lcolor(black)) ///
		(line rs_stand1yr yydx, sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
		, legend(label(1 "18-44") label(2 "45-59") label(3 "55-64") label(4 "65-74") label(5 "75+")   ///  
		label(6 "Age stand") ring(0) pos(6) col(2)) scheme(sj) name(surv1, replace) ysize(8) xsize(11) ///
		subtitle("`text`i''", size(*1.0)) ytitle("1-year survival proportion", size(*1.0)) xtitle("Year of diagnosis", size(*1.0)) ///
		ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.0) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.0))
graph export prediction-out-of-sample-surv1.svg, replace

twoway 	(line stand5_1 yydx , sort lpattern(shortdash) lwidth(medthick) lcolor(black)) ///
		(line stand5_2 yydx , sort lpattern(dash_dot) lwidth(medthick) lcolor(black)) ///
		(line stand5_3 yydx , sort lpattern(longdash) lwidth(medthick) lcolor(black)) ///
		(line stand5_4 yydx , sort lpattern(longdash_dot) lwidth(medthick) lcolor(black)) ///
		(line stand5_5 yydx , sort lpattern(solid) lwidth(medthick) lcolor(black)) ///
		(line rs_stand5yr yydx, sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
		, legend(label(1 "18-44") label(2 "45-59") label(3 "55-64") label(4 "65-74") label(5 "75+")   ///  
		label(6 "Age stand") ring(0) pos(6) col(2)) scheme(sj) name(surv5, replace) ysize(8) xsize(11) ///
		subtitle("`text`i''", size(*1.0)) ytitle("5-year survival proportion", size(*1.0)) xtitle("Year of diagnosis", size(*1.0)) ///
		ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.0) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.0))
graph export prediction-out-of-sample-surv5.svg, replace


