
//==================//
// EXERCISE 241
// REVISED MAY 2015
//==================//

use melanoma, clear
keep if stage == 1
stset surv_mm, fail(status==1 2) id(id) scale(12)

/*a*/
strs using popmort, br(0(1)10) mergeby(_year sex _age) by(year8594) ///
list(start end n d w cr_e2 lo_cr_e2 hi_cr_e2) save(replace)


/*b*/
strs using popmort , br(0(1)10) mergeby(_year sex _age) by(agegrp year8594) ///
save(replace)
use grouped, clear
bysort agegrp year8594: gen n0 = n[1]
bysort agegrp year8594: gen first = _n == 1
bysort year8594: egen N0 = total(n0*first)
gen weight=n0/N0


list n0 cr_e2 weight if end==10 & year8594==0 , sum(n0 weight ) mean(cr_e2)
display .3039627*0.8135 + .2955711*0.7604 + .2927739*0.7348 + .1076923*0.6422

list n0 cr_e2 if end==10 & year8594==1 , sum(n0) mean(cr_e2)
display .3039627*0.8374 + .2955711*0.8661 + .2927739*0.8726 + .1076923*0.8103 

/*c*/
use melanoma, clear
keep if stage==1 /* restrict to localised */
stset surv_mm, fail(status==1 2) id(id) scale(12)
gen standwei = agegrp
recode standwei 0=0.3039627 1=0.2955711 2=0.2927739 3=0.1076923
strs using popmort [iw=standwei], br(0(1)10) mergeby(_year sex _age) ///
standstrata(agegrp) by(year8594)

/*d*/
strs using popmort [iw=standwei], br(0(1)10) mergeby(_year sex _age) ///
standstrata(agegrp) by(year8594) brenner

/*e*/
strs using popmort [iw=standwei], br(0(`=1/12')10) mergeby(_year sex _age) ///
standstrata(agegrp) by(year8594) pohar savstand(pohar_q17,replace) notables
use pohar_q17, clear
list year8594 end cns_pp lo_cns_pp hi_cns_pp cr_e2 lo_cr_e2 hi_cr_e2 ///
	if mod(end,1)==0,noobs
