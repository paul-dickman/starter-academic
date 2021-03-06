
//==================//
// EXERCISE 281
// REVISED MAY 2015
//==================//

use colon, clear

/* We need a variable for date of birth */
	gen dob=dx-age*365.25
	format dob %d

/* stset using attained age as the timescale */
	stset exit, fail(status==2) enter(dx) origin(dob) scale(365.25) id(idnr)

/* graph the age-specific hazards for each sex */
	sts graph if _t < 100, haz by(sex) name(observed, replace) kernel(epan2) ///
	xscale(range(40 100)) xlabel(40(5)100) ///
	yscale(range(0 1.5)) ylabel(0(0.5)1.5)
	
/* Tabulate age-specific mortality rates */
	preserve
	stsplit attage, at(0(1)110)
	strate sex attage
	restore
	
/*Model the age-specific hazards for each sex. First using a proportional hazards model.*/
	stpm2 sex, df(5) scale(hazard)

/* Predict the hazards and plot by sex*/	
	predict h, haz
	
	twoway (line h _t if sex==1 & _t>40,sort) ///
		(line h _t if sex==2 & _t>40, sort), ///
		name(fitted, replace) title("Fitted values from fpm (prop hazards)") ///
		xscale(range(40 100)) xlabel(40(5)100) ///
		yscale(range(0 1.5)) ylabel(0(0.5)1.5) 

/* Plot the empirical and fitted hazards (FPM PH model) together */	
	sts graph if _t < 100, haz by(sex) kernel(epan2) name(overlay1, replace) ///
		xscale(range(40 100)) xlabel(40(5)100) ///
		title("Empirical and fitted hazards (fpm PH)") ///
		addplot(line h _t if sex==1 & _t>40,sort || ///
		line h _t if sex==2 & _t>40, sort)

/* Same plot but on the log scale */
	sts graph if _t < 100, haz by(sex) kernel(epan2) name(overlay2, replace) ///
		xscale(range(40 100)) xlabel(40(5)100) ///
		title("Empirical and fitted hazards (fpm PH)") ///
		yscale(log) ylabel(0 0.01 0.1 0.5 1.5) ///
		addplot(line h _t if sex==1 & _t>40,sort || ///
		line h _t if sex==2 & _t>40, sort)
		
/*Now allow non-proportional hazards*/
	stpm2 sex, df(5) scale(hazard) tvc(sex) dftvc(3)

/* Predict the hazards and plot by sex*/		
	predict h2, haz

	sts graph if _t < 100, haz by(sex) kernel(epan2) name(overlay1_tvc, replace) ///
		xscale(range(40 100)) xlabel(40(5)100) ///
		title("Empirical and fitted hazards (fpm tvc)") ///
		addplot(line h2 _t if sex==1 & _t>40,sort || ///
		line h2 _t if sex==2 & _t>40, sort)

	sts graph if _t < 100, haz by(sex) kernel(epan2) name(overlay2_tvc, replace) ///
		xscale(range(40 100)) xlabel(40(5)100) ///
		title("Empirical and fitted hazards (fpm tvc)") ///
		yscale(log) ylabel(0 0.01 0.1 0.5 1.5) ///
		addplot(line h2 _t if sex==1 & _t>40,sort || ///
		line h2 _t if sex==2 & _t>40, sort)
		
		
/*Create a table of predicted rates and probabilities. These figures could be used as the
popmort file for relative survival analysis. For a real-life example we would also stratify
by calendar year and race (if applicable). Could also model rates as a function of social
class or ethnicity. To estimate rates for a small population one could include data for a
larger population to get the shape correct.*/
	
/*One row for each age 40-100 (61 observations)*/
	range attage 40 100 61
	drop if attage==.

/* Use non PH model to predict hazards for these ages (both sexes)*/
	predict rate_m, hazard at(sex 1) timevar(attage)
	predict rate_f, hazard at(sex 2) timevar(attage)

/* Generate survival probabilities*/	
	gen prob_m=exp(-rate_m)
	gen prob_f=exp(-rate_f)
	
/* View the hazards and survival probs*/	
	format rate_m rate_f prob_m prob_f %8.5f
	keep attage prob_m prob_f rate_m rate_f
	list
