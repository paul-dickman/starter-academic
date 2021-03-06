/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/mediation_standsurv.do

Mediation analysis using standsurv

See https://pclambert.net/software/standsurv/ for details of installing standsurv

We are interested in sex difference in survival of patients with melanoma,
with focus on the extent to which the sex differences are mediated by stage.
We will partition the total effect of sex into the natural indirect effect
(mediated by stage) and the natural direct effect. We then illustrate how to
estimate the proportion of the sex difference mediated by stage (as a function
of time with confidence intervals).

Emphasis is on illustrating how these quantities can be estimated in Stata
using the standsurv command; we won't discuss the neccessary assumptions and
their appropriateness.   

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

/* Define function for calculating proportion mediated (for use in standsurv) */
mata:
mata clear
            function calcPM(at) {
                return(100*(at[3] - at[2])/(at[1] - at[2]))
            }
            end

// Use standsurv to estimate 4 survival functions along with the proportion mediated
// 1. Survival for females
// 2. Survival for males
// 3. Survival for males if they had the stage distribution of women
// 4. Survival for females if they had the stage distribution of men
standsurv, atvars(s0m0 s1m1 s1m0 s0m1) ci timevar(temptime) ///
    at1(., atif(male==0)) at2(., atif(male==1)) at3(male 1, atif(male==0)) at4(male 0, atif(male==1)) ///
	userfunction(calcPM) userfunctionvar(PM)
	
// NOTES ON STANDSURV SYNTAX
// Consider at3(male 1, atif(male==0))
// atif(male==0) specifies that we should only use observations for females (male==0).
// "male 1" specifies that we predict survival under the assumption that everyone is male.
// As such, we take the group of observations with the stage distribution of females but 
// predict the survival that would be observed if they had the predicted survival of males.
// This gives us "Survival of men if they had the stage distribution of women"

// By specifying at1(., atif(male==0)), we get the survival of females (male==0) predicted at
// the actual values of their covariates (".").

// Estimate NDE, NIE and TE (PM is calculated in standsurv)
generate TE = (s0m0 - s1m1)*100 if temptime != .
generate NIE = (s1m0 - s1m1)*100 if temptime != .
generate NDE = (s0m0 - s1m0)*100 if temptime != .

label variable TE "Total effect"
label variable NIE "Natural indirect effect"
label variable NDE "Natural direct effect"
label variable PM "Proportion mediated"

format TE NDE NIE PM PM_lci PM_uci %6.2f
list temptime TE NDE NIE PM PM_lci PM_uci if inlist(temptime,0,1,5,10)

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
			title (Cause-specific survival) name(survival_standsurv, replace) ///
			xtitle("Years since diagnosis") ///
			ytitle("Cause-specific survival", size(*1.0)) 
			
twoway	(line PM temptime, sort lcolor(blue) lpattern(solid)) (rarea PM_lci PM_uci temptime, color(blue%30)) ///
		, ///
		graphregion(color(white)) ///
		xlabel(0(5)15, labsize(*1.0)) ///
		ylab(0(10)100, nogrid angle(0) labsize(*1.0) format(%4.0f)) ///
			title (Percentage of sex difference mediated by stage) name(pm_standsurv, replace) ///
			xtitle("Years since diagnosis") legend(off) ///
			ytitle("Percentage mediated", size(*1.0)) 
			
