************************
******QUESTION 1********
************************

//See written solutions.

************************
******QUESTION 2********
************************

use bladder_5year if A5>35 & sex==0, clear

**(a)**

//Basic tabulation of the incidence rates
table A5 P5, contents(sum rate) format(%3.1f)


**(b)**

//Local macros to define the graphs - unique values of A5
levelsof A5, local(agevalues)
global agevalues `agevalues'

/* Period-Age Plot */
local i 1
local hsv
foreach a of global agevalues {
	local hsv hsv `=60 + `i'*30' 1 1
	local linesPA `linesPA' (connect rate P5 if A5==`a', sort msize(*0.7) mcolor("`hsv'") lcolor("`hsv'"))
	local legPA  `legPA' `i' "`=`a'-2.5'-`=`a'+2.5'"
	local i = `i' + 1
}

twoway `linesPA', ///
	ytitle("Rate (per 100,000 person-years)")  ///
	title("Rate by Period for Various Age Groups") ///
	xtitle("Period (5-Year Categories)") ///
	ylabel(1 2 5 10 20 50 100 200 400,angle(h)) yscale(log) ///
	legend(order(`legPA') cols(4) symxsize(*0.5)) ///
	xscale(range(1950 2010)) ///
	legend(cols(5)) ///
	name(rateplotPA, replace) 


/* Cohort Age Plot */
local i 1
local hsv
foreach a of global agevalues {
	local hsv hsv `=60 + `i'*30' 1 1
	local linesCA `linesCA' (connect rate C5 if A5==`a', sort msize(*0.7) mcolor("`hsv'") lcolor("`hsv'"))
	local legCA  `legCA' `i' "`=`a'-2.5'-`=`a'+2.5'"
	local i = `i' + 1
}

twoway `linesCA', ///
	ytitle("Rate (per 100,000 person-years)")  ///
 title("Rate by Birth Cohort for Various Age Groups") ///
	xtitle("Cohort (10-Year Categories)") ///
	ylabel(1 2 5 10 20 50 100 200 400,angle(h)) yscale(log) ///
	legend(order(`legCA') cols(5) symxsize(*0.5)) ///
	name(rateplotCA, replace)
	
	
grc1leg rateplotPA  rateplotCA, altshrink

	

	

**(c)**
	

// Need integers for modelling in Stata
gen A5model=A5-2.5
gen P5model=P5-2.5
gen C5model=C5


glm D ibn.A5model ib1925.C5model if sex==0, lnoffset(Y) ///
 family(poisson) nocons nolog eform base	
 
 
 
	
**(d)**

di "`=exp(_b[65.A5model])*100000'"


**(e)**	
di "`=exp(_b[1940.C5model])'"


**(f)**


di "`=exp(_b[70.A5model])*exp(_b[1950.C5model])*100000'"


**(g)**

// predict rates
predictnl ratesmodmalesAC=100000*exp(xb())

//Plot predicted values

local i 1
local hsv
local linesCA
foreach a of global agevalues {
	local hsv hsv `=60 + `i'*30' 1 1
	local linesCA `linesCA' (connect ratesmodmalesAC C5 if A5==`a', sort msize(*0.7) mcolor("`hsv'") lcolor("`hsv'"))
	local legCA  `legCA' `i' "`=`a'-2.5'-`=`a'+2.5'"
	local i = `i' + 1
}

twoway `linesCA', ///
	ytitle("Rate (per 100,000 person-years)")  ///
 title("Rate by Birth Cohort for Various Age Groups") ///
	xtitle("Cohort (10-Year Categories)") ///
	ylabel(1 2 5 10 20 50 100 200 400,angle(h)) yscale(log) ///
	legend(order(`legCA') cols(5) symxsize(*0.5)) ///
	name(rateplotCApred, replace) scheme(sj)
 


**(h)**

glm D ibn.A5model C5model if sex==0, lnoffset(Y) ///
 family(poisson) nocons nolog eform base	
 
predictnl ratesmodmalesAdrift=100000*exp(xb())


local i 1
local hsv
local linesCA
foreach a of global agevalues {
	local hsv hsv `=60 + `i'*30' 1 1
	local linesCA `linesCA' (connect ratesmodmalesAdrift C5 if A5==`a', sort msize(*0.7) mcolor("`hsv'") lcolor("`hsv'"))
	local legCA  `legCA' `i' "`=`a'-2.5'-`=`a'+2.5'"
	local i = `i' + 1
}

twoway `linesCA', ///
	ytitle("Rate (per 100,000 person-years)")  ///
 title("Rate by Birth Cohort for Various Age Groups") ///
	xtitle("Cohort (10-Year Categories)") ///
	ylabel(1 2 5 10 20 50 100 200 400,angle(h)) yscale(log) ///
	legend(order(`legCA') cols(5) symxsize(*0.5)) ///
	name(rateplotAdriftpred, replace) scheme(sj)
	
	
	
	
************************
******QUESTION 3********
************************	

**(a)**
clear all
use bladder if A>35 & sex==0, clear


**(b)**
apcfit,  dfa(8) dfp(8) age(A) per(P) cases(D) pop(Y) param(AP) /// 
refp(1982.5) agef(agefittedAPmales) perf(perfittedAPmales) nper(100000)


**(c)/(d)**
  tw rarea agefittedAPmales_lci agefittedAPmales_uci A, sort color(orange) fi(20) || ///
line agefittedAPmales A, sort yscale(log range(0.5 400)) lcolor(cranberry) ///
 name(APagemales,replace) ylabel( 1 2 5 10 50 200 400 ,angle(h)) ///
  legend(off) xtitle("Age") ///
  title("Age") ytitle("Rate per 100,000 person-years")


 tw rarea perfittedAPmales_lci perfittedAPmales_uci P, sort color(eltgreen) fi(20) || ///
line perfittedAPmales P, sort yscale(log range(0.2 1.4)) lcolor(emerald) ///
 name(APpermales,replace)  ylabel(0.2(0.2)1.4,angle(h) format(%2.1f)) ///
  legend(off) xtitle("Calendar Time") xscale(range(1950 2010))  ///
  title("Period") xlabel(1950(20)2010) ytitle("Rate Ratio", orientation(rvertical)) yscale(alt) ///
|| scatteri 1 1982.5, msymbol(Oh) mcolor(emerald)

  
  graph combine APagemales APpermales, rows(1) name("APmales", replace) ///
  scheme(sj) common

  
  
  
  	
************************
******QUESTION 4********
************************	
	
  
  
  
 **(a)**
clear all
use bladder if A>35 & sex==0, clear
  
*4) Age-Period-Cohort model splines. 
  
*Males ACP model - drift assigned to cohort  
 **(a)**
  
  apcfit, age(A) per(P) cases(D) pop(Y) param(ACP) dfa(8) dfp(8) dfc(8) ///
 agef(agefACPmales) perf(perfACPmales) cohf(cohfACPmales) nper(100000) refc(1927.5) 
 
 
*Plot the results
 
twoway          (rarea perfACPmales_uci perfACPmales_lci P, sort pstyle(ci) color(eltgreen) fintensity(inten50)) ///
                         (line perfACPmales P, sort lc(emerald) clpattern(solid)) ///
                         (rarea cohfACPmales_uci cohfACPmales_lci C, sort pstyle(ci)  color(eltblue) fintensity(inten50)) ///
                         (line cohfACPmales C, sort lc(edkblue) clpattern(solid)) ///
				(scatteri 1 1927.5, msymbol(Oh) mcolor(edkblue)) ///
                         , xlabel(1890(20)2010) name(PCACPmales,replace) xscale(range(1870 2010)) legend(off) ///
                         xtitle("Calendar Time") title("CP") ytitle("Rate Ratio", orientation(rvertical)) yscale(alt) yscale(log range(0.2 3.6)) ylabel(0.5(0.5)2.5 4 6 10,angle(h) format(%2.1f))  scheme(sj)

 
twoway          (rarea agefACPmales_uci agefACPmales_lci A, sort pstyle(ci) color(orange) fintensity(inten50) ) ///
                        (line agefACPmales A, sort lcolor(cranberry) clpattern(solid)) ///
                  , yscale(log range(0.5 800))  name(AACPmales,replace) legend(off) ///
                         ylabel( 1 2 5 10 50 200 400 800, angle(h)) ///
                         xtitle("Age") title("Age") ytitle("Rate per 100,000 person-years") scheme(sj)

***Combine the two Graphs**
graph combine AACPmales PCACPmales, nocopies  ///
common scheme(sj) name(ACPmales, replace)



*Males APC model - drift assigned to period

**(b)**
apcfit if sex==0,  dfa(8) dfp(8) dfc(8) age(A) per(P) cases(D) pop(Y) param(APC) ///
 agef(agefAPCmales) perf(perfAPCmales) cohf(cohfAPCmales) nper(100000) refp(1982.5)
 
 
twoway          (rarea cohfAPCmales_uci cohfAPCmales_lci C, sort pstyle(ci)  color(eltblue) fintensity(inten50)) ///
                         (line cohfAPCmales C, sort lc(edkblue) clpattern(solid)) ///
						 (rarea perfAPCmales_uci perfAPCmales_lci P, sort pstyle(ci) color(eltgreen) fintensity(inten50)) ///
                         (line perfAPCmales P, sort lc(emerald) clpattern(solid)) ///    
				(scatteri 1 1982.5, msymbol(Oh) mcolor(emerald)) ///
                         , xlabel(1890(20)2010) name(PCAPCmales,replace) xscale(range(1870 2010)) legend(off) ///
                         xtitle("Calendar Time") title("PC") ytitle("Rate Ratio", orientation(rvertical)) yscale(alt) yscale(log range(0.2 3.6)) ylabel(0.5(0.5)2.5 4 6 10,angle(h) format(%2.1f))  ///
						 scheme(sj)

 
twoway          (rarea agefAPCmales_uci agefAPCmales_lci A, sort pstyle(ci) color(orange) fintensity(inten50) ) ///
                        (line agefAPCmales A, sort lcolor(cranberry) clpattern(solid)) ///
                  , yscale(log range(0.5 800))  name(AAPCmales,replace) legend(off) ///
                         ylabel( 1 2 5 10 50 200 400 800, angle(h)) ///
                         xtitle("Age") title("Age") ytitle("Rate per 100,000 person-years") scheme(sj)

***Combine the two Graphs**
graph combine AAPCmales PCAPCmales, nocopies scheme(sj) ///
 name(APCmales, replace) common
 
 
 
	
************************
******QUESTION 5********
************************	



*5) Number of knots.

*Testing different degrees of freedom for the AP model

**(a)**
clear all
use bladder if A>35 & sex==0, clear


 estimates clear

forvalues dfa=3/10 {
	forvalues dfp=3/10 {

	*Age-Period model, males
	apcfit if sex==0,  dfa(`dfa') dfp(`dfp')  age(A) per(P) cases(D) pop(Y) param(AP) refp(1982.5) ///
 nper(100000) agef(agef`dfa'`dfp') perf(perf`dfa'`dfp')

	estimates store APbladder_dfa`dfa'_dfp`dfp'
	}
}

**Use appropriate N for BIC calculation - sum of cases
sum D if sex==0
local totD=r(sum)

*List results for a selection
estimates stats APbladder_dfa3_dfp3 APbladder_dfa5_dfp5 APbladder_dfa7_dfp7 ///
APbladder_dfa10_dfp10 APbladder_dfa4_dfp9, n(`totD')

*Plot results for a selection
line perf53 perf55 perf57 perf510 P, sort yscale(log range(0.2 1.4)) ///
 name(APpermales,replace) lcolor(maroon navy black forest_green)  ylabel(0.2(0.2)1.4,angle(h) format(%2.1f)) /// xtitle("Calendar Time") xscale(range(1950 2010))  ///
  title("Period") xlabel(1950(20)2010) ytitle("Rate Ratio", orientation(rvertical)) yscale(alt) ///
|| scatteri 1 1982.5, msymbol(Oh) mcolor(emerald) scheme(sj) legend(order(1 "3 df" 2 "5 df" 3 " 7 df" 4 "10 df"))


		
	
 
