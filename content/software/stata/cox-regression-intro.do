
/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/cox-regression-intro.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/cox-regression-intro/

Introduction to the Cox model.

Paul Dickman, March 2019
***************************************************************************/

set more off
use http://pauldickman.com/data/melanoma.dta, clear

generate male=(sex==1)

stset surv_mm, failure(status==1) exit(time 60) id(id) scale(12)noshow

stsplit fu, at(0(.08333333)5) trim
strate fu male, output(rates,replace)

preserve
use rates, clear
format _Rate _Lower _Upper %4.2f
twoway (rspike _Lower _Upper fu if male==0) (scatter _Rate fu if male==0, mcolor(dknavy) msymbol(circle_hollow)) /// 	 
	   (rspike _Lower _Upper fu if male==1) (scatter _Rate fu if male==1, mcolor(red)), ///
       title("Empirical hazards by stage") ///
	   legend(order(2 "Female" 4 "Male") ring(0) pos(1) col(1)) ///
	   ytitle(Hazard (deaths/person-year)) ///
	   yscale(range(0 0.15)) ylabel(0(0.03)0.15) xtitle("Time since diagnosis in years")
restore


/* Fit the Cox model */
stcox i.sex i.year8594 i.agegrp
estimates store Cox
 
/* Now split and fit the Poisson model */
/* Change the at option to vary the interval length */
stsplit fu, at(0(12)120) trim
streg i.fu i.sex i.year8594 i.agegrp, dist(exp)
estimates store Poisson

/* Compare the estimates */
estimates table Cox Poisson, eform equations(1) b(%9.6f) se(%9.6f) ///
keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
title("Hazard ratios and standard errors for Cox and Poisson models")

/* THIS MAY TAKE SEVERAL MINUTES TO RUN */
/* Now split very finely (one interval for each failure time) and fit the Poisson model */
/* This is equivalent to the Cox model (Whitehead 1980); estimates and SEs will be identical */
use http://pauldickman.com/data/colon.dta if stage == 1, clear
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow
stsplit, at(failures) riskset(riskset)
quietly tab riskset, gen(interval)

/* THIS MAY TAKE SEVERAL MINUTES TO RUN */
streg interval* i.sex i.year8594 i.agegrp, dist(exp)
estimates store Poisson_fine

/* Compare the estimates and SEs */
estimates table Cox Poisson_fine Poisson, eform equations(1) ///
keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
se b(%9.6f) se(%9.6f) modelwidth(12) ///
title("Hazard ratios and standard errors for various models")

// Now compare with flexible parametric model
use http://pauldickman.com/data/colon.dta if stage == 1, clear
stset surv_mm, failure(status==1) exit(time 120) id(id) noshow

stpm2 i.sex i.year8594 i.agegrp, scale(h) df(5) eform 
estimates store fpm

/* Compare the estimates and SEs */
estimates table Cox fpm Poisson, eform equations(1) ///
keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
se b(%9.6f) se(%9.6f) modelwidth(12) ///
title("Hazard ratios and standard errors for various models")
