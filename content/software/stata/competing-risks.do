/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/competing-risks.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/competing-risks/

This code illustrates how to estimate crude probabilities 
of death based on a fitted flexible parametric model. 

Paul Dickman (based on code by Paul Lambert), April 2019
***************************************************************************/

use colon if stage!=0, clear
 
gen female = (sex==2)

// Expand data
// This creates 2 copies of each observation
expand 2

// Recode and set up data for competing risk analysis
bysort id: gen cause=_n		// cause =1 for cause 1, cause =2 for cause 2

gen cancer=(cause==1)		// indicator for observation for cancer
gen other=(cause==2)		// indicator for observation for other

// Event indicator
gen event=(cause==status)  // status=1 death due to cancer, =2 death due to other

stset surv_mm, failure(event) scale(12) exit(time 120.5)

// Categorize age and create interactions with cause
forvalues i = 0/3 {
	gen age`i'can=(agegrp==`i' & cancer==1) 
	gen age`i'oth=(agegrp==`i' & other==1) 
}

// Allow different effect of sex for cancer and other */
gen fem_can = female*cancer
gen fem_other = female*other

// Fit a separate model for cancer and store the knot locations
stpm2 fem_can age1can age2can age3can if cancer == 1, ///
	df(4) scale(hazard) dftvc(3) tvc(fem_can age1can age2can age3can) eform nolog   
global knots_cancer `e(bhknots)'
global knots_cancer_tvc `e(tvcknots_age1can)'

// Fit a separate model for other and store the knot locations
stpm2 fem_oth age1oth age2oth age3oth if other == 1, ///
	df(4) scale(hazard) eform nolog   
global knots_other `e(bhknots)'

// Fit a single model using saved knot locations
stpm2 cancer other fem_can fem_oth age1can age2can age3can age1oth age2oth age3oth ///
	, scale(hazard) rcsbaseoff nocons ///
	tvc(cancer other fem_can age1can age2can age3can) eform nolog ///
	knotstvc(cancer $knots_cancer other $knots_other ///
	fem_can $knots_cancer_tvc ///
	age1can $knots_cancer_tvc ///
	age2can $knots_cancer_tvc ///
	age3can $knots_cancer_tvc)

// Estimate the cumulative incidence functions
// Only estimate the CIFS for males and for the youngest and oldest age groups
stpm2cif cancermale_age0 othermale_age0, cause1(cancer 1) cause2(other 1) 
stpm2cif cancermale_age3 othermale_age3, cause1(cancer 1 age3can 1) cause2(other 1 age3oth 1)  
	
twoway (line CIF_cancermale_age0 _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_cancermale_age3 _newt, sort lcolor(red) lpattern(solid)) /// 
	   ,ytitle("Probability of Death") /// 
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Cancer") ///
	   ylabel(0(0.1)0.6, angle(0) format(%3.1f)) name(males_can, replace)

twoway (line CIF_othermale_age0 _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_othermale_age3 _newt, sort lcolor(red) lpattern(solid)) /// 
	   ,ytitle("Probability of Death") /// 
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Other Causes") ///
	   ylabel(0(0.1)0.6, angle(0) format(%3.1f)) name(males_oth, replace)
	  
graph combine males_can males_oth, ysize(8) xsize(11) nocopies ycommon name(males, replace)
graph export competing-non-stacked.svg, replace

/* Stack the cumulative incidence functions and plot again */
gen male_total1_age0=CIF_cancermale_age0
gen male_total2_age0=CIF_cancermale_age0 + CIF_othermale_age0

gen male_total1_age3=CIF_cancermale_age3
gen male_total2_age3=CIF_cancermale_age3 + CIF_othermale_age3

twoway (area male_total2_age0 _newt, sort fintensity(75)) ///
	   (area male_total1_age0 _newt, sort fintensity(75)), ///
	    ylabel(0(0.2)1, angle(0) format(%3.1f)) ///
		ytitle("Probability of Death") xtitle("Time Since Diagnosis (Years)") ///
		legend(order(2 "Cancer" 1 "Other") size(small)) ///
        title("Males, 0-45 years") plotregion(margin(zero)) name(stack0, replace)

twoway (area male_total2_age3 _newt, sort fintensity(75)) ///
	   (area male_total1_age3 _newt, sort fintensity(75)), ///
	    ylabel(0(0.2)1, angle(0) format(%3.1f)) ///
		ytitle("Probability of Death") xtitle("Time Since Diagnosis (Years)") ///
		legend(order(2 "Cancer" 1 "Other") size(small)) ///
        title("Males, 75+ years") plotregion(margin(zero)) name(stack3, replace)
		
graph combine stack0 stack3, ysize(8) xsize(11) ycommon xcommon name(stack, replace)
graph export competing-stacked.svg, replace



