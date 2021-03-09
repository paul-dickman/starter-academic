***********************************************************
* Stata code accompanying the video lecture:
*
* Introduction to survival analysis
*
* http://pauldickman.com/video/survival-intro/
*
* Paul Dickman
* April 2020
***********************************************************

cd "C:\www\pauldickman\content\video\survival-intro\"

clear all
input time status   x
   9     1    0
  13     1    0
  13     0    0
  18     1    0
  23     1    0
  28     0    0
  31     1    0
  34     1    0
  45     0    0
  48     1    0
 161     0    0
   5     1    1
   5     1    1
   8     1    1
   8     1    1
  12     1    1
  16     0    1
  23     1    1
  27     1    1
  30     1    1
  33     1    1
  43     1    1
  45     1    1
end

label data "Survival of patients with Acute Myelogenous Leukemia. From the R survival package."
label variable time "Time in months to death or censoring"
label variable status "Vital status; 1=dead, 0=censored"
label variable x "Treatment; 0=maintenence therapy, 1=no maintenence"

label define x 0 "Maintained" 1 "Nonmaintained"
label values x x

stset time, fail(status)

sts list

sts generate km=s

drop time status x

// Add an observation at time zero
expand 2 if _n==1
replace _t=0 if _n==_N
replace km=1 if _n==_N
replace _t=60 if _t==161
sort _t
duplicates drop _t, force

expand 2 if _n>1, generate(flag)
replace _t=_t-0.05 if flag

sort _t
replace km=km[_n-1] if flag

list

format km %6.1f

twoway line km _t if _t < 60, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival function, S(t)") xtitle("Time (months)") name("km", replace) ///
				 xlabel(0(6)60, labsize(*1.2)) xscale(range(0 60)) ylabel(0.0(0.1)1.0, labsize(*1.2)) yscale(range(0 1))
graph export km.pdf, replace	

format km %6.2f

twoway line km _t if _t < 5, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km5_", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km5_.pdf, replace	
	
twoway line km _t if _t <= 5, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km5", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km5.pdf, replace	
				 
twoway line km _t if _t < 8, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km8_", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km8_.pdf, replace	
				 
twoway line km _t if _t <= 8, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km8", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km8.pdf, replace	
				 
twoway line km _t if _t < 9, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km9_", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km9_.pdf, replace	
				 
twoway line km _t if _t <= 9, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km9", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km9.pdf, replace	

twoway line km _t if _t < 12, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km12_", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km12_.pdf, replace	
				 
twoway line km _t if _t <= 12, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km12", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km12.pdf, replace	

twoway line km _t if _t < 13, sort connect(stairstep) lpattern(solid) lwidth(medthick) ///
                 , scheme(plotplain) ysize(9) xsize(16) ///
                 ytitle("Survival") xtitle("Time in months") name("km13_", replace) ///
				 xlabel(0(1)15, labsize(*1.2)) xscale(range(0 15)) ylabel(0.7(0.05)1.0, labsize(*1.2)) yscale(range(0.7 1.0))
graph export km13_.pdf, replace	
