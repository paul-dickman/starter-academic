
//==================//
// EXERCISE 140
// REVISED January 2018
//==================//

use colon, clear
drop if stage ==0
gen female = sex==2

/* Cancer mortality */
stset surv_mm, failure(status==1) scale(12) exit(time 120.5)
tab status _d
sts generate surv1_sex = s, by(female) 

/* Other cause mortality */
stset surv_mm, failure(status==2) scale(12) exit(time 120.5)
tab status _d
sts generate surv2_sex = s, by(female) 

/* Plot the complement of the Kaplan-Meier survival estimate for each cause */
gen prob1_sex = 1-surv1_sex
gen prob2_sex = 1-surv2_sex

twoway (line prob1_sex _t if female == 0, sort lcolor(black) lpattern(solid)) ///
	   (line prob2_sex _t if female == 0, sort lcolor(black) lpattern(dash)), ///
	   ytitle("Probability of Death") ///
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "Cancer" 2 "Other Causes")) ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(KM, replace) 

/* Estimate the cumulative incidence function (CIF) */
stset surv_mm, failure(status==1) scale(12) exit(time 120.5)
stcompet CIF_sex=ci, compet1(2) by(sex)
gen CIF_sex_cancer=CIF_sex if status==1
gen CIF_sex_other=CIF_sex if status==2

/* Plot the cumulative incidence function along with the complement of the Kaplan-Meier estimates */
twoway (line prob1_sex _t if female==0, sort lcolor(black) lpattern(solid)) ///
	   (line prob2_sex _t if female==0, sort lcolor(black) lpattern(dash)) ///
	   (line CIF_sex_cancer _t if female==0, sort lcolor(gs10) lpattern(solid)) ///
	   (line CIF_sex_other _t if female==0, sort lcolor(gs10) lpattern(dash)), ///
	   ytitle("Probability of Death") ///
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "Cancer K-M" 2 "Other K-M" 3 "Cancer CIF" 4 "Other CIF")) ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(KMandCIF, replace)
	

/* Estimate CIF by age group */
stset surv_mm, failure(status==1) scale(12) exit(time 120.5)
stcompet CIF_age=ci, compet1(2) by(agegrp)
	 
twoway	(line CIF_age _t if agegrp == 0 & status == 1, sort connect(stepstair)) ///	 
		(line CIF_age _t if agegrp == 1 & status == 1, sort connect(stepstair)) ///	 
		(line CIF_age _t if agegrp == 2 & status == 1, sort connect(stepstair)) ///	 
		(line CIF_age _t if agegrp == 3 & status == 1, sort connect(stepstair)) ///	 
		, legend(order(1 "<45" 2 "45-59" 3 "60-74" 4 "75+") ring(0) pos(5) cols(1)) ///
		xtitle("Years since diagnosis") ///
		ytitle("CIF") ///
		title("Cancer") ///
		name(CIF_age1,replace) 

twoway	(line CIF_age _t if agegrp == 0 & status == 2, sort connect(stepstair)) ///	 
		(line CIF_age _t if agegrp == 1 & status == 2, sort connect(stepstair)) ///	 
		(line CIF_age _t if agegrp == 2 & status == 2, sort connect(stepstair)) ///	 
		(line CIF_age _t if agegrp == 3 & status == 2, sort connect(stepstair)) ///	 
		, legend(order(1 "<45" 2 "45-59" 3 "60-74" 4 "75+") ring(0) pos(11) cols(1)) ///
		xtitle("Years since diagnosis") ///
		ytitle("CIF") ///
		title("Other causes") ///
		name(CIF_age2,replace)
		
graph combine CIF_age1 CIF_age2, nocopies ycommon		
		
/* Estimate CIF by stage */
stcompet CIF_stage=ci, compet1(2) by(stage)
	 
twoway	(line CIF_stage _t if stage == 1 & status == 1, sort connect(stepstair)) ///	 
		(line CIF_stage _t if stage == 2 & status == 1, sort connect(stepstair)) ///	 
		(line CIF_stage _t if stage == 3 & status == 1, sort connect(stepstair)) ///	 
		, legend(order(1 "local" 2 "regional" 3 "distant") ring(0) pos(5) cols(1)) ///
		xtitle("Years since diagnosis") ///
		ytitle("CIF") ///
		title("Cancer") ///
		name(CIF_stage1,replace) 

twoway	(line CIF_stage _t if stage == 1 & status == 2, sort connect(stepstair)) ///	 
		(line CIF_stage _t if stage == 2 & status == 2, sort connect(stepstair)) ///	 
		(line CIF_stage _t if stage == 3 & status == 2, sort connect(stepstair)) ///	 
		, legend(order(1 "local" 2 "regional" 3 "distant") ring(0) pos(1) cols(1)) ///
		xtitle("Years since diagnosis") ///
		ytitle("CIF") ///
		title("Other causes") ///
		name(CIF_stage2,replace) 	

graph combine CIF_stage1 CIF_stage2, nocopies ycommon		

/* Fit a competing risks model using Fine and Gray's method */
stset surv_mm, failure(status==1) scale(12) exit(time 120.5)
stcrreg i.sex, compete(status == 2)	
stpepemori sex, compet(2)

/* Plot the associated cancer-specific cumulative incidence functions */
predict cif_males, basecif
gen cif_females = 1 - (1-cif_males)^exp(_b[2.sex])

graph twoway line cif_males cif_females _t, ///
	sort connect(step step) yscale(range(0 0.6)) ylabel(0(0.2)0.6) ///
	legend(order(1 "Males" 2 "Females")) ytitle(Cause-specific cumulative incidence) xtitle(Time since diagnosis (years)) ///
	title(First principles) name(cif_sex, replace) 

stcurve, cif at1(sex = 1) at2(sex=2) title(Stcurve) name(cif_sex2, replace)

graph combine cif_sex cif_sex2, ycommon 

/* Fit a competing risks model and plot the CIFs for deaths due to other causes than cancer */
stset surv_mm, failure(status==2) scale(12) exit(time 120.5)
stcrreg i.sex, compete(status == 1)
stcurve, cif at1(sex = 1) at2(sex=2) title(Other causes) legend(order(1 "Males" 2 "Females"))

/* Fit a competing risks model using the flexible parametric approach */

/* Expand data */
expand 2

/* Recode and set up data for competing risk analysis */
bysort id: gen cause=_n		// cause =1 for cause 1, cause =2 for cause 2

gen cancer=(cause==1)		// cancer is a dummy for cause 1
gen other=(cause==2)		// other is a dummy for cause 2

/*
Event is the event indicator, coded like this:
For the first row (death due to cancer): event is 1 if person died from cancer
For the second row (death due to other): event is 1 if person died from other
*/

gen event=(cause==status)  // status=1 death due to cancer, =2 death due to other

/* Look at the created data */
list id status cause sex event in 1/8, sepby(id)

/* Fit flexible parametric model for both causes simultaneously */
/* constant effect of sex */

/* stset using new event indicator */
stset surv_mm, failure(event) scale(12) exit(time 120.5)

/* Fit the stpm2 model assuming the effect of sex is the same for both cancer and other causes */
stpm2 cancer other female, scale(hazard) rcsbaseoff dftvc(4) nocons tvc(cancer other) eform nolog

/* No different effect of sex */
gen fem_can = female*cancer
gen fem_other = female*other
stpm2 cancer other fem_can fem_other, scale(hazard) rcsbaseoff dftvc(4) nocons tvc(cancer other) eform nolog
test fem_can = fem_other	  
	  
  
/* Predict CIFs for males and females */
stpm2cif cancermale othermale, cause1(cancer 1) cause2(other 1) 
stpm2cif cancerfemale otherfemale, cause1(cancer 1 fem_can 1) cause2(other 1 fem_other 1) 
   
/* Plot CIF's for cancer and other causes for males and females */
/* It is important that we use the _newt variable (which is outputted from stpm2cif), and not _t variable from stset. */
twoway (line CIF_cancermale _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_othermale _newt, sort lcolor(red) lpattern(solid)) /// 
	   (line CIF_sex_cancer _t if female==0, sort lcolor(navy) lpattern(dash)) ///
	   (line CIF_sex_other _t if female==0, sort lcolor(red) lpattern(dash)) ///
	   ,ytitle("Probability of Death") title("Males") ///
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "Cancer" 2 "Other")) ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(malesfpm, replace)
	   
twoway (line CIF_cancerfemale _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_otherfemale _newt, sort lcolor(red) lpattern(dash)) ///
	   (line CIF_sex_cancer _t if female==1, sort lcolor(navy) lpattern(dash)) ///
	   (line CIF_sex_other _t if female==1, sort lcolor(red) lpattern(dash)) ///
	   ,ytitle("Probability of Death") title("Females") ///
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "Cancer" 2 "Other")) ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(femalesfpm, replace)

graph combine malesfpm femalesfpm, ycommon xcommon name(FPM, replace)

/* Stack the cumulative incidence functions and plot again */
gen male_total1=CIF_cancermale
gen male_total2=male_total1 + CIF_othermale

gen female_total1=CIF_cancerfemale
gen female_total2=female_total1 + CIF_otherfemale

twoway (area male_total2 _newt, sort fintensity(100)) ///
	   (area male_total1 _newt, sort fintensity(100)), ///
	    ylabel(0(0.2)1, angle(0) format(%3.1f)) ///
		ytitle("Probability of Death") xtitle("Time Since Diagnosis (Years)") ///
		legend(order(2 "Cancer" 1 "Other") size(small)) ///
        title("Males") plotregion(margin(zero)) name(malestack, replace)
		
twoway (area female_total2 _newt, sort fintensity(100)) ///
	   (area female_total1 _newt, sort fintensity(100)), ///
	    ylabel(0(0.2)1, angle(0) format(%3.1f)) ///
		ytitle("Probability of Death") xtitle("Time Since Diagnosis (Years)")  ///
		legend(order(2 "Cancer" 1 "Other") size(small)) ///
        title("Female") plotregion(margin(zero)) name(femalestack, replace)

graph combine malestack femalestack, ycommon xcommon name(FPM, replace)

/* Categorize age and create interactions with cause */
forvalues i = 0/3 {
	gen age`i'can=(agegrp==`i' & cancer==1) 
	gen age`i'oth=(agegrp==`i' & other==1) 
}

stpm2 cancer other fem_can fem_oth age1can age2can age3can age1oth age2oth age3oth ///
	, scale(hazard) rcsbaseoff dftvc(3) nocons tvc(cancer other) eform nolog   
		 
/* Predict CIFs */
stpm2cif cancermale_age0 othermale_age0, cause1(cancer 1) cause2(other 1) 
stpm2cif cancermale_age3 othermale_age3, cause1(cancer 1 age3can 1) cause2(other 1 age3oth 1) 

twoway (line CIF_cancermale_age0 _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_cancermale_age3 _newt, sort lcolor(red) lpattern(solid)) /// 
	   ,ytitle("Probability of Death") /// 
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Cancer") ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(malesfpm_age0, replace)

twoway (line CIF_othermale_age0 _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_othermale_age3 _newt, sort lcolor(red) lpattern(solid)) /// 
	   ,ytitle("Probability of Death") title("Males") ///
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Other Causes") ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(malesfpm_age3, replace)
	   
graph combine malesfpm_age0 malesfpm_age3, nocopies ycommon
	   
/* Allow for time-dependent effects for cancer */
stpm2 cancer other fem_can fem_oth age1can age2can age3can age1oth age2oth age3oth ///
	, scale(hazard) rcsbaseoff dftvc(cancer:4 other:4 3) nocons ///
	tvc(cancer other fem_can age1can age2can age3can) eform nolog  
	
stpm2cif cancermale_age0_tvc othermale_age0_tvc, cause1(cancer 1) cause2(other 1) 
stpm2cif cancermale_age3_tvc othermale_age3_tvc, cause1(cancer 1 age3can 1) cause2(other 1 age3oth 1)  

twoway (line CIF_cancermale_age0 _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_cancermale_age3 _newt, sort lcolor(red) lpattern(solid)) /// 
	   (line CIF_cancermale_age0_tvc _newt, sort lcolor(navy) lpattern(dash)) ///
       (line CIF_cancermale_age3_tvc _newt, sort lcolor(red) lpattern(dash)) /// 
	   ,ytitle("Probability of Death") /// 
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Cancer") ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(malesfpm_can_tvc, replace)

twoway (line CIF_othermale_age0 _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_othermale_age3 _newt, sort lcolor(red) lpattern(solid)) /// 
	   (line CIF_othermale_age0_tvc _newt, sort lcolor(navy) lpattern(dash)) ///
       (line CIF_othermale_age3_tvc _newt, sort lcolor(red) lpattern(dash)) /// 
	   ,ytitle("Probability of Death") title("Males") ///
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Other Causes") ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(malesfpm_oth_tvc, replace)
	   
graph combine malesfpm_can_tvc malesfpm_oth_tvc, nocopies ycommon
 
/* Separate knot placements */

/* Distribution of events */
hist _t if _d==1, by(status)

/* Separate models */
stpm2 fem_can age1can age2can age3can if cancer == 1, ///
	df(4) scale(hazard) dftvc(3) tvc(fem_can age1can age2can age3can) eform nolog   
global knots_cancer `e(bhknots)'
global knots_cancer_tvc `e(tvcknots_age1can)'

stpm2 fem_oth age1oth age2oth age3oth if other == 1, ///
	df(4) scale(hazard) eform nolog   
global knots_other `e(bhknots)'

/* Re-fit model using these knot locations */
stpm2 cancer other fem_can fem_oth age1can age2can age3can age1oth age2oth age3oth ///
	, scale(hazard) rcsbaseoff nocons ///
	tvc(cancer other fem_can age1can age2can age3can) eform nolog ///
	knotstvc(cancer $knots_cancer other $knots_other ///
	fem_can $knots_cancer_tvc ///
	age1can $knots_cancer_tvc ///
	age2can $knots_cancer_tvc ///
	age3can $knots_cancer_tvc)
	
stpm2cif cancermale_age0_tvc2 othermale_age0_tvc2, cause1(cancer 1) cause2(other 1) 
stpm2cif cancermale_age3_tvc2 othermale_age3_tvc2, cause1(cancer 1 age3can 1) cause2(other 1 age3oth 1)  
	
twoway (line CIF_cancermale_age0_tvc _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_cancermale_age3_tvc _newt, sort lcolor(red) lpattern(solid)) /// 
	   (line CIF_cancermale_age0_tvc2 _newt, sort lcolor(navy) lpattern(dash)) ///
       (line CIF_cancermale_age3_tvc2 _newt, sort lcolor(red) lpattern(dash)) /// 	   
	   ,ytitle("Probability of Death") /// 
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Cancer") ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(malesfpm_can_tvc2, replace)

twoway (line CIF_othermale_age0_tvc _newt, sort lcolor(navy) lpattern(solid)) ///
       (line CIF_othermale_age3_tvc _newt, sort lcolor(red) lpattern(solid)) /// 
	   (line CIF_othermale_age0_tvc2 _newt, sort lcolor(navy) lpattern(dash)) ///
       (line CIF_othermale_age3_tvc2 _newt, sort lcolor(red) lpattern(dash)) /// 	   
	   ,ytitle("Probability of Death") /// 
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "<45" 2 "75+")) ///
	   title("Other Causes") ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f)) name(malesfpm_oth_tvc2, replace)
	  
graph combine malesfpm_can_tvc2 malesfpm_oth_tvc2, nocopies ycommon

/* Now, estimate CIFs from a Cox model instead - Assume that the effect of sex is the same on both outcomes */
use colon, clear
drop if stage ==0
gen female = sex==2
 
/* Stset the data, specify that death from cancer is the outcome of interest */
stset surv_mm, failure(status==1) scale(12) exit(time 120.5)

stcompadj sex=1 , compet(2) gen(Main_males Compet_males)
stcompadj sex=2 , compet(2) gen(Main_females Compet_females)

graph twoway line Main_males Compet_males _t, ///
	sort connect(step step) yscale(range(0 1)) ylabel(0(0.2)1) ///
	ytitle(Probability of Death) xtitle(Time Since Diagnosis (Years)) ///
	title(Males) ///
	legend(order(1 "Cancer" 2 "Other")) ///
	name(Cox_males, replace)
	
graph twoway line Main_females Compet_females _t, ///
	sort connect(step step) yscale(range(0 1)) ylabel(0(0.2)1) ///
	ytitle(Probability of Death) xtitle(Time Since Diagnosis (Years)) ///
	title(Females) ///
	legend(order(1 "Cancer" 2 "Other")) ///
	name(Cox_females, replace)
	
graph combine Cox_males Cox_females, ycommon

// Relax the assumption that the effect of sex is the same on the two outcomes */
stcompadj sex=1 , compet(2) maineffect(sex) competeffect(sex) gen(Main_males_2 Compet_males_2)
stcompadj sex=2 , compet(2) maineffect(sex) competeffect(sex) gen(Main_females_2 Compet_females_2)

graph twoway (line Main_males Compet_males _t, lpattern(dash dash) lcolor(navy red) sort connect(step step)) ///
	(line Main_males_2 Compet_males_2 _t, lpattern(solid solid) lcolor(navy red) sort connect(step step)), ///
	 yscale(range(0 0.6)) ylabel(0(0.2)0.6) ///
	ytitle(Probability of Death) xtitle(Time Since Diagnosis (Years)) ///
	title(Males) ///
	legend(order(3 "Cancer" 4 "Other")) ///
	name(Cox_males_2, replace)
	
graph twoway (line Main_females Compet_females _t, lpattern(dash dash) lcolor(navy red) sort connect(step step)) ///
	(line Main_females_2 Compet_females_2 _t, lpattern(solid solid) lcolor(navy red) sort connect(step step)), ///
	 yscale(range(0 0.6)) ylabel(0(0.2)0.6) ///
	ytitle(Probability of Death) xtitle(Time Since Diagnosis (Years)) ///
	title(Females) ///
	legend(order(3 "Cancer" 4 "Other")) ///
	name(Cox_females_2, replace)

graph combine Cox_males_2 Cox_females_2, ycommon

/* Test if the effect of sex differs between cancer and other causes */
preserve
stcompadj sex=1 , compet(2) savexp(silong,replace)
use silong,clear
xi:stcox i.sex*i.stratum, strata(stratum) nohr nolog
restore

/* View the estimates from the Cox regression */
preserve
stcompadj sex=1 , compet(2) maineffect(sex) competeffect(sex) savexp(silong,replace)
use silong,clear
xi: stcox Main_sex Compet_sex stratum,  nolog
restore





