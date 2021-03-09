
//==================//
// EXERCISE 182
// REVISED MAY 2015
//==================//

set matsize 800

/* Read in and stset the data */
use melanoma, clear
stset exit, failure(status == 1 2) origin(dx) entry(dx) scale(365.25) id(id)

/* Calculate relative survival using strs */
strs using popmort, br(0(1)21) mergeby(_year sex _age) notables save(replace)
use grouped.dta, clear
list start n d w p cp d_star, sum(d d_star)

/* Using the output from strs, calculate the SMR and 95% confidence intervals */

collapse (sum) obs=d exp=d_star
gen LL=( 0.5*invchi2(2*obs, 0.025)) / exp
gen UL=( 0.5*invchi2(2*(obs+1), 0.975)) / exp
gen smr=obs/exp
list obs exp smr LL UL


/************************************************************
Illustrate difference between the exact estimation and the
approximation done above using STRS, and then using the 
code given in the exercise (=same approach as in exercise 181)
*************************************************************/

/* Using STRS */
/* This causes strs to split on calendar year, rather than approximating attained calendar year. */
use melanoma, clear
stset exit, failure(status == 1 2) origin(dx) entry(dx) scale(365.25) id(id)
strs using popmort, br(0(1)21) mergeby(_year sex _age) notables save(replace) calyear
use grouped.dta, clear
list start n d w p cp d_star, sum(d d_star)
collapse (sum) obs=d exp=d_star
gen LL=( 0.5*invchi2(2*obs, 0.025)) / exp
gen UL=( 0.5*invchi2(2*(obs+1), 0.975)) / exp
gen smr=obs/exp
// Display the exact estimation:
list obs exp smr LL UL		


/* Using approach from exercise 181 */
use melanoma, clear
gen bdate = dx-(age*365.25)
stset exit, fail(status == 1 2) origin(bdate) entry(dx) scale(365.24) id(id)
stsplit _age, at(0(1)110) trim
stsplit _year, after(time=d(1/1/1975)) at(0(1)22) trim
replace _year=1975+_year
sort _year sex _age
merge m:1 _year sex _age using popmort
drop if _merge==2
gen mortrate=-ln(prob)
// Display the exact estimation:
strate, smr(mortrate)

use melanoma, clear
gen bdate = dx-(age*365.25)
stset exit, fail(status == 1 2) origin(bdate) entry(dx) scale(365.24) id(id)
stsplit _age, at(0(1)110) trim
gen _year=year(dx)+(_age-age)
sort _year sex _age
merge m:1 _year sex _age using popmort
drop if _merge==2
gen mortrate=-ln(prob)
// Display the approximation:
strate, smr(mortrate)
