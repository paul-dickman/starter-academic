/***************************************************************************
This code available at http://pauldickman.com/software/stnet/comparestrs.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stnet/comparestrs/

The data are available at: http://pauldickman.com/survival/

Note: -stnet- runs much faster if the popmort file is downloaded
      and stored locally.

Paul Dickman, March 2019
***************************************************************************/

use http://pauldickman.com/data/colon.dta if stage==1, clear

// stnet requires date of birth
generate birthdate=dx-age*365.241

// stnet uses date of diagnosis as a decimal
// yydx is an integer, so need to replace this with a decimal 
// so both commands use the same value of year of diagnosis (i.e., a decimal)
replace yydx = 1960 + dx/365.241

stset exit, origin(dx) fail(status==1,2) id(id) scale(365.24)

stnet using http://pauldickman.com/data/popmort.dta, ///
 breaks(0(.083333333)10) diagdate(dx) birthdate(birthdate) ederer ///
 list(n d cre2 cns locns upcns secns) listyearly mergeby(_year sex _age)
 
strs using http://pauldickman.com/data/popmort.dta, ///
     breaks(0(.083333333)10) mergeby(_year sex _age) notables ///
     ht pohar list(n d cr_e2 cns_pp lo_cns_pp hi_cns_pp) save(replace)
	 
preserve
use grouped, clear
list end n d cr_e2 cns_pp lo_cns_pp hi_cns_pp if floor(end)==end

// AGE-SPECIFIC ESTIMATES
// back to the patient data
restore

strs using http://pauldickman.com/data/popmort.dta, ///
     breaks(0(.083333333)10) mergeby(_year sex _age) by(agegrp) notables ///
     ht pohar list(n d cr_e2 cns_pp lo_cns_pp hi_cns_pp) save(replace)

use grouped, clear
list agegrp end n d cr_e2 cns_pp lo_cns_pp hi_cns_pp if floor(end)==end





