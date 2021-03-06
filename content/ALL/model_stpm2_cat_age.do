/***************************************************************************
This code available at:
http://pauldickman.com/all/ALL_IARC_multiple-primary_rules_clean_make_dta.sas

This is step 3 in the 3 step process of modelling survival of patients with
acute lymphoblastic leukemia in the USA (SEER-9 registries)

1. Run SEER*Stat case-listing session
2. Run SAS file
3. Run Stata do file

See http://pauldickman.com/all/ for details.

Paul Dickman, April 2019
***************************************************************************/

use "SEER_ALL", clear

****** Create new observations for all covariate combinations that don't exist ********************

/*add "missing" observations to use for predictions, but not for modeling*/
local added = 0
forvalues i=1980/2015 {
	 foreach j of numlist 18 30 45 65 {
		forvalues k=1/2 {
			
			qui count if yeardiag==`i' & agegroup==`j' & sex==`k'
			if r(N)==0 {
				local added=`added'+1
				local N=_N+1
				qui set obs `N'
				qui replace yeardiag=`i' if _n==_N
				qui replace agegroup=`j' if _n==_N
				qui replace sex=`k' if _n==_N
			}
		}
	}
}

drop id
gen id=_n

display as text "Number of observations added: " `added'

/*dummy variable for sex*/
gen female=sex-1

/*dummy variable for agegroup */
quietly tab agegroup, gen(agegroup)

* degrees of freedom for the restricted cubic spline function
* for year of diagnosis. Note that we use a different spline
* for the main effect (see below) and this one with fewer df
* for interactions
local df_yr 2

/* spline variables for year of diagnosis*/
rcsgen yeardiag, df(`df_yr') gen(yearspl) orthog

/* save some stuff needed later to predict survival */
matrix Ryear = r(R)
global knotsyear `r(knots)'

/* generate interaction variables */
forvalues yr=1/`df_yr'  {
gen yearsexspl`yr'=yearspl`yr'*female	
}

forvalues yr=1/`df_yr'  {
gen ageyear1`yr'=yearspl`yr'*agegroup1	
gen ageyear2`yr'=yearspl`yr'*agegroup2	
gen ageyear3`yr'=yearspl`yr'*agegroup3	
gen ageyear4`yr'=yearspl`yr'*agegroup4	
}

gen sexage1=female*agegroup1
gen sexage2=female*agegroup2
gen sexage3=female*agegroup3
gen sexage4=female*agegroup4

*********************** stset with exit at year 6 *************
stset stime, fail(status==1) id(id) scale(12) exit(t 72)


*********************** Fit the model *************************
stpm2 yearspl* agegroup2 agegroup3 agegroup4 ageyear2* ageyear3* ageyear4*, scale(h) df(6) bhazard(rate) difficult ///
	tvc(yearspl1* agegroup2 agegroup3 agegroup4) dftvc(3) eform

/* predict and plot S(t) for four values of year */
range temptime 0 5 200

foreach yr in 1980 1990 2000 2010 {
rcsgen , scalar(`yr') rmatrix(Ryear) gen(c) knots($knotsyear)

/* predicted RSR for ages 18-29 (agegroup1) */
predict rsr`yr'_18 , survival timevar(temptime) zeros ///
   at(yearspl1 `=c1' yearspl2 `=c2' /*yearspl3 `=c3'*/)
   
/* predicted RSR for ages 30-44 (agegroup2) */
predict rsr`yr'_30 , survival timevar(temptime) zeros ///
   at(agegroup2 1 yearspl1 `=c1' yearspl2 `=c2' /*yearspl3 `=c3'*/ ageyear21 `=c1' ageyear22 `=c2' /*ageyear23 `=c3'*/)   
   
}

twoway   ///
(line rsr1980_18 temptime, sort lpattern(dash_dot) lwidth(medthick) lcolor(gs0)) ///
(line rsr1990_18 temptime, sort lpattern(longdash) lwidth(medthick) lcolor(gs0)) ///
(line rsr2000_18 temptime, sort lpattern(shortdash) lwidth(medthick) lcolor(gs0)) ///
(line rsr2010_18 temptime, sort lpattern(solid) lwidth(medthick) lcolor(gs0)) ///
, legend(label(1 "1980") label(2 "1990") label(3 "2000") label(4 "2010") ///
   size(*0.9)) scheme(sj) name(rsr18_by_year_SEER9, replace) subtitle("Ages 18-29, USA (SEER-9)") ///
ytitle("RSR", size(*1.1)) xtitle("") ///
ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.1) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.1)) 

twoway   ///
(line rsr1980_30 temptime, sort lpattern(dash_dot) lwidth(medthick) lcolor(gs0)) ///
(line rsr1990_30 temptime, sort lpattern(longdash) lwidth(medthick) lcolor(gs0)) ///
(line rsr2000_30 temptime, sort lpattern(shortdash) lwidth(medthick) lcolor(gs0)) ///
(line rsr2010_30 temptime, sort lpattern(solid) lwidth(medthick) lcolor(gs0)) ///
, legend(label(1 "1980") label(2 "1990") label(3 "2000") label(4 "2010") ///
   size(*0.9)) scheme(sj) name(rsr30_by_year_SEER9, replace) subtitle("Ages 30-44, USA (SEER-9)") ///
ytitle("RSR", size(*1.1)) xtitle("") ///
ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.1) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.1)) 

****************** create new dataset with one of each variable combination **************

bysort yeardiag agegroup: keep if _n==1
count 

/* estimate 1-yr RSR*/
gen t1=1
predict surv1, s ci timevar(t1)

/* estimate 5-yr RSR*/
gen t5=5
predict surv5, s ci timevar(t5)

keep surv? surv?_* yeardiag agegroup race
sort yeardiag agegroup

format surv1* surv5* %5.2f

/* list the 1-year RSRs for 2000 and 2010 */
list yeardiag agegroup surv1* if yeardiag==2000 | yeardiag==2010, sepby(yeardiag) noobs

/* list the 5-year RSRs for 2000 and 2010 */
list yeardiag agegroup surv5* if yeardiag==2000 | yeardiag==2010, sepby(yeardiag) noobs

*************** graphs of predicted relative survival ***************************************

twoway   ///
(line surv1 yeardiag if age==18, sort lpattern(solid) lwidth(medthick) lcolor(gs0)) ///
(line surv1 yeardiag if age==30, sort lpattern(longdash) lwidth(medthick) lcolor(blue)) ///
(line surv1 yeardiag if age==45, sort lpattern(shortdash) lwidth(medthick) lcolor(red)) ///
(line surv1 yeardiag if age==65, sort lpattern(dash_dot) lwidth(medthick) lcolor(green)) ///
, legend(label(1 "Age 18-29") label(2 "Age 30-44") label(3 "Age 45-64") label(4 "Age 65-84") size(*0.9) pos(11) ring(0) col(2)) ///
scheme(sj) name(rsr1_usa, replace) subtitle("1-year RSR, ALL, USA (SEER-9)") ///
ytitle("1-year RSR", size(*1.1)) xtitle("Year of diagnosis", size(*1.1)) ///
ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.1) angle(0)) yscale(range(0 1)) xlabel(1980(5)2015, labsize(*1.1)) 

twoway   ///
(line surv5 yeardiag if age==18, sort lpattern(solid) lwidth(medthick) lcolor(gs0)) ///
(line surv5 yeardiag if age==30, sort lpattern(longdash) lwidth(medthick) lcolor(blue)) ///
(line surv5 yeardiag if age==45, sort lpattern(shortdash) lwidth(medthick) lcolor(red)) ///
(line surv5 yeardiag if age==65, sort lpattern(dash_dot) lwidth(medthick) lcolor(green)) ///
, legend(label(1 "Age 18-29") label(2 "Age 30-44") label(3 "Age 45-64") label(4 "Age 65-84") size(*0.9) pos(11) ring(0) col(1)) /// 
scheme(sj) name(rsr5_usa, replace) subtitle("5-year RSR, ALL, USA (SEER-9)") ///
ytitle("5-year RSR", size(*1.1)) xtitle("Year of diagnosis", size(*1.1)) ///
ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.1) angle(0)) yscale(range(0 1)) xlabel(1980(5)2015, labsize(*1.1)) 

log close

***************************************** END OF FILE *****************************************
