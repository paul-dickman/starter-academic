
//==================//
// EXERCISE 204
// REVISED MAY 2015
//==================//


/*Read in and stset the data*/
use melanoma if stage==1 & yydx<=1983, clear

/*Stset the data and make sure to only count person-time before 1984*/
stset exit, origin(dx) entry(dx) fail(status==1 2) id(id) ///
exit(time mdy(12,31,1983)) scale(365.24)


/* part b : traditional cohort estimates*/
strs using popmort if (yydx <=1983), ///
    br(0(1)15) mergeby(_year sex _age)

	
/* part c : traditional cohort estimates*/
strs using popmort if (1977 <= yydx) & (yydx <=1983), ///
    br(0(1)15) mergeby(_year sex _age)

	
/* part d : period estimates (period window 1 jan 1983 - 31 Dec 1983)*/
stset exit, origin(dx) enter(time mdy(1,1,1983)) ///
        exit(time mdy(12,31,1983)) ///
        failure(status==1 2) id(id) scale(365.24)
		
strs using popmort, br(0(1)15) mergeby(_year sex _age)


/* part e : period estimates (period window 1 jan 1982 - 31 Dec 1983)*/
stset exit, origin(dx) enter(time mdy(1,1,1982)) ///
        exit(time mdy(12,31,1983)) ///
        failure(status==1 2) id(id) scale(365.24)
		
strs using popmort, br(0(1)15) mergeby(_year sex _age)


/*part f : Actual relative survival estimates (patients diagnosed in 1983)*/
use melanoma if stage==1
stset exit, origin(dx) entry(dx) fail(status==1 2) id(id) scale(365.24)
strs using popmort if(yydx==1983), br(0(1)15) mergeby(_year sex _age)


/*part g : Actual relative survival estimates (patients diagnosed in 1984)*/
strs using popmort if(yydx==1984), br(0(1)15) mergeby(_year sex _age)



/*Part j : Calculate all measures of relative survival and plot them on the same graph*/

use melanoma, clear
keep if stage==1
set more off

capture postclose q19_est
postfile q19_est method year survival survival_lo survival_hi using q19_est , replace

forvalues i = 1981(1)1990 {

* Cohort estimates
	stset exit, origin(dx) entry(dx) fail(status==1 2) id(id) ///
				exit(time mdy(12,31,`i')) scale(365.24)

	strs using popmort if (yydx <=`i'), br(0(1)15) mergeby(_year sex _age) save(replace) notables

	preserve

	use grouped, clear
	keep if end == 5
	summ cr_e2 , meanonly
	local point = r(mean) 
	summ lo_cr_e2 , meanonly
	local lo = r(mean)
	summ hi_cr_e2 , meanonly
	local hi = r(mean)

	post q19_est (1) (`i') (`point') (`lo') (`hi')
	
	restore
	

* Period estimates
	stset exit, origin(dx) enter(time mdy(1,1,`i')) exit(time mdy(12,31,`i')) ///
				failure(status==1 2) id(id) scale(365.24)
		
	strs using popmort, br(0(1)15) mergeby(_year sex _age) notables save(replace)

	preserve

	use grouped, clear
	keep if end == 5
	summ cr_e2 , meanonly
	local point = r(mean) 
	summ lo_cr_e2 , meanonly
	local lo = r(mean)
	summ hi_cr_e2 , meanonly
	local hi = r(mean)

	post q19_est (2) (`i') (`point') (`lo') (`hi')

	restore
	
* Actual relative survival

	stset exit, origin(dx) entry(dx) fail(status==1 2) id(id) scale(365.24)

	strs using popmort if (yydx==`i'), br(0(1)15) mergeby(_year sex _age) notables save(replace)
	
	preserve

	use grouped, clear
	keep if end == 5
	summ cr_e2 , meanonly
	local point = r(mean) 
	summ lo_cr_e2 , meanonly
	local lo = r(mean)
	summ hi_cr_e2 , meanonly
	local hi = r(mean)

	post q19_est (3) (`i') (`point') (`lo') (`hi')
	restore
}

postclose q19_est


use  q19_est, clear

twoway (connected survival year if method == 1) ///
		(rcap survival_lo survival_hi year if method == 1), ///
		name(cohort, replace) title("Cohort") ///
		yscale(range(0.5(0.1)1)) ylabel(0.5(0.1)1) ytitle("5-year RS") xtitle(Year of diagnosis) ///
		legend(order(1 "Relative survival" 2 "95% Confidence interval"))
		
twoway (connected survival year if method == 2) ///
	   (rcap survival_lo survival_hi year if method == 2), ///
		name(period, replace) title("Period") ///
		yscale(range(0.5(0.1)1)) ylabel(0.5(0.1)1) ytitle("5-year RS") xtitle(Year of diagnosis) ///
		legend(order(1 "Relative survival" 2 "95% Confidence interval"))
		
twoway (connected survival year if method == 3) ///
	   (rcap survival_lo survival_hi year if method == 3), ///
		name(actual, replace) title("Actual") ///
		yscale(range(0.5(0.1)1)) ylabel(0.5(0.1)1) ytitle("5-year RS") xtitle(Year of diagnosis) ///
		legend(order(1 "Relative survival" 2 "95% Confidence interval"))
		
grc1leg cohort period actual,  cols(3) scale(0.9)
