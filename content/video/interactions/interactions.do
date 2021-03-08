***********************************************************
* Stata code accompanying the video lecture:
*
* Understanding interactions in the Cox model
*
* http://pauldickman.com/video/interactions/
*
* Enoch Chen, Paul Dickman
* August 2020
***********************************************************
// Start of Stata code //
use "https://pauldickman.com/data/melanoma.dta" if stage == 1, clear

* Declare data to be survival-time
* status = 1 as death; censor after 120 months
stset surv_mm, failure(status == 1) scale (12) exit(time 120) id(id)

//
* Main model
stcox sex i.agegrp year8594, efron

* Adding interaction between sex & year8594
stcox i.sex i.year8594 i.sex#i.year8594 i.agegrp, efron

* Effect of sex for second period
lincom 2.sex + 2.sex#1.year8594, eform
 
* Same model (same parameterisation) but different syntax
stcox i.sex##i.year8594 i.agegrp, efron

* Fitting the same model with different parameterisation 1
* We now get the two estimated HRs (effect of sex) for each period
stcox i.year8594 i.sex#i.year8594 i.agegrp, efron

* Fitting the same model with different parameterisation 2
stcox i.year8594#i.sex i.agegrp, efron 

* Interaction between sex and age group
stcox i.year8594 i.sex##i.agegrp, efron

* Reparameterise to get the four HRs for sex
stcox i.year8594 i.agegrp i.agegrp#i.sex, efron 

//
* Test the significance of the interaction (Wald test)
test 0.agegrp#2.sex = 1.agegrp#2.sex = 2.agegrp#2.sex = 3.agegrp#2.sex

* Equivalently, could also use
stcox i.year8594 i.agegrp##i.sex, efron
test 1.agegrp#2.sex 2.agegrp#2.sex 3.agegrp#2.sex

* Now using a likelihood ratio test
estimates store interaction
stcox i.year8594 i.agegrp i.sex, efron
lrtest interaction

//End of Stata code//
