clear
use http://www.pauldickman.com/survival/colon
stset surv_mm, fail(status==1) scale(12)

sts graph, by(year8594)
graph export "C:\survival\temp.eps", as(eps) preview(on) replace
sts test year8594

scalar O1=3945
scalar E1=3612.03
scalar O2=4424
scalar E2=4756.97
display (O1-E1)^2/E1+(O2-E2)^2/E2


/* Now censor everyone at T years */
scalar T=10.95833
replace _d=0 if _t > T
replace _t=11 if _t > T
sts graph, by(year8594)
graph export "C:\survival\temp2.eps", as(eps) preview(on) replace
sts test year8594

scalar O1=3883
scalar E1=3550.04
scalar O2=4424
scalar E2=4756.97
display (O1-E1)^2/E1+(O2-E2)^2/E2
