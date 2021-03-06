/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/sex-differences-cox.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/sex-differences-cox/

- compare estimates from a Cox model and flexible parametric model
- estimate HR as a fucntion of follow-up time

Paul Dickman, March 2019
***************************************************************************/
// exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// create dummy variables for modelling
generate male=(sex==1)

// spline variables for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog
		
// estimate effect of sex adjusted for year of diagnosis and age 		
stpm2 i.male yearspl* i.agegrp, scale(h) df(5) eform 
estimates store adj1

// estimate effect of sex adjusted additionally for stage and subsite
stpm2 i.male yearspl* i.agegrp i.stage i.subsite, scale(h) df(5) eform
estimates store adj2

// estimate effect of sex adjusted for year of diagnosis and age 		
stcox i.male yearspl* i.agegrp 
estimates store adj1_cox

// estimate effect of sex adjusted additionally for stage and subsite
stcox i.male yearspl* i.agegrp i.stage i.subsite
estimates store adj2_cox

// compare estimates from crude and adjusted models
estimates table adj1 adj1_cox adj2 adj2_cox, eform equations(1) ///
   b(%9.6f) modelwidth(12) keep(i.male i.agegrp i.stage i.subsite)
   
// estimating the time-varying hazard ratio

stpm2 male yearspl* i.agegrp, scale(h) df(5) eform tvc(male) dftvc(3)

range temptime 0 10 51
predict hr, hrnumerator(male 1) ci timevar(temptime)

twoway (rarea hr_lci hr_uci temptime, color(red%25)) ///
       (line hr temptime, sort lcolor(red)) ///
      , legend(off) ysize(8) xsize(11) ///
       ytitle("Hazard ratio (male/female)") name("hrtvc", replace) ///
       xtitle("Years since diagnosis")

// empirical hazards as a function of follow-up time
sts graph, hazard by(sex) kernel(epan2) name(h, replace)

// Wald test for time-varying effect of sex
testparm _rcs_male*

