
//==================//
// EXERCISE 282
// REVISED MAY 2015
//==================//

/* (a) Load melanoma data and produce life tables by age group and sex */
use melanoma, clear
keep if year8594 == 1
stset surv_mm, fail(status==1 2) id(id) scale(12)
set trace off
strs using popmort, br(0(1)5) mergeby(_year sex _age) by(agegrp sex) save(replace)

use grouped, clear
keep start end n cp cp_e2 cr_e2 sex agegrp

/* (b) Five year relative survival by age group and sex */
list agegrp sex cr_e2 if end == 5, noobs sepby(agegrp)

/* (c) Reshape the data from long to wide format */
bysort sex (agegrp start): gen j = _n
gen sexlab =cond(sex==1,"_m","_f")
drop sex
reshape wide start end n cp cp_e2 cr_e2 agegrp, i(j) j(sexlab) string
rename agegrp_m agegrp
rename start_m start
rename end_m end
drop agegrp_f start_f end_f

/* (d) Number of cases per year */
bys agegrp: gen Nrisk_m = n_m[1]/10

gen p_dead_m = 1 - cp_e2_m * cr_e2_m
gen Nd_m = Nrisk_m*p_dead_m  
gen NExp_d_m = Nrisk_m*(1-cp_e2_m)
gen ED_m = Nd_m - NExp_d_m

format Nd_m NExp_d_m ED_m %4.1f
list agegrp Nrisk_m p_dead_m Nd_m NExp_d_m ED_m if end==5, noobs

table agegrp if end == 5, c(sum Nd_m sum NExp_d_m sum ED_m) row format(%4.1f)

/* (e) Repeat calculations for females */
bys agegrp: gen Nrisk_f = n_f[1]/10
gen p_dead_f = 1 - cp_e2_f * cr_e2_f
gen Nd_f = Nrisk_f*p_dead_f  
gen NExp_d_f = Nrisk_f*(1-cp_e2_f)
gen ED_f = Nd_f - NExp_d_f

format Nd_f NExp_d_f ED_f %4.1f
list agegrp Nrisk_f p_dead_f Nd_f NExp_d_f ED_f if end==5, noobs

table agegrp if end == 5, c(sum Nd_f sum NExp_d_f sum ED_f) row format(%4.1f)


/* (f) Calculate avoidable deaths */
gen Nd_m_f = Nrisk_m*(1 - cp_e2_m * cr_e2_f)
gen AD_m = Nd_m - Nd_m_f

format Nd_m_f AD_m %4.1f
list agegrp Nrisk_m p_dead_m Nd_m NExp_d_m ED_m Nd_m_f AD_m if end==5, noobs

/* (g) Avoidable Deaths */
list agegrp end AD_m if agegrp==3


