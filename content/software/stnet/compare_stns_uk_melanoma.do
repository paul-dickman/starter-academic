/***************************************************************************
*** THIS IS WORK IN PROGRESS ***

This code available at:
http://pauldickman.com/software/stnet/compare_stns_uk_melanoma.do

Comments available at:
http://pauldickman.com/software/stnet/compare_stns/

Compare estimates of net survival (Pohar Perme) between stnet, strs, and stns
using the English melanoma data from the LSHTM CSG short course (data is
available to short course participants at the short course home page).

Paul Dickman, July 2019
***************************************************************************/

cd C:\svn_cansurv\pauld\london\practical\stns\

// Modify the life table (stns requires days as the time unit)
use Lifetable_2013, clear
gen double rate_day=rate/365.25
label variable rate_day "Expected mortality rate per day"
replace _age=_age*365.25
label variable _age "Age in days"
gen yearindays=mdy(1,1,_year)
label variable yearindays "Year as a Stata date (days since 1-1-1960)"
save Lifetable_2013_stns, replace

// MAIN ANALYSIS
use melanoma_2013, clear
sample 10 // Work with a 10% sample to save time
gen agediagindays=(diagmdy-birthmdy)

// Using stns
// stset with time in days
stset ftime, failure(dead==1) id(id)
stns list using Lifetable_2013_stns.dta,age(agediagindays=_age) ///
period(diagmdy=yearindays) strata(sex dep) rate(rate_day) ///
at(1(1)10, scalefactor(365.25) method(step))

// Using strs
// stset with time in years
stset finmdy, failure(dead==1) origin(diagmdy) scale(365.24) id(id)
strs using Lifetable_2013, br(0(.08333333)10) mergeby(_year sex _age dep) ///
    diagage(agediag) diagyear(ydiag) pohar notables save(replace)

use grouped, clear
list end n d cr_e2 cns_pp lo_cns_pp hi_cns_pp if inlist(end,5,10)
