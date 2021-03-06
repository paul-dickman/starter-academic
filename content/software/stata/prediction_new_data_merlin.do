/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/prediction_new_data_merlin.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/prediction_new_data_merlin/

Illustrates how to fit a model using patient data and then predict in a 
second dataset specifically constructed to contain only the covariates for 
which we wish to predict. Age is modelled using a restricted cubic spline.

Here we reproduce the analysis (using stpm2) shown at
http://pauldickman.com/software/stata/prediction_new_data/
with the difference that we use merlin and take advantage of merlin's
power for modelling and predicting with splines.

Paul Dickman & Michael Crowther, November 2019
***************************************************************************/

use https://pauldickman.com/data/colon if age>=40&age<=90, clear

// Create an indicator variable for sex
generate female=(sex==2)

// All-cause death as outcome, censor at 5 years
stset surv_mm, failure(status=1,2) scale(12) id(id) exit(time 60.5)

// Fit the Royston-Parmar model, make use of the stset internal variables
// We are reproducing the following stpm2 model
// stpm2 female rcsage1-rcsage4, scale(hazard) df(5) tvc(female) dftvc(2)
merlin (_t female female#rcs(_t, df(2) event log orthog) ///
           rcs(age, df(4) orthog) ///
		   , family(rp, df(5) failure(_d)) timevar(_t))   

// Create a new dataset in which to do the predictions
clear
range age 20 100 81
range female 0 1 2
range _t 0 6 25
fillin age female _t
drop if missing(age, female, _t)
generate _d=.
predict s2, survival timevar(_t)
// Set survival to 1 at time zero
replace s2=1 if _t==0

twoway (line s2 _t if female==0&age==50, sort lpattern(shortdash) lwidth(medthick) lcolor(blue)) ///
       (line s2 _t if female==1&age==50, sort lpattern(solid) lwidth(medthick) lcolor(black)) ///
	   , legend(label(1 "Male, age 50") label(2 "Female, age 50") ring(0) pos(1) col(1)) scheme(sj) name(s2_merlin, replace) ///
	   ytitle("Survival proportion", size(*1.0)) xtitle("Time since diagnosis (years)", size(*1.0)) 




	   
