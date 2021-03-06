/***************************************************************************
This code available at:
http://pauldickman.com/software/stata/age-standardise-nonparametric.do

The tutorial based on this code is available at:
http://pauldickman.com/software/stata/age-standardise-nonparametric/

Age-standardised net survival using non-parametric 
methods (Ederer II and Pohar Perme) and ICSS weights. 

Paul Dickman, March 2019
***************************************************************************/
set more off
use http://pauldickman.com/data/colon.dta if stage == 1, clear

// Reclassify age groups according to International Cancer Survival Standard 
drop agegrp
label drop agegrp
egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
label variable agegrp "Age group"
label define agegrp 1 "15-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+" 
label values agegrp agegrp

/* Specify weights for each agegroup */
recode agegrp (1=0.07) (2=0.12) (3=0.23) (4=0.29) (5=0.29), gen(ICSSwt)

stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)

strs using http://pauldickman.com/data/popmort [iw=ICSSwt], ///
    breaks(0(1)10) mergeby(_year sex _age) diagage(age) ///
    by(sex) standstrata(agegrp) pohar f(%7.5f) 
	 
	 



