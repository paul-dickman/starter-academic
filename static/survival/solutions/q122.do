
//==================//
// EXERCISE 122
// REVISED MAY 2015
//==================//

/* Data set used */
use melanoma if stage == 1, clear

/* All-cause survival */
stset surv_mm, failure(status==1,2) exit(time 120) 

/* Cox regression */
stcox i.sex i.year8594 i.agegrp

/* Now cause-specific survival */
stset surv_mm, failure(status==1)

/* Cox regression */
stcox i.sex i.year8594 i.agegrp
