
//==================//
// EXERCISE 110
// REVISED MAY 2015
//==================//

/* Data set used */
use diet, clear

stset dox, id(id) fail(chd) origin(doe) scale(365.25)

/* Incidence rate by hieng per 1000 py's */
strate hieng, per(1000)

/* Poisson regression */
poisson chd hieng, e(y) irr

/* Create categorical variable for energy intake */
histogram energy, normal
sum energy, detail
egen eng3 = cut(energy), at(1500, 2500, 3000, 4500)
tabulate eng3

/* Incidence rate by eng3 per 1000 py's */
strate eng3, per(1000) graph

/* Create indicator variable */
tabulate eng3, gen(X)

/* Check indicator variables */
list energy eng3 X1 X2 X3 if eng3==1500
list energy eng3 X1 X2 X3 if eng3==2500
list energy eng3 X1 X2 X3 if eng3==3000

/* Poisson regression */
poisson chd X2 X3, e(y) irr
poisson chd X1 X3, e(y) irr

/* Poisson regression where Stata creates dummy */
poisson chd i.eng3, e(y) irr

/* Number of events and person-time without using st command */
summarize y chd
di (337*0.1364985)/(337*13.66074)

/* Check your calculation */
stptime
