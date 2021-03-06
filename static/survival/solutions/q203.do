
//==================//
// EXERCISE 203
// REVISED MAY 2015
//==================//


/* Read in the data and restrict to localized melanoma*/
use melanoma if stage==1, clear

/* PERIOD ANALYSIS */
/* stset the data with time since diagnosis as the timescale */ 
/* restrict person-time at risk to that within the period window (01jan1994-31dec1995) */
stset exit, enter(time mdy(1,1,1994)) exit(time mdy(12,31,1995)) ///
origin(dx) f(status==1 2) id(id) scale(365.24)

/* Period estimates of relative survival by sex*/
strs using popmort, br(0(1)10) mergeby(_year sex _age) ///
  by(sex) list(n d p r cr_e2 se_cp)
  
/* COMPLETE COHORT ANALYSIS */
/* Now produce complete cohort estimates of relative survival*/
/* Note that the call to strs is identical to that used with period analysis */
/* The difference between the approaches is in how we stset */  
stset exit, enter(time dx) origin(dx) failure(status==1 2) ///
     id(id) scale(365.24)

strs using popmort, br(0(1)10) mergeby(_year sex _age) ///
  by(sex) list(n d p r cr_e2 se_cp)
