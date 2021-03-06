
//==================//
// EXERCISE 103
// REVISED MAY 2015
//==================//

/* Data set used */
use melanoma, clear

/* Stset */
stset surv_mm, failure(status==1)

/* Tabulate stage distribution */
tab stage

/* Survival and hazard function by stage */
sts graph, 	by(stage) name(surv_stage, replace) 
sts graph, 	hazard by(stage) name(haz_stage, replace) 
graph combine surv_stage haz_stage

/* Mortality rates */
strate stage

/* New stset */
stset surv_mm, failure(status==1) scale(12)

/* Mortality rates per 1000 pyrs*/
strate stage, per(1000)

/* Survival and hazard function by sex */
sts graph, 	by(sex) name(surv_sex, replace) 
sts graph, 	hazard by(sex) name(haz_sex, replace) 			
graph combine surv_sex haz_sex

/* Mortality rates per 1000 pyrs */
strate sex, per(1000)

/* Look at status variable */
codebook status
tab status agegrp

/* All-cause survival */
stset surv_mm, failure(status==1,2)

/* Kaplan-Meier */
sts graph, 	by(stage) name(anydeath, replace) 

/* Compare cause-specific and all cause survival */
stset surv_mm, failure(status==1)

sts graph if agegrp==3, by(stage) ///
						name(cancerdeath_75, replace) ///
						subtitle("Cancer")

stset surv_mm, failure(status==1,2)
sts graph if agegrp==3, by(stage) ///
						name(anydeath_75, replace) ///
						subtitle("All cause") 

graph combine cancerdeath_75 anydeath_75						

/* Estimate both cancer-specific and all-cause mortality for each age group */
use melanoma, clear

stset surv_mm, failure(status==1,2)
sts graph, by(agegrp) name(anydeathbyage, replace) subtitle("All cause")

stset surv_mm, failure(status==1)
sts graph, by(agegrp) name(cancerdeathbyage, replace) subtitle("Cancer")

graph combine anydeathbyage cancerdeathbyage

