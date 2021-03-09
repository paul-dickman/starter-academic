
//==================//
// EXERCISE 280
// REVISED MAY 2015
//==================//

// Code for tranforming data from human mortality database (http://www.mortality.org/)
// into a 'popmort' file for use with -strs-.

// 1. Start by downloading 'period death rates' 1x1 from HMD and saving them to a text file.

// The top of the file will look something like this
//   Sweden, Death rates (period 1x1)     Last modified: 16-Aug-2011, MPv5 (May07)
//
//   Year      Age       Female       Male         Total
//   1751        0     0.212235     0.241105     0.226774 
//   1751        1     0.049412     0.052949     0.051169 
//   1751        2     0.032247     0.034587     0.033409  

// 2. Remove the first 3 rows (the headers)

// 3. Replace '110+' with '110 ' 

// 4. If you only have rates up to, e.g., 2011 and need rates for later
//    years then copy and paste.

// 5. Run the code below to create the popmort file.

// 6. Check that everything looks sensible by, for example, looking at graphs and
//    examining the data in the file.

infile _year _age female male total using ///
  "death_rates_Sweden_2011_from_mortality_org.txt" ///
  if (_year > 1949 & _age < 100), clear
drop total
rename male rate1
rename female rate2
reshape long rate, i(_year _age)
rename _j sex
gen prob=exp(-rate)
sort _year  sex  _age
label data "Swedish death rates from http://www.mortality.org/"
label variable rate "Death rate (deaths/year)"
label variable prob "1-year survival probability"
label variable _year "Year of death"
label variable _age "Age"
label variable sex "Sex"
compress
save popmort_sweden_2011, replace

// Plot the age-specific rates by sex for 2009
twoway (line rate _age if sex==1 & _year==2009 & _age < 105, sort) ///
       (line rate _age if sex==2 & _year==2009 & _age < 105, sort), ///
	   yscale(log) ylabel(0.001 0.01 0.1 0.4) ///
	   legend(order(1 "Male" 2 "Female") ring(0)) ///
	   name(rates_by_sex,replace)
	   
// Plot the trends in age-specific rates for males
twoway (line rate _year if sex==1 &_age==0, sort) ///
       (line rate _year if sex==1 &_age==40, sort) ///
       (line rate _year if sex==1 &_age==60, sort) ///
       (line rate _year if sex==1 &_age==80, sort) ///
       (line rate _year if sex==1 &_age==90, sort) ///
	   , ///
	   yscale(log) ylabel(0.001 0.01 0.1 0.4) ///
	   legend(order(1 "age 0" 2 "age 40" 3 "age 60" 4 "age 80" 5 "age 90") ring(1)) ///
	   name(rates_by_year,replace)
	   

	   

