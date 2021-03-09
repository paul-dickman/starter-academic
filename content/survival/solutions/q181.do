
//==================//
// EXERCISE 181
// REVISED MAY 2015
//==================//

/****
 (a)
****/
use melanoma, clear

/* Stset with attained age as the timescale, all-cause mortality as outcome */
/* We need to create a variable for birthdate in order to use age as the timescale */
gen bdate = dx-(age*365.25)
stset exit, fail(status==1 2) origin(bdate) entry(dx) scale(365.25) id(id)

/* Split age into 1 year age bands */
stsplit _age, at(0(1)110) trim

/* Check that the split was okay */
list id _t0 _t _d _age in 1/20

/****
 (b)
****/

/* Split these records into annual calendar period bands */
stsplit _year, after(time=d(1/1/1975)) at(0(1)22) trim

/* Correct value on variable _year */
replace _year=1975+_year

/* Check that the split was okay */
list id _t0 _t _d _age bdate _year in 1/20

/****
 (c)
****/

/* Generate a person-time variable */
gen _y = _t - _t0 if _st==1

/* Tabulate _age and _year and look at number of CASES per age group and calendar year */
table _age _year, c(sum _d)

/* Tabulate _age and _year and look at amount of PERSON-TIME per age group and calendar year */
table _age _year, c(sum _y) format(%5.3f)

/* Create categorised age band variable */
egen ageband_10=cut(_age), at(0(10)110)

/* Create categorised calendar period variable */
egen period_5=cut(_year), at(1970(5)2000)

/* Look at number of cases per age band and calendar period */
table ageband_10 period_5, c(sum _d)

/* Look at amount of person-time per age band and calendar period */
table ageband_10 period_5, c(sum _y) format(%5.3f)

/****
 (d)
****/

/* Create variable with observed rate in exposed population */
gen obsrate=_d/_y

/* Look at mean rate among the exposed population per age band and calendar period */
table ageband_10 period_5 [iw=_y], c(mean obsrate) format(%5.3f)

/****
 (e)
****/

/* Sort data */
sort _year sex _age

/* Merge exposed population with popmort data */
merge m:1 _year sex _age using popmort

/* Look at values of merge variable */
tab _merge

/* Exclude rows which are not in exposed population */
drop if _merge==2

/* Drop merge variable */
drop _merge

/****
 (f)
****/

/* Calculate mortality rate in standard population */
gen mortrate=(-ln(prob))

/* Calculate expected number of cases in exposed population, given  */
/* that they have the same mortality rate as the general population */
gen e=_y*mortrate

/* Look at some of the variables in the data */
list id e _d mortrate in 1/20

/****
 (g)
****/

compress

/* Calculate total number of observed and expected events */
egen obs = total(_d)
egen exp = total(e)

/* Speed up calculations */
preserve
keep in 1

/* Calculate SMR and lower and upper confidence limits */
gen SMR = obs/exp
gen LL = (0.5*invchi2(2*obs, 0.025))/exp
gen UL = (0.5*invchi2(2*(obs+1), 0.975))/exp

/* Display SMR and CI */
display "SMR(95%CI)=" round(SMR,.001) "(" round(LL,.001) ":" round(UL,.001) ")"

restore
/* Easier way to calculate the SMR */
strate, smr(mortrate)

/****
 (h)
****/

compress

/* SMR by stage */
strate stage, smr(mortrate)


/* END OF FILE */

