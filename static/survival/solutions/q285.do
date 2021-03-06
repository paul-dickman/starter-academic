
//======================================================//
// EXERCISE 285
// Multiple imputation
// October 2015, updated November 2018
// Paul Dickman
//======================================================//
set more off
use colon, clear

stset surv_mm, failure(status=1 2) scale(12) exit(time 10*12)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + mmdx/12 + _t)
merge m:1 _year sex _age using popmort
keep if _merge==3

tab stage

/* Check stage distribution over age and gender */
tab stage agegrp, column
tab stage sex, column

/* Graphs of survival by age group and stage */
stpm2 ib1.stage##i.agegrp , df(5) bhaz(rate) scale(hazard) eform nolog
predict survival, surv

line survival _t if stage==0, lpattern(dash) sort || ///
line survival _t if stage==1, sort || ///
line survival _t if stage==2, sort || ///
line survival _t if stage==3, sort by(agegrp) ///
 legend(order(1 "Unknown" 2 "Localised" 3 "Regional" 4 "Distant"))

/* Fit model using missing indicator approach */
stpm2 ib1.stage i.agegrp , df(5) bhaz(rate) scale(hazard) eform nolog

/* Refit model using complete records approach */
replace stage=. if stage==0
stpm2 ib1.stage i.agegrp , df(5) bhaz(rate) scale(hazard) eform nolog

// The outcome should be included in the imputation model.
// Falcaro et al suggest the Nelson-Aalen estimate of cum. hazard.
sts gen H=na

// Declare multiple-imputation data and register variables
mi set flong
mi register imputed stage
mi register regular subsite agegrp sex
mi register passive _rcs* _d_rcs*

// Perform imputation. 
// This creates 10 additional copies of the obs with missing stage.
// Carpenter and Kenward (2013) suggest 30 imputations. We use 10.
set seed 29390
mi impute chained (mlogit) stage = i.subsite sex i.agegrp H _d, add(10)

list id _mi_m agegrp sex stage _t _d if id==2287
list id _mi_m agegrp sex stage _t _d if id==3362
list id _mi_m agegrp sex stage _t _d if id==3501

// Note that as stpm2 is not an official Stata command we need to use cmd ok option
// Save the estimates so that they can be used for making predictions 
mi estimate, dots cmdok sav(mi_stpm2,replace): ///
    stpm2 ib1.stage i.agegrp, df(5) bhaz(rate) scale(hazard) nolog eform

// predict survival using -mi predictnl-	
mi predictnl survimp2 = predict(survival at(agegrp 2) timevar(_t)) using mi_stpm2

// compare predictions to complete case analysis
stpm2 ib1.stage i.agegrp if _mi_m==0, df(5) scale(h) bhaz(rate)
predict surv, survival at(agegrp 2)

line surv survimp2 _t if stage==1 & _mi_m==0, sort || ///
line surv survimp2 _t if stage==2 & _mi_m==0, sort || ///
line surv survimp2 _t if stage==3 & _mi_m==0, sort ///
title("Predicted survival for agegrp==2 (60-74)") ///
legend(order(1 "Localised (Complete)" 2  "Localised (Imputed)" ///
              3 "Regional (Complete)" 4 "Regional (Imputed)" ///
			  5 "Distant (Complete)" 6 "Distant (Imputed)")) ///
           name(imputed, replace)
		   
