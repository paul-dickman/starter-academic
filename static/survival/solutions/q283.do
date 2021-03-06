
//==================//
// EXERCISE 283
// REVISED MAY 2015
//==================//


/* a) Clear Stata and set up the basic data */
clear

set obs 1000

gen agediag=floor(rnormal(60,13))
gen yydx=1990
gen sex=1
egen agegrp=cut(agediag), at(0 45 55 65 75 110) icodes
ta agegrp, gen(agegrp)

/* This histogram will be different each time you run the code as we are
making random draws from a normal distribution. */ 
hist agediag, freq discrete width(1)


/* (b) Simulate the cause-specific time */

/* Note that survsim takes ln hazard ratios as an input */
survsim timerel, lambdas(0.2) gammas(0.5) ///
covariates(agegrp1 `=ln(0.8)' agegrp2 `=ln(0.9)' agegrp3 `=ln(1)' ///
agegrp4 `=ln(1.2)' agegrp5 `=ln(1.4)')


twoway  (function y=exp(-0.2*0.8*x^0.5), range(0 5)) ///
		(function y=exp(-0.2*0.9*x^0.5), range(0 5)) ///
		(function y=exp(-0.2*1*x^0.5), range(0 5)) ///
		(function y=exp(-0.2*1.2*x^0.5), range(0 5)) ///
		(function y=exp(-0.2*1.4*x^0.5), range(0 5)), ///
		legend(ring(0) cols(1) position(5) order(1 "Age 0-44" 2 " Age 45-54" 3 ///
		"Age 56-64" 4 "Age 65-74" 5 "Age 75+")) ///
		ylabel(0(0.2)1,angle(h) format(%2.1f)) ytitle("Cause-specific Survival") ///
		xtitle("Time since diagnosis (years)")


/* (c) Simulate the other-cause time */
gen _age=.
gen _year=.

forvalues i=0/4 {
	capture drop _merge prob rate
	replace _age=min(agediag+`i',99)
	replace _year=yydx+`i'
	quietly merge m:1 _age _year sex using popmort, keep(matched master)
	gen timeback`i'=(-log(runiform()))/(-ln(prob))
	replace timeback`i'=1 if timeback`i'>=1
}
	

	
gen timeback=.

forvalues i=0/4 {
	quietly replace timeback=timeback`i'+`i' if timeback`i'<1 & timeback==.
}

drop timeback? _age _year _merge rate

/*(d) Create the all-cause time and stset */

gen time=min(timeback,timerel)	

generate died = time <= 5
replace time = 5 if died == 0

stset time, failure(died = 1)

/* (e) Perform analysis on simulated data */

gen _age = min(int(agediag + _t),99)
gen _year = int(yydx + _t)

quietly merge m:1 _age _year sex using popmort, keep(matched master)

stpm2 ib2.agegrp, bhaz(rate) df(5) scale(hazard) ///
 eform
 
/* These HRs may not be too close to those used in 
data generation in every single run. Try increasing
the observation number to see the effect. */ 




/* Below is a program that we can then use to run 
a full simulation using simulate. This does 
exactly the same as above, but is more general. */

capture program drop relsurvsim
program define relsurvsim, rclass

syntax, hazratio(numlist ascending min=5 max=5) [ obs(integer 1000) ///
gamma(real 0.5) lambda(real 0.2) meanage(real 60) ///
sdage(real 13) ]

clear

set obs `obs'

gen agediag=floor(rnormal(`meanage',`sdage'))
gen yydx=1990
egen agegrp=cut(agediag), at(0 45 55 65 75 110) icodes

ta agegrp, gen(agegrp)

survsim timerel, lambdas(`lambda') gammas(`gamma') ///
covariates(agegrp1 `=ln(`:word 1 of `hazratio'')' agegrp2 `=ln(`:word 2 of `hazratio'')' agegrp3 `=ln(`:word 3 of `hazratio'')' ///
agegrp4 `=ln(`:word 4 of `hazratio'')' agegrp5 `=ln(`:word 5 of `hazratio'')')

gen _age=agediag
gen _year=yydx

gen sex=1

quietly merge m:1 _age _year sex using popmort, keep(matched master)

gen timeback0=(-log(runiform()))/(-ln(prob))
replace timeback0=1 if timeback0>=1

forvalues i=1/4 {
	capture drop _merge prob
	replace _age=min(agediag+`i',99)
	replace _year=yydx+`i'
	quietly merge m:1 _age _year sex using popmort, keep(matched master)
	gen timeback`i'=(-log(runiform()))/(-ln(prob))
	replace timeback`i'=1 if timeback`i'>=1
}
	

	
quietly gen timeback=timeback0 if timeback0<1

forvalues i=1/4 {
	quietly replace timeback=timeback`i'+`i' if timeback`i'<1 & timeback==.
}

drop timeback? _age _year _merge rate

gen time=min(timeback,timerel)	

generate died = time <= 5
replace time = 5 if died == 0

stset time, failure(died = 1)

gen _age = min(int(agediag + _t),99)
gen _year = int(yydx + _t)

quietly merge m:1 _age _year sex using popmort, keep(matched master)

stpm2 ib2.agegrp, bhaz(rate) df(5) scale(hazard) ///
 eform

return scalar agegrp0=exp(_b[0.agegrp])
return scalar agegrp1=exp(_b[1.agegrp])
return scalar agegrp2=exp(_b[2.agegrp])
return scalar agegrp3=exp(_b[3.agegrp])
return scalar agegrp4=exp(_b[4.agegrp])

end


/* We now use the program above and run it 
1000 times. This will take a couple of minutes
to run. */ 

simulate agegrp0=r(agegrp0) agegrp1=r(agegrp1) /// 
agegrp2=r(agegrp2) agegrp3=r(agegrp3) ///
agegrp4=r(agegrp4), reps(1000): relsurvsim, obs(1000) hazratio(0.8 0.9 1 1.2 1.4)


su *
