***********************************************************************************************
* Question 21 - Analysing the SEER data
***********************************************************************************************


set more off
clear

***********************************************************************************************
* (a) Exploring the general population mortality data
***********************************************************************************************
use popmort_usa, clear

list if sex==2 & race==1 & _year==2000 & _age==110 

list if sex==2 & race==1 & _year==2000 & _age >=97 

// The probability Mary lives to celebrate her 98th birthday is 0.741591

display .741591*.720153*.697662

// The probability Mary lives to celebrate her 100th birthday is 0.373

// prob=exp(-rate)

* plot the age-specific rates by sex
use popmort_usa, clear
keep if race==1 & _year==2000 & _age < 100
twoway (line rate _age if sex==1, sort) ///
       (line rate _age if sex==2, sort), ///
	   yscale(log) ylabel(0.001 0.01 0.1 0.4) ///
	   legend(order(1 "Male" 2 "Female") ring(0)) ///
	   name(rates_by_sex,replace)

* plot the age-specific rates by race
use popmort_usa, clear
keep if sex==1 & _year==2000 & _age < 100
twoway (line rate _age if race==1, sort) ///
       (line rate _age if race==2, sort) ///
       (line rate _age if race==3, sort) ///
       (line rate _age if race==4, sort), ///
	   yscale(log) ylabel(0.001 0.01 0.1 0.4) ///
	   legend(order(1 "White" 2 "Black" 3 "American Indian ..." 4 "Other/Unknown") pos(11) ring(0)) ///
	   name(rates_by_race,replace)
	   
***********************************************************************************************
* (b) Exploring the patient data 
***********************************************************************************************
use colon_SEER, clear
describe
notes
codebook status
codebook status2
tab seer_reg
tab agegrp sex, row

***********************************************************************************************
* (c) Kaplan-Meier estimation of cause-specific survival
***********************************************************************************************
use colon_SEER, clear
stset surv_mm, failure(status==1) scale(12)
sts graph, by(agegrp)

sts graph, by(stage) hazard kernel(epan2)	
***********************************************************************************************
* (d) Model cause-specific survival using Cox regression
***********************************************************************************************
use colon_SEER, clear
stset surv_mm, failure(status==1) scale(12)
stcox i.sex i.agegrp i.stage 

***********************************************************************************************
* (e) Life table estimation of relative survival (cohort approach, Ederer II method)
***********************************************************************************************
use colon_SEER, clear
stset surv_mm, failure(status==1,2) id(id) scale(12)
strs using popmort_usa, br(0(1)10) mergeby(_year sex _age race) ///
   by(sex) maxage(118)

strs using popmort_usa, br(0(1)10) mergeby(_year sex _age race) ///
   by(agegrp) maxage(118) save(replace)
use grouped, clear
twoway (connected cr_e2 end if agegrp==1) /// 
       (connected cr_e2 end if agegrp==2) ///
       (connected cr_e2 end if agegrp==3) ///
       (connected cr_e2 end if agegrp==4) ///
       (connected cr_e2 end if agegrp==5)	
	   
use grouped, clear
twoway (rcap lo_cr hi_cr end) (scatter cr end), ///
by(agegrp, legend(off)) yti("Relative Survival") ///
xti("Years from diagnosis") xla(0(2)10) yla(0.4(.1)1, format(%3.1f))

twoway (connected cr end if agegrp==1, msymbol(O))  ///
       (connected cr end if agegrp==2, msymbol(O)) ///
       (connected cr end if agegrp==3, msymbol(O)) ///
       (connected cr end if agegrp==4, msymbol(O)) ///
       (connected cr end if agegrp==5, msymbol(O)) ///
(rcap lo_cr hi_cr end if agegrp==1, lcolor(black)) ///
(rcap lo_cr hi_cr end if agegrp==2, lcolor(black)) ///
(rcap lo_cr hi_cr end if agegrp==3, lcolor(black)) ///
(rcap lo_cr hi_cr end if agegrp==4, lcolor(black)) ///
(rcap lo_cr hi_cr end if agegrp==5, lcolor(black)), ///
yti("Relative Survival") yscale(range(0.4 1)) ///
ylabel(0.4(0.2)1, format(%3.1f)) ///
xti("Years from diagnosis") xla(0(2)10) ///
legend(order(1 "<50" 2 "50-59" 3 "60-69" 4 "70-79" 5 "80+") ///
 ring(0) pos(1) col(1))

***********************************************************************************************
* (f) Comparing relative survival, cause-specific survival (standard)
*     and cause-specific survival (Howlader extended)
***********************************************************************************************
use colon_SEER if sequence <=1, clear
tab status status2

* cause-specific survival (standard definition)
stset surv_mm, failure(status==1) id(id) scale(12)
strs using popmort_usa, br(0(1)20) mergeby(_year sex _age race) ///
     by(sex) maxage(118) notables savgroup(standard,replace)

* cause-specific survival (extended definition)
stset surv_mm, failure(status2==1) id(id) scale(12)
strs using popmort_usa, br(0(1)20) mergeby(_year sex _age race) ///
     by(sex) maxage(118) notables savgroup(extended,replace)
	   
* relative survival
use colon_SEER, clear
stset surv_mm, failure(status==1,2) id(id) scale(12)
strs using popmort_usa, br(0(1)20) mergeby(_year sex _age race) ///
     by(sex) maxage(118) notables savgroup(relative,replace)

* now merge the 3 results files	 
use sex end cp using standard, clear
rename cp standard
save results, replace

use sex end cp using extended, clear
rename cp extended
merge 1:1 sex end using results, nogenerate
save results, replace

use sex end cr_e2 using relative, clear
rename cr_e2 relative
merge 1:1 sex end using results, nogenerate
save results, replace

list sex end standard extended relative, sepby(sex)
	   
***********************************************************************************************
* (g) Life table estimation of relative survival (period approach, Ederer II method)
***********************************************************************************************
use colon_SEER, clear
stset exit, enter(time mdy(1,1,2006)) exit(time mdy(12,31,2007)) ///
   origin(dx) f(status==1 2) id(id) scale(365.24)

strs using popmort_usa, br(0(1)10) mergeby(_year sex _age race) ///
   by(sex) maxage(118)
	   
	   
***********************************************************************************************
* (h) Modelling relative survival (excess mortality) using Poisson regression
***********************************************************************************************
use colon_SEER, clear
stset surv_mm, failure(status==1,2) id(id) scale(12)

* life table estimates of relative survival
strs using popmort_usa, br(0(1)10) mergeby(_year sex _age race) ///
 by(sex agegrp stage) maxage(118) notable save(replace)

* model excess mortality using Poisson regression
use grouped, clear
glm d i.end i.sex i.agegrp i.stage, ///
   fam(pois) link(rs d_star) lnoff(y) eform 
estimates store ehr_pois

* non-proportional hazards for stage
glm d i.sex i.agegrp i.end#i.stage, ///
   fam(pois) link(rs d_star) lnoff(y) eform 
lrtest ehr_pois

* now a Cox model for cause-specific survival (extended)
use colon_SEER if sequence <=1, clear
stset surv_mm, failure(status2==1) id(id) scale(12) exit(time 120)
stcox i.sex i.agegrp i.stage 
estimates store cshr_cox

* model excess mortality using flexible parametric model
stset surv_mm, failure(status2==1,2) id(id) scale(12) exit(time 120)
stpm2 i.sex i.agegrp i.stage, ///
   df(5) scale(hazard) bhazard(rate) eform
estimates store ehr_fpm

* compare the estimates
est table ehr_pois ehr_fpm cshr_cox, eform equations(1)
   
***********************************************************************************************
* (i) Modelling relative survival (excess mortality) using flexible parametric models
***********************************************************************************************
use colon_SEER if seer_reg==1, clear // restrict to Atlanta
stset surv_mm, failure(status==1,2) id(id) scale(12) exit(time 120)

stpm2, df(5) scale(hazard) bhazard(rate)
predict h1, hazard per (1000) ci
predict s1, survival ci

twoway  (rarea h1_lci h1_uci _t, sort pstyle(ci)) ///
        (line h1 _t, sort), name(h1,replace)
twoway  (rarea s1_lci s1_uci _t, sort pstyle(ci)) ///
        (line s1 _t, sort), name(s1,replace)
		
* proportional hazards model comparable to those fitted in previous parts
use colon_SEER, clear
stset surv_mm, failure(status==1,2) id(id) scale(12) exit(time 120)

stpm2 i.sex i.agegrp i.stage, df(5) scale(hazard) ///
    bhazard(rate) eform
estimates store ehr_fpm
  
/* predictions for youngest and oldest (at reference levels of other covariates) */
range timevar 0 10 1000   
predict h2_age1, hazard per(1000) timevar(timevar) zeros ci
predict h2_age5, hazard per(1000) timevar(timevar) at(agegrp 5)  zeros ci

twoway	(line h2_age1 timevar, sort) ///
		(line h2_age5 timevar, sort), ///
		name(stpm2_haz_ph,replace)
		
* allow non-proportional effects for agegrp	
tab agegrp, gen(agegrp)
stpm2 i.sex agegrp2-agegrp5 i.stage, df(5) scale(hazard) ///
   bhazard(rate) eform tvc(agegrp2-agegrp5) dftvc(3) 

/* use timevar option to speed up prediction and plotting */
predict h3_age1, hazard per(1000) timevar(timevar) zeros ci 
predict h3_age5, hazard per(1000) timevar(timevar) at(agegrp5 1) zeros ci
twoway	(line h3_age1 timevar, sort) ///
		(line h3_age5 timevar, sort), ///
		name(stpm2_haz_tvc,replace) 
		
/* predict hazard ratio */
predict	hr_age5, hrnum(agegrp5 1) timevar(timevar) ci	

twoway	(rarea hr_age5_lci hr_age5_uci timevar, sort pstyle(ci)) ///
		(line hr_age5 timevar, sort) ///
		, yscale(log) yline(1)
   
***********************************************************************************************
* (j) Cure models
***********************************************************************************************
use colon_SEER if seer_reg==9, clear // restrict to Detroit
stset surv_mm, failure(status==1,2) id(id) scale(12) exit(time 12*20)

/* Life tables by age group */
strs using popmort_usa, br(0(1)20) mergeby(_year sex _age race) ///
   by(agegrp) maxage(118) savgroup(seer_utah_grp,replace)

/* merge in life tables */   
preserve
use seer_utah_grp,  clear
rename agegrp agegrp_cr
keep cr_e2 end agegrp_cr
save seer_utah_grp, replace
restore
merge using seer_utah_grp

/* Life table estiamtes */
line cr_e2 end, by(agegrp_cr)

/* drop oldest age group */
drop if agegrp == 5

/* Fit a cure model with no covariates */
strsmix if agegrp == 4, link(identity) dist(weibull) bhazard(rate)
	
/* predict survival and compare to lifetable */
predict s_all, survival
predict s_unc, survival  uncured
local cure = _b[_cons]
twoway	(line s_all s_unc _t, sort) ///
	(scatter cr_e2 end if agegrp_cr==4, sort), yline(`cure') 

/* create dummy variables for age group and add to model */
tab agegrp, gen(agegrp)
strsmix agegrp2 agegrp3 agegrp4, link(identity) dist(weibull) bhazard(rate) 

/* predictions */
predict cure1, cure
predict s_unc1, survival uncured
predict median1, centile

bysort agegrp: gen first = _n == 1
tabdisp agegrp if first, c(cure1 median1) f(%5.3fc)

/* survival of uncured */
twoway	(line s_unc1 _t, sort)

/* Now model lambda parameter of Weibull distribution as well as cure */
strsmix agegrp2 agegrp3 agegrp4 , link(identity) dist(weibull) bhazard(rate) ///
			k1(agegrp2 agegrp3 agegrp4)

/* predictions */
predict cure2, cure
predict s_unc2, survival uncured
predict median2, centile
tabdisp agegrp if first, c(cure2 median2) f(%5.3fc)
							
								


***********************************************************************************************
* (k) Estimating probabilities of death in the presence of competing risks
***********************************************************************************************
use colon_SEER, clear
stset surv_mm, failure(status==1,2) id(id) scale(12)
strs using popmort_usa, br(0(1)10) mergeby(_year sex _age race) ///
   by(sex) maxage(118) cuminc

use colon_SEER if sequence <=1, clear
stset surv_mm, failure(status2==1) id(id) scale(12)

* estimate the CIF
stcompet CIF=ci, by(sex) compet1(2)
gen CIFcancer=CIF if status2==1  
gen CIFother=CIF if status2==2
   
* plot the CIFs for makes   
twoway (line CIFcancer _t, sort lpattern(solid)) ///
	   (line CIFother _t, sort lpattern(dash)) if sex==1, ///
       ytitle("Probability of Death") ///
	   xtitle("Time Since Diagnosis (Years)") ///
	   legend(order(1 "Cancer CIF" 2 "Other CIF")) ///
	   ylabel(0(0.1)0.5, angle(0) format(%3.1f))   
	     

