
//==================//
// EXERCISE 250
// REVISED MAY 2015
//==================//


/* (a) Load melanoma data and produce life tables by age group and sex 
using the cuminc option */
use melanoma, clear
keep if year8594 == 1
stset surv_mm, fail(status==1 2) id(id) scale(12)
set trace off
strs using popmort, br(0(1)5) mergeby(_year sex _age) by(agegrp sex) ///
	save(replace) cuminc list(n d w cp F cp_e2 cr_e2 ci_dc ci_do) f(%7.5f)

/* (c) similarity between F and ci_dc in youngest group */
use grouped, clear
list agegrp start end sex F ci_dc if agegrp == 0 & sex == 1, noobs
	
/* (d) Relationship between crude probability and all-cause probability */
list  end agegrp sex F ci_dc ci_do if  agegrp == 2 & end == 5
gen F2 = ci_dc + ci_do
list  end agegrp sex F ci_dc ci_do F2 if  agegrp == 2 & end == 5

/* (e) Proportion of deaths due to cancer and other causes */
gen prob_c = ci_dc / F
gen prob_o = ci_do / F
list  end agegrp sex F ci_dc ci_do prob_c prob_o ///
	if  end == 5 & sex == 1, noobs

/* (g) Plot overall, net and crude probability of death by age group. */
gen net = 1- cr_e2
twoway	(line F net ci_dc end if sex == 1, sort ), by(agegrp) ///
		legend(order(1 "Overall" 2 "Net" 3 "Crude") cols(3)) ///
		ylabel(0(0.1)0.6, angle(h) format(%3.1f)) ///
		ytitle("Probability of Death") 

		
		
