
//==================//
// EXERCISE 211
// REVISED MAY 2015
//==================//

clear
use melanoma
stset surv_mm, failure(status=1 2) scale(12) exit(time 120.5) id(id)

***********************************************************************
* (a) Use strs to split the data with narrow (1 month) time intervals *
***********************************************************************
/* This may take up to a minute depending on the speed of your PC */

strs using popmort,	br(0(0.0883)6) mergeby(_year sex _age) ///
		by(agegrp sex year8594) notables ///
		savind(vnarrowint_ind, replace) ///
		savgroup(vnarrowint_grp, replace)

/* How many observations are there in the grouped and individual level datasets */
use vnarrowint_ind, clear
display "There are " _N " observations in the individual level data"
use vnarrowint_grp, clear
display "There are " _N " observations in the grouped level data"

*************************************************
* (b) Create variables and fit PEH spline model *
*************************************************

/* Load the grouped level data */
use vnarrowint_grp, clear
/* generate dummy variables */
tab agegrp, gen(agegrp)
gen female = sex == 2

/* generate spline variables */
gen midtime = (start+end)/2
rcsgen midtime, knots(0.05 0.25 0.75 1.5 2.5 4) gen(rcs) 

glm 	d rcs1-rcs5 agegrp2 agegrp3 agegrp4 female year8594 ///
		, family(poisson) link(rs d_star) lnoffset(y) 
estimates store M_sp_peh

/* use eform option to get excess hazard ratios */
glm, eform

**************************************************************************
* (c) Predict excess hazard rate and plot for oldest and youngest groups *
**************************************************************************

predict lh, xb nooffset
gen h=exp(lh)
twoway 	(line h midtime if agegrp1 == 1 & female == 0 & year8594 == 1, lpattern(dash) sort) ///
		(line h midtime if agegrp4 == 1 & female == 0 & year8594 == 1, sort), ///
		legend(order(1 "Agegrp 1 (0-44 years)" 2 "Agegrp 4 (75+ years)"))
		

/* on log scale */
twoway 	(line h midtime if agegrp1 == 1 & female == 0 & year8594 == 1, lpattern(dash) sort) ///
			(line h midtime if agegrp4 == 1 & female == 0 & year8594 == 1, sort) ///
			, yscale(log) legend(order(1 "Agegrp 1 (0-44 years)" 2 "Agegrp 4 (75+ years)"))

display "The lines are parallel as the model assumes proportional excess hazards"

******************************
* (d) Time dependent effects *
******************************

/* Interactions between spline variables and age group */
forvalues i = 1/4 {
	forvalues j = 1/5 {
		gen age`i'rcs`j' = agegrp`i' * rcs`j'
	}
}

/* fit model with time-dependent effects for age group */
glm 	d rcs1-rcs5 agegrp2 agegrp3 agegrp4 female year8594 ///
		age2rcs1-age2rcs5 age3rcs1-age3rcs5 age4rcs1-age4rcs5 ///
		, family(poisson) link(rs d_star) lnoffset(y) 
lrtest M_sp_peh 

******************************************************************
* (e) Obtain excess hazard ratios for each age group with 95% CI *
******************************************************************
forvalue i = 2/4 {
	partpred agehr`i', for(agegrp`i' age`i'rcs1-age`i'rcs5) eform ci(agehr`i'_lci agehr`i'_uci)
}

/* Plot excess hazard ratios vs time */
twoway 	(line agehr2 midtime if agegrp2==1, sort ) ///
			(line agehr3 midtime if agegrp3==1, sort) ///
			(line agehr4 midtime if agegrp4==1, sort) ///
			,legend(order(1 "45-59" 2 "60-74" 3 "75+") ring(0) pos(1) cols(1)) ///
			yline(1) ytitle(Excess Hazard Ratio) xtitle(Years from Diagnosis) 

*************************************************************
* (f) Plot excess hazard ratio for oldest group with 95% CI *
*************************************************************
twoway (rarea agehr4_lci agehr4_uci midtime if agegrp4==1, sort pstyle(ci)) ///
		 (line agehr4 midtime if agegrp4==1, sort) ///
		 (function y = 2.9, range(0 6) lcolor(black) lpattern(dash)), ///
		 legend(off) yline(1) ytitle(Excess Hazard Ratio) 
		 

*******************************************************
* (g) Estimated Relative Survival Curves with 95% CIs *
*******************************************************

/* preserve current data */
preserve
/* drop variables, but keep parameter and variances estimates */
drop _all
/* generate spline functions for 200 equally spaced intervals */
set matsize 200
range midtime 0.025 5 200
rcsgen midtime, knots(0.05 0.25 0.75 1.5 2.5 4) gen(rcs) 
matrix b=e(b)
matrix V=e(V)
gen ones=1

/* For age group 1 */
matselrc b b2, row(1) col(d:rcs1 d:rcs2 d:rcs3 d:rcs4 d:rcs5 d:year8594 d:_cons)
matselrc V V2, row(d:rcs1 d:rcs2 d:rcs3 d:rcs4 d:rcs5 d:year8594 d:_cons) ///
					 col(d:rcs1 d:rcs2 d:rcs3 d:rcs4 d:rcs5 d:year8594 d:_cons)
mkmat rcs1 rcs2 rcs3 rcs4 rcs5  ones ones, matrix(des1)
/* predicted log excess hazard function */
matrix predleh1 = des1*b2'
/* predicted excess hazard */
matewmf predleh1 predeh1, f(exp)
matrix predeh1_vcov = diag(predeh1)*des1*V2*des1'*diag(predeh1)'
/*create a triangular matrix*/
matrix cummat = J(200,200,0)
forvalues i = 1/200 {
	forvalues j = 1/`i' {
		matrix cummat[`i',`j']=0.025
	}
}
/*cumulative excess hazard*/
matrix predceh1 = cummat*predeh1
matrix predceh1_vcov = cummat*predeh1_vcov*cummat'
svmat double predceh1, names(predceh1)
rename predceh11 predceh1
matrix predceh1var = (vecdiag(predceh1_vcov))'
svmat double predceh1var, names(predceh1_var)
rename predceh1_var1 predceh1_var
/* calculated predicted relative survival with 95% confidence interval */
gen rs1 = exp(-predceh1)
gen rs1_lci = exp(-(predceh1 + 1.96*sqrt(predceh1_var)))
gen rs1_uci = exp(-(predceh1 - 1.96*sqrt(predceh1_var)))

/* For age group 4 */
matselrc b b2, row(1) col(d:rcs1 d:rcs2 d:rcs3 d:rcs4 d:rcs5 d:agegrp4 d:year8594 ///
				d:age4rcs1 d:age4rcs2 d:age4rcs3 d:age4rcs4 d:age4rcs5 d:_cons)
matselrc V V2, row(d:rcs1 d:rcs2 d:rcs3 d:rcs4 d:rcs5 d:agegrp4 d:year8594 ///
						d:age4rcs1 d:age4rcs2 d:age4rcs3 d:age4rcs4 d:age4rcs5 d:_cons) ///
					col(d:rcs1 d:rcs2 d:rcs3 d:rcs4 d:rcs5 d:agegrp4 d:year8594 ///
						d:age4rcs1 d:age4rcs2 d:age4rcs3 d:age4rcs4 d:age4rcs5 d:_cons)
mkmat 	rcs1 rcs2 rcs3 rcs4 rcs5 ones ones ///
			rcs1 rcs2 rcs3 rcs4 rcs5 ones, matrix(des4)
/* predicted log excess hazard function */
matrix predleh4 = des4*b2'
/* predicted excess hazard */
matewmf predleh4 predeh4, f(exp)
matrix predeh4_vcov = diag(predeh4)*des4*V2*des4'*diag(predeh4)'
/*cumulative excess hazard*/
matrix predceh4 = cummat*predeh4
matrix predceh4_vcov = cummat*predeh4_vcov*cummat'
svmat double predceh4, names(predceh4)
rename predceh41 predceh4
matrix predceh4var = (vecdiag(predceh4_vcov))'
svmat double predceh4var, names(predceh4_var)
rename predceh4_var1 predceh4_var
/* calculated predicted relative survival with 95% confidence interval */
gen rs4 = exp(-predceh4)
gen rs4_lci = exp(-(predceh4 + 1.96*sqrt(predceh4_var)))
gen rs4_uci = exp(-(predceh4 - 1.96*sqrt(predceh4_var)))

twoway	(rarea rs1_lci rs1_uci midtime, bstyle(ci2)) ///
		(rarea rs4_lci rs4_uci midtime, bstyle(ci2)) ///
		(line rs1 midtime, clpattern(solid)) ///
		(line rs4 midtime, clpattern(longdash)) ///
		,scheme(s2mono) xtitle("Time from Diagnosis (Years)") ///
		ytitle("Relative Survival") ///
		title("Melanoma Relative Survival (Males 1985-1994)") ///
		legend(order(3 "Age <45" 4 "Age 75+") ring(0) pos(7) cols(1))
restore

***************************************************
* (h) Fit a PEH fractional polynomial model using *
*     an FP3 for the baseline excess hazard       *
***************************************************

/* Note that this will take a few minutes to fit */
mfp, df(4, midtime:6) alpha(-1) ///
		xorder(n): glm d midtime ///
		(agegrp2 agegrp3 agegrp4 female year8594) ///
		, family(poisson) link(rs d_star) lnoffset(y) eform  
estimates store M_mfp_peh
estimates 	table M_sp_peh M_mfp_peh, eform ///
				keep(agegrp2 agegrp3 agegrp4 female year8594)

predict lh_fp, xb nooffset
gen h_fp = exp(lh_fp) 

/* compare hazards from FP and Spline models */
twoway 	(line h midtime if agegrp1 == 1 & female == 0 & year8594 == 1, lcolor(red) sort) ///
			(line h midtime if agegrp4 == 1 & female == 0 & year8594 == 1, lcolor(blue) sort) ///
			(line h_fp midtime if agegrp1 == 1 & female == 0 & year8594 == 1, lcolor(red) lpattern(longdash) sort) ///
			(line h_fp midtime if agegrp4 == 1 & female == 0 & year8594 == 1, lcolor(blue) lpattern(longdash) sort)
	
*******************************************************************			
* (i) Fit an FP model using an FP3 for the baseline excess hazard *
*     and FP2 for time-dependent effects for age group            *
*******************************************************************

forvalues i = 1/4 {
	gen age`i'midtime = midtime*agegrp`i'
}
						
mfp glm d midtime age2midtime age3midtime age4midtime ///
		(agegrp2 agegrp3 agegrp4 female year8594) ///
		, family(poisson) link(rs d_star) lnoffset(y) eform df(4, midtime:6) alpha(-1) ///
		xorder(n) zero(age2midtime age3midtime age4midtime)
						
partpred fp_age4_hr if agegrp4 == 1, for(agegrp4 Iage4__*) ///
  eform ci(fp_age4_hr_lci fp_age4_hr_uci)

twoway 	(rarea fp_age4_hr_lci fp_age4_hr_uci midtime if agegrp4==1, sort pstyle(ci)) ///
		(line fp_age4_hr midtime if agegrp4==1, sort lcolor(black)) ///
		(line agehr4_lci midtime if agegrp4==1, sort lcolor(red) lpattern(dash)) ///
		(line agehr4_uci midtime if agegrp4==1, sort lcolor(red) lpattern(dash)) ///
		(line agehr4 midtime if agegrp4==1, sort lcolor(red)) ///
		,legend(off) yline(1) 

*************************************************************** 
* (j) Compare grouped vs individual data for PEH spline model *
***************************************************************

clear
use vnarrowint_ind, clear
/* generate dummy variables */
tab agegrp, gen(agegrp)
gen female = sex == 2

/* generate spline variables */
gen midtime = (start+end)/2
rcsgen midtime, knots(0.05 0.25 0.75 1.5 2.5 4) gen(rcs) 

glm d rcs1-rcs5 agegrp2 agegrp3 agegrp4 female year8594 ///
	, family(poisson) link(rs d_star) lnoffset(y) 

estimates store M_sp_ind_peh
estimates 	table M_sp_peh M_sp_ind_peh, eform ///
				keep(agegrp2 agegrp3 agegrp4 female year8594)

	
