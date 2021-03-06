/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/sex-differences.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/sex-differences/

- examine sex differences in patient survival
- obtain standardised survival curves
- survival of men if they had the covariate distribution of women 

Paul Dickman, March 2019
***************************************************************************/
// exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// create dummy variables for modelling
generate male=(sex==1)
quietly tab agegrp, generate(agegrp)
quietly tab stage, generate(stage)
quietly tab subsite, generate(subsite)

// spline variables for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog

// terms for interaction between sex and stage
generate stage2m=stage2*male
generate stage3m=stage3*male

// temporary time variable for predictions
range temptime 0 10 101	 

// Kaplan-Meier estimate of survival
sts gen km=s, by(sex)

// Fit a flexible parametric model and save the predicted survival
// Allow non-proportional hazards for sex
stpm2 i.male, scale(h) df(5) eform tvc(male) dftvc(2)

predict fpm, survival

twoway 	(line km _t if male==0 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(red%50)) ///
		(line km _t if male==1 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(blue%50)) ///
		(line fpm _t if male==0 , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
		(line fpm _t if male==1 , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
		, scheme(sj) ysize(8) xsize(11) name("sexdiff1", replace) ///
		ytitle("Cause-specific survival") xtitle("Years since diagnosis") ///
		legend(label(1 "Female K-M") label(2 "Male K-M") label(3 "Female fpm") label(4 "Male fpm") ring(0) pos(7) col(1))
graph export sexdiff1.svg, replace
		
// Now assume PH for sex so we can intepret the HR
stpm2 i.male, scale(h) df(5) eform 	
estimates store crude
		
// Study association between exposure (sex) and potential confounders		
tab agegrp sex, col
tab stage sex, col
tab subsite sex, col		
		
// estimate effect of sex adjusted for year of diagnosis and age 		
stpm2 yearspl* i.male i.agegrp, scale(h) df(5) eform ///
      tvc(yearspl* agegrp2 agegrp3 agegrp4) dftvc(2)
estimates store adj1

// estimate effect of sex adjusted additionally for stage and subsite
stpm2 yearspl* i.male i.agegrp i.stage i.subsite, scale(h) df(5) eform ///
      tvc(yearspl* agegrp2 agegrp3 agegrp4 stage2 stage3 subsite2 subsite3 subsite4) dftvc(2)
estimates store adj2

// compare estimates from crude and adjusted models
estimates table crude adj1 adj2, eform equations(1) b(%9.6f) modelwidth(12) ///
   keep(i.male i.agegrp i.stage i.subsite)

// More complex model for standardisation  
// includes interaction between sex and stage and time-varying effects of sex and year
stpm2 yearspl* male agegrp2 agegrp3 agegrp4 stage2 stage3 subsite2 ///
      subsite3 subsite4 stage2m stage3m, scale(h) df(5) eform ///
      tvc(male yearspl*) dftvc(2)
 
// Marginal survival for males and females
predict marginal0, meansurv at(male 0 stage2m 0 stage3m 0) timevar(temptime)
predict marginal1, meansurv at(male 1 stage2m = stage2 stage3m = stage3) timevar(temptime)

twoway 	(line marginal0 temptime , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
		(line marginal1 temptime , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
		, scheme(sj) ysize(8) xsize(11) name("sexdiff2", replace) ///
		ytitle("Cause-specific survival", size(*1.0)) xtitle("Years since diagnosis", size(*1.0)) ///
		legend(label(1 "Female (marginal)") label(2 "Male (marginal)") ring(0) pos(7) col(1))		
graph export sexdiff2.svg, replace	 
	 
// marginal survival for males and marginal survival for females
predict meansurv00 if male==0, meansurv timevar(temptime)
predict meansurv11 if male==1, meansurv timevar(temptime)

twoway 	(line km _t if male==0 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(red%50)) ///
		(line km _t if male==1 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(blue%50)) ///
		(line meansurv0 temptime , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
		(line meansurv1 temptime , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
		, scheme(sj) ysize(8) xsize(11) name("sexdiff3", replace) ///
		ytitle("Cause-specific survival") xtitle("Years since diagnosis") ///
		legend(label(1 "Female K-M") label(2 "Male K-M") label(3 "Female fpm") label(4 "Male fpm") ring(0) pos(7) col(1))
graph export sexdiff3.svg, replace

// Survival for males if they had the covariate distribution of females
// Survival that would be observed for females if they had the cancer-specific mortality of males  
predict meansurv01 if male==0, meansurv at(male 1 stage2m = stage2 stage3m = stage3) timevar(temptime)

// Survival for females if they had the covariate distribution of males
// Survival that would be observed for males if they had the cancer-specific mortality of females  
predict meansurv10 if male==1, meansurv at(male 0 stage2m 0 stage3m 0) timevar(temptime)

twoway 	(line meansurv00 temptime , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
		(line meansurv11 temptime , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
		(line meansurv01 temptime , sort lpattern(dash) lwidth(medthick) lcolor(blue)) ///
		, scheme(sj) ysize(8) xsize(11) name("sexdiff4", replace) ///
		ytitle("Cause-specific survival", size(*1.0)) xtitle("Years since diagnosis", size(*1.0)) ///
		legend(label(1 "Female") label(2 "Male") label(3 "Male (adjusted)") ring(0) pos(7) col(1))		
graph export sexdiff4.svg, replace

twoway 	(line meansurv00 temptime , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
		(line meansurv11 temptime , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
		(line meansurv10 temptime , sort lpattern(dash) lwidth(medthick) lcolor(blue)) ///
		, scheme(sj) ysize(8) xsize(11) name("bob", replace) ///
		ytitle("Cause-specific survival", size(*1.0)) xtitle("Years since diagnosis", size(*1.0)) ///
		legend(label(1 "Female") label(2 "Male") label(3 "Male (adjusted)") ring(0) pos(7) col(1))		

// Proportion of the sex difference explained by confounders
generate explained=(meansurv01-meansurv11)/(meansurv00-meansurv11) if temptime!=.
format meansurv00 meansurv01 meansurv11 explained %5.3f
list temptime meansurv00 meansurv01 meansurv11 explained if inlist(temptime,1,5,10), noobs	 
	 
// Difference in standardised survival curves
// This takes several minutes to run if the ci option is used	
predictnl diff = predict(meansurv timevar(temptime)) - ///
                 predict(meansurv at(male 1 stage2m = stage2 stage3m = stage3) timevar(temptime)) ///
                 if male==0, /*ci(diff_lci diff_uci)*/

/*				 
twoway (rarea diff_lci diff_uci temptime, color(red%25)) ///
                 (line diff temptime, sort lcolor(red)) ///
                 , legend(off) ysize(8) xsize(11) ///
                 ylabel(,angle(h) format(%3.2f)) ///
                 ytitle("Difference in S(t)") name("sexdiff4a", replace) ///
                 xtitle("Years since diagnosis")			
graph export sexdiff4a.svg, replace   
*/
			
// Repeat estimation of marginal survival using stpm2_standsurv
// This estimates marginal survival among females (same as in marginal0),
// marginal survival among males (marginal1), and the difference (male - female)
stpm2_standsurv, at1(male 0 stage2m 0 stage3m 0) ///
                 at2(male 1 stage2m = stage2 stage3m = stage3) ///
				 timevar(temptime) ci contrast(difference)

list _at1 _at2 marginal0 marginal1 in 1/5

twoway  (rarea _contrast2_1_lci _contrast2_1_uci temptime, color(red%25)) ///
           (line _contrast2_1 temptime, sort lcolor(red)) ///
           , legend(off) ysize(8) xsize(11) ///
           ylabel(,angle(h) format(%3.2f)) ///
           ytitle("Difference in S(t)") name("sexdiff_contrast", replace) ///
           xtitle("Years since diagnosis")
graph export sexdiff_contrast.svg, replace
			
// Be careful with "adjusted" survival curves
// sts graph gives predicted curves for 0 values of adjustfor() variables  		
sts graph, by(sex) adjustfor(age) name("sexdiff5", replace) ysize(8) xsize(11)
graph export sexdiff5.svg, replace

sts graph, by(sex) adjustfor(age yydx) name("sexdiff6", replace) ysize(8) xsize(11)
graph export sexdiff6.svg, replace

// Generate "centered" variables
generate age70=age-70
generate yydx1980=yydx-1980

sts graph, by(sex) adjustfor(age70 yydx1980) name("sexdiff7", replace) ysize(8) xsize(11)
graph export sexdiff7.svg, replace

sts graph, strata(sex) adjustfor(age70 yydx1980) name("sexdiff8", replace) ysize(8) xsize(11)
graph export sexdiff8.svg, replace






