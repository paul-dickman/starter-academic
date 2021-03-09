
//==================//
// EXERCISE 240
// REVISED MAY 2015
//==================//

use melanoma, clear
keep if stage==1 /* restrict to localised */
stset surv_mm, fail(status==1 2) id(id) scale(12)

/* (a) Crude estimates */
strs using popmort, br(0(1)15) mergeby(_year sex _age) ///
  list(n d w cr_e2 se_cp)

/* (b) Age-specific estimates */
strs using popmort, br(0(1)15) mergeby(_year sex _age) by(agegrp) ///
  list(n d w cr_e2 se_cp) save(replace)

/* Age-standardised 10-year RSR 'by hand' */
use grouped, clear
bysort agegrp: gen n0=n[1]
summ n0 if end == 1
local N `r(sum)'
gen weight=n0/`N'
gen x=cr_e2*weight
list agegrp n0 cr_e2 weight x if end==10, sum(n0 weight x) mean(cr_e2)

/* (c) Age-standardised using traditional approach implemented with iweights */
use melanoma, clear
keep if stage==1 /* restrict to localised */
stset surv_mm, fail(status==1 2) id(id) scale(12)

local totalobs = _N
bysort agegrp: gen standwei = _N/`totalobs'

strs using popmort [iw=standwei], br(0(1)15) mergeby(_year sex _age) ///
 list(n d w cr_e2 se_cp) standstrata(agegrp) 

/* (d) Age-standardised using alternative (Brenner) approach implemented with iweights */
strs using popmort [iw=standwei], br(0(1)15) mergeby(_year sex _age) ///
 list(n d w cr_e2 se_cp) standstrata(agegrp) brenner


/* part (e) omitted. */
use melanoma if stage==1, clear
stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)

gen long potfu = date("31/12/1995","DMY")
gen standwei=agegrp
recode standwei 0=.2751034 1=.296164 2=.2888304 3=.1399022

strs using popmort [iw=standwei], br(0(1)10) 	mergeby(_year sex _age) ///
	list(start end n d d_star p_star w cr_e1 cr_e2 cr_hak) ///
	ederer1 potfu(potfu) pohar standstrata(agegrp) save(replace) 


/* (f) Pohar Perme estimate */
use melanoma if stage==1, clear
stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)
strs using popmort, ///
	br(0(`=1/12')10) ///
	mergeby(_year sex _age) ///
	pohar save(replace) notables

use grouped, clear
list start end cr_e2 cns_pp if mod(end,1)==0, noobs

twoway	(line cr_e2 end, lcolor(black)) ///
		(line cns_pp end, lcolor(red)) ///
		, xtitle("Years since diagnosis") ///
		ytitle("Relative Survival") ///
		ylabel(0.7(0.05)1, angle(h) format(%3.2f)) ///
		legend(order(1 "Ederer 2" 2 "Pohar Perme") ring(0) pos(1) cols(1))

		
