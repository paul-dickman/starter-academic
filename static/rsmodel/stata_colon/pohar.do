************************************************************************
* POHAR.DO
*
* Calculate relative/net survival using the Pohar Perme approach and 
* compare with Ederer II and Hakulinen estimates.
*
* Paul Dickman (paul.dickman@ki.se)
* Nov 2013 v1.0
*
*************************************************************************
set more off
clear all

use colon if stage==1, clear
stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)
gen long potfu = date("31/12/1995","DMY")

/*****************************/
/**** Cohort estimates *******/

/* Without ht option (survival is estimated using actuarial approach) */
strs using popmort, br(0(1)20) mergeby(_year sex _age) by(year8594) ///
     list(start end n d cr_e2 lo_cr_e2 hi_cr_e2 cr_hak cns_pp lo_cns_pp hi_cns_pp) ///
	 pohar potfu(potfu) save(replace)

/* With ht option (survival is estimated by transforming the cumulative hazard) */
strs using popmort, br(0(1)20) mergeby(_year sex _age) by(year8594) ht ///
     list(start end n d cr_e2 lo_cr_e2 hi_cr_e2 cr_hak cns_pp lo_cns_pp hi_cns_pp) ///
	 pohar potfu(potfu) save(replace)

/*****************************/
/**** Period estimates *******/
stset exit, origin(dx) enter(time mdy(1,1,1992)) exit(time mdy(12,31,1994)) ///
         failure(status==1 2) id(id) scale(365.24)

/* Without ht option (should be same as with ht since we have late entry) */
strs using popmort, br(0(1)20) mergeby(_year sex _age) by(year8594) ///
     list(start end n d cr_e2 lo_cr_e2 hi_cr_e2 cr_hak cns_pp lo_cns_pp hi_cns_pp) ///
	 pohar potfu(potfu) save(replace)
	 
/* With ht option */
strs using popmort, br(0(1)20) mergeby(_year sex _age) by(year8594) ht ///
     list(start end n d cr_e2 lo_cr_e2 hi_cr_e2 cr_hak cns_pp lo_cns_pp hi_cns_pp) ///
	 pohar potfu(potfu) save(replace)

exit	 
	 



