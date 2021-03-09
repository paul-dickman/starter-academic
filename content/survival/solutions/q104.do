
//==================//
// EXERCISE 104
// REVISED MAY 2015
//==================//

/* Data set used */
use melanoma if stage == 1, clear

/* Stset */
stset surv_mm, failure(status==1)

/* Kaplan-Meier by calendar time */
sts graph, by(year8594) 

sts graph, hazard by(year8594) noshow	

/* Log-rank test */
sts test year8594

/* Wilcoxon test */
sts test year8594, wilcoxon

/* Estimate mortality rates */
strate agegrp, per(1000)

/* Kaplan-Meier */
sts graph, 	by(agegrp) 

/*stset using the scale option*/
stset surv_mm, failure(status==1) scale(12)

/* Kaplan-Meier */
sts graph, by(agegrp)

/* Estimate mortality rates by age group*/
strate agegrp, per(1000)

/* Kaplan-Meier by sex */
sts graph, by(sex)
sts graph, hazard by(sex) noshow 

/* Estimate mortality rates by sex */
strate sex, per(1000)

/* Log-rank test */
sts test sex


