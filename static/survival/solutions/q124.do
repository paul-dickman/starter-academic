
//==================//
// EXERCISE 124
// REVISED MAY 2015
//==================//

/* Data set used */
use diet, clear

/* Poisson regression */
poisson chd hieng, e(y) irr

/* Stset with time in study as timescale*/
stset dox, id(id) fail(chd) entry(doe) origin(doe) scale(365.24)

/* Cox regression */
stcox hieng

/* New stset with attained age as timescale */
stset dox, id(id) fail(chd) entry(doe) origin(dob) scale(365.24)

/* Cow regression */
stcox hieng
