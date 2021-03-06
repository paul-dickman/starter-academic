
//==================//
// EXERCISE 202
// REVISED MAY 2015
//==================//

/* Data set used (localised melanoma) */
use melanoma if stage==1 , clear

/* Create failure indicator variable */
recode status (1=1) (nonmissing=0), gen(csr_fail)

/* Cause specific mortality */
stset surv_mm, fail(status==1) id(id) scale(12)

/****
 (a)
****/

/* Life-table estiamtes using strs, annual intervals 0-20 years */
strs using popmort, br(0(1)20) mergeby(_year sex _age) list(n d w p cp)

/****
 (b)
****/

/* Life table estimates using ltable command */
ltable surv_mm csr_fail, interval(12)

/****
 (c)
****/

/* Life table estimates saving standardised estimates (cause specific) */
strs using popmort, br(0(1)20) ///
					mergeby(_year sex _age) ///
					list(n d w p cp) ///
					savgroup(csr, replace)

/* New stset to be able to estimate relative survival rates */
stset surv_mm, fail(status==1 2) id(id) scale(12)

/* Life table estimates saving standardised estimates (relative survival) */
strs using popmort, br(0(1)20) ///
					mergeby(_year sex _age) ///
					list(n d w p cr) ///
					savgroup(rsr, replace)

/* Relative survival estimates */
use rsr, clear

/**/
gen SE_RSR=se_cp/cp_e2
rename cr RSR
keep start RSR SE_RSR
save rsr, replace

/* Cause specific estimates */
use csr, clear
rename cp CSR
rename se_cp SE_CSR
keep start end CSR SE_CSR
save csr, replace


merge 1:1 start using rsr
format CSR SE_CSR RSR SE_RSR %6.4f

/* Compare cause specific estimates to relative survival estimates */
list start end CSR RSR

/***********
END OF FILE
***********/




 
