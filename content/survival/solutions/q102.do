
//==================//
// EXERCISE 102
// REVISED MAY 2015
//==================//

/* Data set used */
use melanoma if stage==1, clear

/* Generate a new failure variable */
recode status (1=1) (nonmissing=0), gen(csr_fail)

/* Life table */
ltable surv_yy csr_fail
ltable surv_mm csr_fail

/* Kaplan-Meier (survival time in years) */
stset surv_yy, failure(status==1)
sts list

/* Kaplan-Meier (survival time in months) */
stset surv_mm, failure(status==1)
sts list


