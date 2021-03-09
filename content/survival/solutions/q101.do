
//==================//
// EXERCISE 101
// REVISED MAY 2015
//==================//

/* Data set used */
use colon_sample, clear

/* Create 0/1 outcome variable */
recode status (1=1) (nonmissing=0), gen(csr_fail)

/* Life table */
ltable surv_yy csr_fail
ltable surv_mm csr_fail, interval(12)

/* Kaplan-Meier */
stset surv_mm, failure(status==1)
sts list
sts graph

/* Kaplan-Meier displaying number at risk */
sts graph, atrisk name(atrisk, replace)
sts graph, risktable name(risktable, replace)

/* Kaplan-Meier with titles and axis labels */
sts graph, risktable title(Kaplan-Meier estimates of cause-specific survival) ///
			xtitle(Time since diagnosis in months) name(withtitle, replace)
