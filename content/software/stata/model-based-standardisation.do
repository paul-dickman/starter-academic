
/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/model-based-standardisation.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/model-based-standardisation/

Paul Dickman, March 2019
***************************************************************************/

use https://pauldickman.com/data/colon.dta if stage==1, clear
keep surv_mm status yydx age 

stset surv_mm, fail(status==1,2) scale(12)

/*spline variable for year of diagnosis*/
rcsgen yydx, df(3) gen(yearspl) orthog

// New age groups according to the International Cancer Survival Standard (ICSS)
label drop agegrp
egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
label variable agegrp "Age group"
label define agegrp 1 "15-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+" 
label values agegrp agegrp

// Generate dummy variables for agegrp. -stpm2- supports 
// factor variables (i.) for main effects but not time-varying effects
quietly tab agegrp, gen(agegrp)

// Create weights to use for age-standardisation
recode agegrp (1=0.07) (2=0.12) (3=0.23) (4=0.29) (5=0.29), gen(ICSSwt)
local total= _N
bysort agegrp:gen a_age = _N/`total'
gen w = ICSSwt/a_age

// show the weights
tabstat w, statistics( mean min max) by(agegrp)

stpm2 yearspl? agegrp2 agegrp3 agegrp4 agegrp5, scale(h) df(4) eform ///
  tvc(yearspl? agegrp2 agegrp3 agegrp4 agegrp5) dftvc(1)

// Create values of follow-up time for which to predict survival
// See: https://pclambert.net/software/stpm2/stpm2_timevar/
range temptime 0 10 101

// marginal (population-averaged) survival
predict s_unweighted, meansurv timevar(temptime)

// marginal (population-averaged) survival standardised to ICSS
predict s_weighted, meansurv meansurvwt(w) timevar(temptime)

twoway 	(line s_weighted temptime , sort lpattern(shortdash) lwidth(medthick) lcolor(black)) ///
		(line s_unweighted temptime , sort lpattern(solid) lwidth(medthick) lcolor(black)) ///
		, legend(label(1 "Marginal survival (standardised)") label(2 "Marginal survival (unstandardised)") ring(0) pos(7) col(1)) ///
		scheme(sj) name(surv1, replace) ysize(8) xsize(11) ///
		subtitle("`text`i''", size(*1.0)) ytitle("All-cause survival", size(*1.0)) xtitle("Years since diagnosis", size(*1.0)) ///
		ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.0) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.0))
graph export model-based-standardisation.svg, replace

// Standardised survival is higher than the unstandardised, which suggests
// our patient population is older than the standard population
tab agegrp

// Now let's just estimate 5-year survival to get insight into what meansurv is doing
drop temptime

generate t5=5

// 5-year survival conditional on covariates
predict s5, survival timevar(t5)

// 5-year marginal (population-averaged) survival
predict s5_unweighted, meansurv timevar(t5)

// 5-year marginal (population-averaged) survival standardised to ICSS
predict s5_weighted, meansurv meansurvwt(w) timevar(t5)

list yydx agegrp s5 s5_unweighted s5_weighted in 1/5

summarize s5

generate s5w=s5*w
summarize s5w




