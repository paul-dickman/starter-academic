set more off
use melanoma, clear
keep if stage == 1
stset surv_mm, failure(status==1) scale(12) id(id) noshow

/* Estimate the hazard ratio using a Cox model */
stcox year8594, basehc(base)

/* Plot the fitted hazards */
stcurve, hazard at1(year8594=0) at2(year8594=1) ///
   legend(position(2) ring(0) col(1) lab(1 "Diagnosed 1975-84") lab(2 "Diagnosed 1985-94")) ///
   xtitle("Time since diagnosis in years") ///
   title("Fitted hazards from Cox model") name(cox_fitted, replace)

/* restrict our analysis to mortality up to 10 years following diagnosis */
stsplit fu, at(0(1)10) trim
xi: streg i.fu year8594, dist(exp)
predict xb, xb nooffset
gen rate=exp(xb)
twoway line rate fu if year8594==0, c(J) clpattern(solid) sort || ///
   line rate fu if year8594==1, c(J) clpattern(shortdash) xtit("Time since diagnosis in years") sort ///
   ytit("Mortality rate per person-year") ///
   legend(position(2) ring(0) col(1) lab(1 "Diagnosed 1975-84") lab(2 "Diagnosed 1985-94")) ///
   title("Fitted hazards from Poisson regression model") name(poisson_fitted, replace)

