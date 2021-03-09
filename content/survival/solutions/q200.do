
//==================//
// EXERCISE 200
// REVISED MAY 2015
//==================//

use colon_sample, clear
gen id = _n

stset surv_mm, failure(status==1 2) sc(12) id(id)

strs using popmort, br(0(1)5) mergeby(_year sex _age) ///
           ederer1 list(n d w p cp_e1 cp_e2)
