
//==================//
// EXERCISE 261
// REVISED MAY 2015
//==================//

** Load the Data, stset and merge in expected mortality **
use colon, clear
stset surv_mm, failure(status=1 2) scale(12) exit(time 120.5)
gen _age = min(int(age + _t),99)
gen _year = int(yydx + _t)
sort _year sex _age
merge m:1 _year sex _age using popmort,  keep(match master)


** Cure model using stpm2 **
stpm2 year8594, df(6) bhazard(rate) scale(hazard) cure 

predict cure1, cure
list cure1 if year8594==0, constant
list cure1 if year8594==1, constant

predict med1, centile(50) uncured
list med1 if year8594==0, constant
list med1 if year8594==1, constant


** Cure model using stpm2, including time-dependent effect **
stpm2 year8594, df(6) tvc(year8594) dftvc(4) bhazard(rate) scale(hazard) cure 

predict cure2, cure
list cure2 if year8594==0, constant
list cure2 if year8594==1, constant

predict med2, centile(50) uncured
list med2 if year8594==0, constant
list med2 if year8594==1, constant


predict surv, survival
predict survunc, survival uncured

forvalues j=0/1 {
		twoway (line surv _t if year8594==`j', sort) (line survunc _t if year8594==`j', sort), ///
          legend(label(1 "Survival overall") label(2 "Survival for uncured")) name(period`j', replace)
}
