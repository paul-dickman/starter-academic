
//==================//
// EXERCISE 201
// REVISED MAY 2015
//==================//

/* Data set used  (localised melanoma) */
use melanoma if stage==1 , clear

stset surv_mm, fail(status==1 2) id(id) scale(12)

/* Lifetable estimates, annual intervals */
strs using popmort, br(0(1)10) mergeby(_year sex _age) ///
   by(year8594) save(replace)

/******************************************************************************
 (a) 
*******************************************************************************/


/******************************************************************************
 (b) Lifetable estimates, 6 month intervals
*******************************************************************************/
strs using popmort, br(0(0.5)10) mergeby(_year sex _age) by(year8594) save(replace)

/******************************************************************************
 (c) Lifetable estimates, 3 month intervals for first year then annual
*******************************************************************************/
strs using popmort, br(0 0.25 0.5 0.75 1(1)10) mergeby(_year sex _age) by(year8594) save(replace)

/******************************************************************************
 (d) Lifetable estimates, annual intervals up to 20 years
*******************************************************************************/
strs using popmort, br(0(1)20) mergeby(_year sex _age) by(year8594) save(replace)

/******************************************************************************
 (e) Plot estimates of cumulative relative survival
*******************************************************************************/
use grouped, clear

/* Plot estimates of cumulative relative survival */
twoway 	(connected cr end if year8594==0, lpattern(solid) color(black)) ///
		(connected cr end if year8594==1, lpattern(-) color(black)), ///
		legend(order(1 "Diagnosed 1975-84" 2 "Diagnosed 1985-94")) name(rsr_by_period1,replace)

/* Alternative approach for producing a graph of estimates */
twoway (rcap lo_cr hi_cr end) (scatter cr end), ///
by(year8594, legend(off)) yti("Relative Survival") ///
xti("Years from diagnosis") xla(0(2)20) yla(0.6(.1)1) name(rsr_by_period2,replace)

/* Alternative approach for producing a graph of estimates */
twoway (scatter cr end if year8594==0, msymbol(O))  /// 
       (scatter cr end if year8594==1, msymbol(O)) ///
(rcap lo_cr hi_cr end if year8594==0, lcolor(black)) ///
(rcap lo_cr hi_cr end if year8594==1, lcolor(black)) , ///
yti("Relative Survival") yscale(range(0.4 1)) ///
ylabel(0.4(0.2)1, format(%3.1f)) ///
xti("Years from diagnosis") xla(0(2)20) ///
legend(order(1 "1975-84" 2 "1985-94") ring(0) pos(7) col(1)) name(rsr_by_period3,replace)
				
/******************************************************************************
 (f) Plot estimates of interval-specific relative survival
*******************************************************************************/
twoway 	(connected r end if year8594==0, lpattern(solid) color(black)) ///
		(connected r end if year8594==1, lpattern(-) color(black)), ///
		legend(order(1 "Diagnosed 1975-84" 2 "Diagnosed 1985-94")) name(conditional_rsr_by_period,replace)

/******************************************************************************
 (g) Comparing 3 approaches to estimating expected (and relative) survival
*******************************************************************************/
use melanoma if stage==1, clear
stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)

/* Type "help strs" for more info on syntax */
gen long potfu = date("31/12/1995","DMY")

strs using popmort if stage==1, ///
	br(0(1)20) ///
	mergeby(_year sex _age) ///
	by(year8594) ///
	list(start n d w cr_e1 cr_e2 cr_hak) ///
	ederer1 ///
	potfu(potfu)

/******************************************************************************
 (i) Pohar Perme estimator
*******************************************************************************/
use melanoma if stage==1, clear
stset surv_mm, fail(status==1 2) id(id) scale(12)
strs using popmort, br(0(1)20) mergeby(_year sex _age) ///
  by(year8594) pohar list(start n d w cr_e2 cns_pp)

/******************************************************************************
 (i) Estimating rates
*******************************************************************************/
use melanoma if stage==1 , clear
stset surv_mm, fail(status==1 2) id(id) scale(12)
/* Lifetable estimates, 1 year intervals */
strs using popmort if stage==1, ///
   br(0(1)10) mergeby(_year sex _age) save(replace)

/* Use the data saved in the strs command */
use grouped, clear

/* Estimate the observed mortality rate */
// first use an approximation to person-time at risk
gen obs_rate1 = d / (n-d/2-w/2)

// now using exact person-time
gen obs_rate2 = d / y

// now estimate the rate by transforming the estimated survival probability
gen obs_rate3 = -ln(p)

// now the probability of death (which is not strictly a rate)
gen q=1-p

format obs_rate1 obs_rate2 obs_rate3 q %6.4f
list end d y obs_rate1 obs_rate2 obs_rate3 q

/* Estimate the expected mortality rate */
gen exp_rate = d_star/y

/* Estimate the excess mortality rate */
gen excess_rate = (d-d_star)/y
list end d d_star y obs_rate2 exp_rate excess_rate

/* Plot excess mortality rate as a function of time since diagnosis*/
graph twoway (line excess_rate end, sort) 	///
		, scheme(sj)						///
		name(exmort_by_diagnosis)			///
		xtitle("Time since diagnosis")		///
		ytitle("Excess rate")


/*Individual data*/
use individ, clear
collapse (mean) age _age, by(end)
list

/***********
END OF FILE
***********/



