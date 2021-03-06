/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/age-standardise-standsurv.do

1. Estimate internally age-standardised 5-year survival for males and females
   for each year of diagnosis
2. Estimate the difference in internally age-standardised 5-year survival 
   between males and females for each year of diagnosis

See http://pauldickman.com/software/stata/age-standardise-standsurv/ for details.

Paul Dickman & Paul Lambert, February 2021
***************************************************************************/

// NOTE: The user-written command -standsurv- must be installed. 
// See https://pclambert.net/software/standsurv/
// Also need to install -stpm2- from SSC if not already installed

// read data from web; exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// outcome is cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// create dummy variables for modelling
generate male=(sex==1)
quietly tab agegrp, generate(agegrp)

// generate spline variables for year of diagnosis
rcsgen yydx, df(3) gen(yearspl) orthog
// store knots and R matrix for later use
global yearknots `r(knots)'
matrix R = r(R)

// interaction between sex and yearspl
generate maleyr1=male*yearspl1
generate maleyr2=male*yearspl2
generate maleyr3=male*yearspl3

// fit the model
stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
      tvc(agegrp2 agegrp3 agegrp4) dftvc(2)

// age-standardised 5-year survival for males, females, and the difference between the two
// the standard population is the age distribution of all patients across all years
generate t5=5 in 1
forvalues y = 1975/1994 {
  display "Calculating age-standardised survival for year: `y' "
  rcsgen, scalar(`y') knots(${yearknots}) rmatrix(R) gen(c) 
  standsurv , at1(male 0 maleyr1 0 maleyr2 0 maleyr3 0 yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              at2(male 1 maleyr1 `=c1' maleyr2 `=c2' maleyr3 `=c3' yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              timevar(t5) contrast(difference) ci ///
              atvar(S_female`y' S_male`y') contrastvars(S_diff`y')
}

list *1975* in 1

// reshape from wide to long to make plotting easier
keep in 1
keep id S_male* S_female* S_diff*
reshape long S_male S_male@_lci S_male@_uci ///
             S_female S_female@_lci S_female@_uci ///
			 S_diff S_diff@_lci S_diff@_uci, i(id) j(yydx)

twoway (rarea S_male_lci S_male_uci yydx, sort color(blue%25)) ///
       (line S_male yydx, sort lcolor(blue) lpattern(dash_dot)) /// 
	   (rarea S_female_lci S_female_uci yydx, sort color(red%25)) ///
       (line S_female yydx, sort lcolor(red) lpattern(solid)) /// 
                 , ysize(8) xsize(11) ///
				 title("Age-standardised 5-year cause-specific survival") ///
 				 subtitle("Standardised to the age-distribution among all patients for all years") ///
                 ylabel(,angle(h) format(%3.2f)) ///
                 ytitle("5-year survival (age-standardised)") name("agestand", replace) ///
                 xtitle("Year of diagnosis") ///
				 legend(label(2 "men") label(4 "women") order(2 4) ring(0) position(6) col(1))			 
graph export age-standardise-standsurv.svg, replace
				 
twoway (rarea S_diff_lci S_diff_uci yydx, sort color(blue%25)) ///
       (line S_diff yydx, sort lcolor(blue) lpattern(dash_dot)) /// 
                 , ysize(8) xsize(11) ///
				 title("Difference in age-standardised 5-year survival") ///
 				 subtitle("(men - women) with 95% confidence interval") ///
                 ylabel(,angle(h) format(%3.2f)) ///
                 ytitle("Difference in 5-year survival (age-standardised)") name("agestanddiff", replace) ///
                 xtitle("Year of diagnosis") legend(off) 	 
graph export age-standardise-standsurv-diff.svg, replace
		
exit

**************************** END OF FILE **********************************************************************

// if we want to produce age-standardised survival curves (and not just 5-year survival)
range tt 0 5 101
forvalues y = 1975/1994 {
  display "Calculating age-standardised survival for year: `y' "
  rcsgen, scalar(`y') knots(${yearknots}) rmatrix(R) gen(c) 
  standsurv , at1(male 0 maleyr1 0 maleyr2 0 maleyr3 0 yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              at2(male 1 maleyr1 `=c1' maleyr2 `=c2' maleyr3 `=c3' yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              timevar(tt) contrast(difference) ci ///
              atvar(S_male`y' S_female`y') contrastvars(S_diff`y')
}


				 

