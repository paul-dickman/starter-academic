/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/mediation_meansurv.do

Mediation analysis using predict, meansurv

We are interested in sex difference in survival of patients with melanoma,
with focus on the extent to which the sex differences are mediated by stage.
We will partition the total effect of sex into the natural indirect effect
(mediated by stage) and the natural direct effect. We then illustrate how to
estimate the proportion of the sex difference mediated by stage (as a function
of time with confidence intervals).

Emphasis is on illustrating how these quantities can be estimated in Stata; 
we won't discuss the neccessary assumptions and their appropriateness.   

Paul Dickman, July 2019
***************************************************************************/
// exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// create dummy variables for modelling
generate male=(sex==1)
tab stage, gen(stage)

// Fit the model
stpm2 male stage2 stage3, df(5) tvc(male) dftvc(3) scale(hazard) eform

// Create temporary time variable
range temptime 0 15 46

/*survival (women)*/
predict s0m0 if male==0, meansurv timevar(temptime)

/*survival (men)*/
predict s1m1 if male==1, meansurv timevar(temptime)

/* Survival of males if they had the stage distribution of females */
predict s1m0 if male==0, meansurv at(male 1) timevar(temptime)

/* Survival of females if they had the stage distribution of males */
/* This is not used in the mediation analysis */
predict s0m1 if male==1, meansurv at(male 0) timevar(temptime)

// Estimate NDE, NIE, TE, and PM
generate TE = (s0m0 - s1m1)*100 if temptime != .
generate NIE = (s1m0 - s1m1)*100 if temptime != .
generate NDE = (s0m0 - s1m0)*100 if temptime != .
generate PM = (NIE / TE)*100 if temptime != .

label variable TE "Total effect"
label variable NIE "Natural indirect effect"
label variable NDE "Natural direct effect"
label variable PM "Proportion mediated"

format TE NDE NIE PM %6.2f 
list temptime TE NDE NIE PM if inlist(temptime,0,1,5,10)

twoway	(line s1m0 temptime, sort lcolor(blue) lpattern(dash)) ///
		(line s0m1 temptime, sort lcolor(red) lpattern(dash)) ///
		(line s1m1 temptime, sort lcolor(blue)) ///
		(line s0m0 temptime, sort lcolor(red)) ///
		, ///
		graphregion(color(white)) ///
		xlabel(0(5)15, labsize(*1.0)) ///
		ylab(0.5(0.1)1, nogrid angle(0) labsize(*1.0) format(%04.2f)) ///
			legend(cols(2) size(*0.6) region(lcolor(white)) bmargin(zero) order(4 3 2 1) position(6) ring(0) ///
			label(1 "S1M0 (men if stage dist. of women)") label(2 "S0M1 (women if stage dist. of men)") label(3 "S1M1 (men)") label(4 "S0M0 (women)")) ///
			title (Survival) name(survival, replace) ///
			xtitle("Years since diagnosis") ///
			ytitle("Cause-specific survival", size(*1.0)) 
			
twoway	(line PM temptime, sort lcolor(blue) lpattern(solid)) ///
		, ///
		graphregion(color(white)) ///
		xlabel(0(5)15, labsize(*1.0)) ///
		ylab(0(10)100, nogrid angle(0) labsize(*1.0) format(%4.0f)) ///
			title (Percentage of sex difference mediated by stage) name(pm, replace) ///
			xtitle("Years since diagnosis") legend(off) ///
			ytitle("Percentage mediated", size(*1.0)) 
			
