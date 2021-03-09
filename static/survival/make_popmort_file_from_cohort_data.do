/************************************************************************
MAKE_POPMORT_FILE_FROM_COHORT_DATA.DO

This code illustrates how one can create a 'popmort' file of general 
population mortality rates if one has data on a cohort from that population.
We use data on cancer patients here (because such data are available to us) 
and use non-cancer mortality as the outcome, but if one applied the 
same approach to a cohort of from the general population and used any 
death as the outcome then a 'popmort file' could be created.

The approach is to model mortality using attained age as the timescale.
Once we have fitted an appropriate model then we save the predicted values
(i.e., mnortality rates) for each combination of covariates. In this
example we only nmodel by age and sex, but in a realistic application 
one would also want to model by year of diagnosis.

Since population mortality rates stratified by age, sex, and year are 
available (e.g., from mortality.org) for many countries, the primary 
application for this approach is to create popmort files stratified by
additional variables (e.g., region, race). 

We use flexible parametric models (the -stpm2- command must be installed)
so as to get a parametric estimate of the baseline hazard (i.e, the mortality 
rates that are of primary interest to us) that is smooth and flexible.

For a realistic application (tabulating rates by age, sex, year, and race)
attention must be given to:
1 modelling appropriate interaction terms
2 modelling non-proportional hazards
3 the degree of smoothing 

Created: June 2012
Updated: October 2013 (improved description and comments) 
 
Paul Dickman (paul.dickman@ki.se)
*************************************************************************/

clear all
set more off
set autotabgraphs on

use colon, clear

/* We need a variable for date of birth */
gen dob=dx-age*365.25
format dob %d

/* We need an ID number */
gen idnr=_n

/* stset using attained age as the timescale */
stset exit, fail(status==2) enter(dx) origin(dob) scale(365.25) id(idnr)

/* graph the age-specific hazards for each sex */
sts graph if _t < 100, haz by(sex) name(observed, replace) kernel(epan2) ///
		 xscale(range(40 100)) xlabel(40(5)100) ///
		 title("Smoothed empirical age-specific mortality rates") ///
		 subtitle("These are the rates we want, but we will fit a model so as to smooth them") ///
		 yscale(range(0 1.5)) ylabel(0(0.5)1.5) 

/************************************************************************************************* 
Tabulate age-specific mortality rates. Note that this step is not required for future modelling. 
The code is provided to illustrate how easily one can tabulate the empirical mortality rates. 
One could, theoretically, save these estimates to a file and use it as the popmort file.
*************************************************************************************************/ 
preserve
stsplit attage, at(0(1)110)
strate sex attage
restore

/* Model the age-specific hazards for each sex */
/* First using a proportional hazards model */
stpm2 sex, df(5) scale(hazard) 
predict h, haz

twoway (line h _t if sex==1 & _t>40,sort) ///
       (line h _t if sex==2 & _t>40, sort), ///
	    name(fitted, replace) title("Fitted values from fpm (prop hazards)") ///
		xscale(range(40 100)) xlabel(40(5)100) ///
		 yscale(range(0 1.5)) ylabel(0(0.5)1.5)  

		 
sts graph if _t < 100, haz by(sex) kernel(epan2) name(overlay1, replace) ///
		 xscale(range(40 100)) xlabel(40(5)100) ///
		 title("Empirical and fitted hazards (fpm PH)") ///
		 addplot(line h _t if sex==1 & _t>40,sort || ///
		 line h _t if sex==2 & _t>40, sort)
		 
		 
sts graph if _t < 100, haz by(sex) kernel(epan2) name(overlay2, replace) ///
		 xscale(range(40 100)) xlabel(40(5)100) ///
		 title("Empirical and fitted hazards (fpm PH)") ///
		 yscale(log) ylabel(0 0.01 0.1 0.5 1.5) ///
		 addplot(line h _t if sex==1 & _t>40,sort || ///
		 line h _t if sex==2 & _t>40, sort)
	
/* Now allow non-proportional hazards */
stpm2 sex, df(5) scale(hazard) tvc(sex) dftvc(3)
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

/*********************************************************************
Create a table of predicted rates and probabilities. These figures 
could be used as the popmort file for relative survival analysis.
For a real-life example we would also stratify by calendar year
and race (if applicable). Could also model rates as a function 
of social class or ethnicity. To estimate rates for a small
population one could include data for a larger population to
get the shape correct.
**********************************************************************/
range attage 40 100 61
drop if attage==.
predict rate_m, hazard at(sex 1) timevar(attage)
predict rate_f, hazard at(sex 2) timevar(attage)
gen prob_m=exp(-rate_m)
gen prob_f=exp(-rate_f)
format rate_m rate_f prob_m prob_f %8.5f
keep attage prob_m prob_f rate_m rate_f
list
