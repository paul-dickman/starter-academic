
/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/four-methods-nonparametric.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/four-methods-nonparametric/

Estimate relative/net survival using four difference approaches
(Ederer I, Ederer II, Hakulinen, Pohar Perme) 

Paul Dickman, March 2019
***************************************************************************/
set more off
use http://pauldickman.com/data/colon.dta if stage == 1, clear

stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)
gen long potfu = date("31/12/1995","DMY")
strs using popmort, br(0(1)20) mergeby(_year sex _age) by(year8594) ///
     list(start end n d w cr_e1 cr_e2 cr_hak cns_pp) pohar ederer1 potfu(potfu)

/* Now with shorter intervals, don't show the tables as we will draw a graph */
strs using popmort, br(0 0.01 0.25(0.25)10) mergeby(_year sex _age) by(year8594) ///
     list(start end n d w cr_e1 cr_e2 cr_hak cns_pp) pohar ederer1 potfu(potfu) save(replace) notables
	 
/* Now graph the estimates */
use grouped if year8594==0, clear
twoway ///
(connected cr_e1 end, sort lwidth(medthick) msymbol(none) lpattern(dot)) ///
(connected cr_e2 end, sort lwidth(medthick) msymbol(none) lpattern(shortdash)) ///
(connected cr_hak end, sort lwidth(medthick) msymbol(none) lpattern(longdash)) ///
(connected cns_pp end, sort lwidth(medthick) msymbol(none) lpattern(solid)), ///
yti("Relative/net survival") yscale(range(0.6 1)) ///
ylabel(0.6(0.1)1, format(%3.1f)) title("Localised colon carcinoma diagnosed 1975-84") ///
xtitle("Years from diagnosis") xlabel(0(1)10) ysize(8) xsize(11) ///
legend(order(1 "Ederer I" 2 "Ederer II" 3 "Hakulinen" 4 "Pohar Perme") ring(0) pos(1) col(1))

graph export four-methods-nonparametric.svg, replace
