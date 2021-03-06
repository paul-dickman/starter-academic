
//==================//
// EXERCISE 243
// REVISED MAY 2015
//==================//

/* (a) */
/* Load melanoma data and stset*/
use melanoma, clear
keep if stage==1 /* restrict to localised */
stset surv_mm, fail(status==1 2) id(id) scale(12)

/* generate an age group variable for the 5 groupings */
recode age (min/44=1) (45/54=2) (55/64=3) (65/74=4) (75/max=5), gen(agegrpICSS)
label variable agegrpICSS "Age groups for ICSS"


label define agegrpICSS 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+"
label values agegrpICSS agegrpICSS



/*Generate the internal weights based on the age distribution of the data*/
local totalobs = _N
bysort agegrpICSS: gen standwei = _N/`totalobs'

label variable standwei "Internal age group weights"


/* Age-standardised using traditional approach implemented with iweights */

strs using popmort [iw=standwei], br(0(1)10) mergeby(_year sex _age) ///
list(n d w cr_e2 se_cp) standstrata(agegrpICSS) ///
savstand(internal,replace)


/* (b) */ 

/* We use ICSS 2 weights for melanoma 

15-44 year: 28%, 45-54 years: 17%, 
55-64years: 21%, 65-74 years: 20%,
75+ years: 14%

*/

/*Generate a variable with the external weights*/
recode age (min/44=0.28) (45/54=0.17) (55/64=0.21) (65/74=0.20) (75/max=0.14), gen(ICSS2wei)
label variable ICSS2wei "ICSS2 age group weights"


/* Age-standardised using external weights implemented with iweights */

strs using popmort [iw=ICSS2wei], br(0(1)10) mergeby(_year sex _age) ///
 list(n d w cr_e2 se_cp) standstrata(agegrpICSS) ///
savstand(external,replace)


/*(c) */
bys agegrpICSS: gen ind=1 if _n==1

list agegrpICSS standwei ICSS2wei if ind==1, noobs
 
/* It is also possible to save the standardised estimates and compare */

use internal, replace

list end cr_e2 lo_cr_e2 hi_cr_e2 if end==5, noobs

use external, replace  

list end cr_e2 lo_cr_e2 hi_cr_e2 if end==5, noobs





/* (d) */



/* Load melanoma data and stset*/
use melanoma, clear
keep if stage==1 /* restrict to localised */
stset surv_mm, fail(status==1 2) id(id) scale(12)

/* generate an age group variable for the 5 groupings */
recode age (min/44=1) (45/54=2) (55/64=3) (65/74=4) (75/max=5), gen(agegrpICSS)
label variable agegrpICSS "Age groups for ICSS"


label define agegrpICSS 1 "0-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+"
label values agegrpICSS agegrpICSS


/* Let's now use ICSS 1 weights for melanoma 

15-44 year: 7%, 45-54 years: 12%, 
55-64years: 23%, 65-74 years: 29%,
75+ years: 29%

*/

/*Generate a variable with the external weights*/
recode age (min/44=0.07) (45/54=0.12) (55/64=0.23) (65/74=0.29) (75/max=0.29), gen(ICSS1wei)
label variable ICSS1wei "ICSS1 age group weights"


/* Age-standardised using external weights implemented with iweights */

strs using popmort [iw=ICSS1wei], br(0(1)10) mergeby(_year sex _age) ///
 list(n d w cr_e2 se_cp) standstrata(agegrpICSS)  ///
savstand(externalICSS1,replace)



use internal, replace

list end cr_e2 lo_cr_e2 hi_cr_e2 if end==5, noobs

use external, replace  

list end cr_e2 lo_cr_e2 hi_cr_e2 if end==5, noobs

use externalICSS1, replace  

list end cr_e2 lo_cr_e2 hi_cr_e2 if end==5, noobs 
 
