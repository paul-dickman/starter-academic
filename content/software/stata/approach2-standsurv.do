/***************************************************************************
APPROACH 2 - USING STANDSURV

1. Estimate internally age-standardised 5-year survival for males and females
   for each year of diagnosis

Paul Dickman & Paul Lambert, February 2021
***************************************************************************/

// read data from web; exclude unknown stage (stage==0)
use https://pauldickman.com/data/melanoma.dta if stage>0, clear

// outcome is cause-specific survival (status==1 is death due to melanoma) 
stset surv_mm, fail(status==1) scale(12) exit(time 120)

// Reclassify age groups according to International Cancer Survival Standard (ICSS 2)
// Overview: https://seer.cancer.gov/stdpopulations/survival.html
// Original publication: https://www.sciencedirect.com/science/article/abs/pii/S0959804904005283
drop agegrp
label drop agegrp
drop if age < 15
egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
label define agegrp 1 "15-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+" 
label values agegrp agegrp

// Generate a veraiable with ICSS weights (we use ICSS 2 for melanoma)
recode agegrp (1=0.28) (2=0.17) (3=0.21) (4=0.20) (5=0.14), gen(ICSSwt)

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

// interaction between sex and age
generate maleage2=male*agegrp2
generate maleage3=male*agegrp3
generate maleage4=male*agegrp4
generate maleage5=male*agegrp5

// required to get standsurv to work
sort agegrp

// fit the model
stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4 agegrp5 maleage?, scale(h) df(5) eform ///
      tvc(agegrp2 agegrp3 agegrp4 agegrp5 male) dftvc(2)

// age-standardised 5-year survival for males, females, and the difference between the two
// standard population is ICSS2
generate t5=5 in 1
forvalues y = 1975/1994 {
  display "Calculating age-standardised survival for year: `y' "
 
  // Create weights to use for external age-standardisation
  // Separate weights are required for each year (since age distribution varies by year)
  // total obs for each year
  count if yydx==`y'
  local total: display %3.0f r(N)
  
  // count of number of patients in each agegroup for each year
  by agegrp: egen n_age`y'=sum(yydx==`y')

  // generate weights
  gen w`y' = ICSSwt/(n_age`y'/`total') 
  // write the spline basis vectors to local macro variables
  rcsgen, scalar(`y') knots(${yearknots}) rmatrix(R) gen(c) 
  
  // estimate age-standardised survival for men and women (with difference)
  standsurv , at1(male 0 maleyr1 0 maleyr2 0 maleyr3 0 yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3' maleage2 0  maleage3 0  maleage4 0  maleage5 0) ///
              at2(male 1 maleyr1 `=c1' maleyr2 `=c2' maleyr3 `=c3' yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3'  maleage2=agegrp2  maleage3=agegrp3  maleage4=agegrp4 maleage5=agegrp5) ///
              timevar(t5) contrast(difference) ci indweights(w`y') ///
              atvar( S_female`y' S_male`y') contrastvars(S_diff`y')
}

// reshape from wide to long to make plotting easier
keep in 1
keep id S_male* S_female* S_diff*
reshape long S_male S_male@_lci S_male@_uci ///
             S_female S_female@_lci S_female@_uci ///
			 S_diff S_diff@_lci S_diff@_uci, i(id) j(yydx)

twoway (line S_female yydx, sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
       (line S_male yydx, sort lpattern(dash) lwidth(medthick) lcolor(blue)) /// 
                 , ysize(8) xsize(11) ///
                 ylabel(,angle(h) format(%3.2f)) ///
                 ytitle("5-year survival (age-standardised)") name("approach2", replace) ///
                 xtitle("Year of diagnosis") ylabel(0.5 0.6 0.7 0.8 0.9, labsize(*1.0) angle(0)) yscale(range(0.5 0.9)) ///
				 legend(label(1 "women") label(2 "men") ring(0) position(6) col(1))			 

exit

**************************** END OF FILE **********************************************************************



				 

