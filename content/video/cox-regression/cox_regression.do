***********************************************************
* Stata code accompanying the video lecture:
*
* Introduction to Cox regression
*
* http://pauldickman.com/video/cox-regression/
*
* Enoch Chen, Paul Dickman
* August 2020
***********************************************************

use "https://pauldickman.com/data/colon.dta", clear

* Check coding of stage and status
codebook stage status // stage = 3 labeled as Distant
					  
* Create indicator variables for distant stage and age group 75+
generate distant = (stage == 3) 
generate agegrp3 = (agegrp==3) 

***********************************************************
* Declare data to be survival-time data
* Specify survival time, failure
// status 1 = Dead: cancer, 2 = Dead: other
stset surv_mm, failure(status == 1) scale(12) id(id)

* Main model
stcox distant, efron 

* Adjust for agegrp (two categories)
stcox agegrp3 distant, efron 

* Fit model to just the individuals with localised stage
stcox sex i.agegrp year8594 if stage == 1, efron  // stage 1 = Localised

* Test the effect of age (Wald test)
test 1.agegrp 2.agegrp 3.agegrp

* Test the effect of age (likelihood ratio test test)
stcox sex i.agegrp year8594 if stage == 1, efron  // stage 1 = Localised
est store A
stcox sex  year8594 if stage == 1, efron  // stage 1 = Localised
lrtest A

* Model age as a continuous variable
stcox sex age year8594 if stage == 1, efron  // stage 1 = Localised

/******************************************************************************
A note about ties in the Cox model

The Cox model (as well as the Kaplan-Meier estimator) are developed under the 
assumption that survival times are continuous (and measured with infinite 
precision) such that all individuals will have a unique time to event/censoring.  
In practice, survival times are not measured with infinite precision and some
individuals will have the same survival times. These are called "ties" and we 
need to make an approximation to the estimation procedure to account for ties.
 
By default, R uses the so-called "Efron method" and Stata uses the so-called
"Breslow method". To make the Stata estimates agree with the R estimates shown
in the lecture notes we have spefied the "efron" option in the Stata code.
******************************************************************************/

//End of Stata code//
