
//==================//
// EXERCISE 125
// REVISED MAY 2015
//==================//

/* Data set used */
use brv, clear

/* Look at variables in the data set */
desc

/* Look at some of the couples */
list id sex doe dosp dox fail if couple==3
list id sex doe dosp dox fail if couple==4
list id sex doe dosp dox fail if couple==19
list id sex doe dosp dox fail if couple==7


/****
 (b)
****/

/* Stset data */
stset dox, fail(fail) origin(dob) entry(doe) scale(365.24) id(id) noshow

/* Crude mortality rate for each sex */
strate sex, per(1000)

/* Poisson regression */
streg sex, dist(exp)


/* Calculate mean entry age by sex */
tabstat _t0, by(sex)

/****
 (c)
****/

/* Create a time-varying covariate */
stsplit brv, after(time=dosp) at(0)
recode brv -1=0 0=1

/* Look at some couples to see how the split worked */
list id sex doe dosp dox brv _t0 _t _d fail if couple==3
list id sex doe dosp dox brv _t0 _t _d fail if couple==4
list id sex doe dosp dox brv _t0 _t _d fail if couple==19
list id sex doe dosp dox brv _t0 _t _d fail if couple==7

/****
 (d)
****/

/* Poisson regression */
streg brv, distribution(exponential) nolog

/****
 (e)
****/

/* Poisson regression stratified on sex */
streg brv if sex==1
streg brv if sex==2

/* Poisson regression with effect of bereavement by sex */
streg i.sex i.brv#i.sex, dist(exp)

/****
 (f)
****/

/* Look at mean and lowest/highest value for _t0 and _t */
summarize _t0 _t, detail

/* Split follow up time (=age) to be able to control for age bands in Poisson model */
stsplit age, at(70(5)100)

/* Poisson model controlling for age */
streg brv i.age, nolog dist(exp)

/****
 (g)
****/

/* Poisson regression controlling for age and sex */
streg brv i.age sex, nolog

/* Poisson regression estimating the effect of brv for each sex, controlling for age */
streg i.age i.sex i.sex#i.brv, dist(exp)

/****
 (h)
****/

* No syntax needed

/****
 (i)
****/

/* Cox regression adjusted for age */
stcox brv, nolog

/****
 (j)
****/

/* Cox regression estimating the effect of brv for each sex, controlling for age */
stcox i.sex i.sex#i.brv, nolog


/* END OF FILE */


