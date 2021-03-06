/***************************************************************************
This code available at http://pauldickman.com/software/stnet/compare_stns.do
*** THIS IS WORK IN PROGRESS ***

Comments available at:
http://pauldickman.com/software/stnet/compare_stns/

Compare estimates of net survival (Pohar Perme) between stnet, strs, and stns
using the colon cancer data. 

Paul Dickman, July 2019
***************************************************************************/

// Modify the life table to include variables required by -stns- 
use popmort.dta, clear
gen double rate_day=rate/365.25
label variable rate_day "Expected mortality rate per day"
generate _agedays=_age*365.25
label variable _agedays "Age in days"
gen yearindays=mdy(1,1,_year)
label variable yearindays "Year as a Stata date (days since 1-1-1960)"
sort _year sex _age
save popmort_stns, replace

use colon.dta if stage==1, clear

// stnet requires date of birth
generate birthdate=dx-age*365.241

// stnet calculates date of diagnosis as an interger
// use this in strs to match
replace yydx = 1960 + dx/365.241

stset exit, origin(dx) fail(status==1,2) id(id) scale(365.24)

// STNET
stnet using popmort_stns, ///
 breaks(0(.083333333)10) diagdate(dx) birthdate(birthdate) ederer ///
 list(n d cre2 cns locns upcns secns) listyearly mergeby(_year sex _age)
 
// STRS
strs using popmort_stns, ///
     breaks(0(.083333333)10) mergeby(_year sex _age) notables ///
     ht pohar list(n d cr_e2 cns_pp lo_cns_pp hi_cns_pp) save(replace)
	 
preserve
use grouped, clear
list end n d cr_e2 cns_pp lo_cns_pp hi_cns_pp if floor(end)==end
restore

// STNS
generate agediagindays=(dx-birthdate)
stset exit, origin(dx) fail(status==1,2) id(id)

stns list using popmort_stns, age(agediagindays=_agedays) ///
period(dx=yearindays) strata(sex) rate(rate_day) ///
at(1(1)10, scalefactor(365.24) method(step))



