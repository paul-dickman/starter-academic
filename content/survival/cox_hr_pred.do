/********************************************************
cox_hr_pred.do

Cox regression comparing alternative approaches to modelling age:
1. Linear effect
2. Categories
3. Restricted cubic spline

We then plot the predictd HRs from each approach with
age 60 as the reference.
********************************************************/
set more off
use melanoma if stage==1, clear
stset surv_mm, failure(status==1) id(id) exit(time 120)

// center age at 60 
gen age60=age-60 

// Create basis vectors for restricted cubic splines centered at age 60 
// It is quite easy to create a spline basis, e.g., mkspline Sage = age60, cubic nknots(4)
// However, centering the resulting variables at a certain value (60 here) requires
// some extra work
rcsgen age, gen(Sage) orthog df(3)
matrix Rmatage = r(R)
local knotsage `r(knots)'
rcsgen , scalar(60) rmatrix(Rmatage) gen(c) knots(`knotsage')
forvalues i=1/3 {  
replace Sage`i'=Sage`i'-c`i'
}

// fit unadjusted Cox model with age modeled as a linear effect
stcox age60
// predict the HR for age (age 60 is the reference)
// partpred is a user-written command
// type findit partpred in Stata to download it
partpred expxb1, for(age60) eform ci(expxb_lci1 expxb_uci1)

// fit unadjusted Cox model with age modeled in categories
// group 2 (age 60-74) is the reference
stcox ib2.agegrp
// predict the HR for age (age 60 is the reference)
// partpred is a user-written command
// type findit partpred in Stata to download it
partpred expxb2, for(ib2.agegrp) eform ci(expxb_lci2 expxb_uci2)

// fit unadjusted Cox model with age modeled using restricted cubic spline
stcox Sage1 Sage2 Sage3
// predict the HR for age (age 60 is the reference)
// partpred is a user-written command
// type findit partpred in Stata to download it
partpred expxb3, for(Sage?) eform ci(expxb_lci3 expxb_uci3)

// now additionally adjust for sex and period (modelling age using a spline) 
stcox year8594 sex Sage1 Sage2 Sage3
// predict the HR for age using partpred (age 60 is the reference)
partpred expxb3a, for(Sage?) eform ci(expxb_lci3a expxb_uci3a)

// plot the predicted hazard ratios
drop if age > 90
drop if age < 20
line expxb1 age, sort || ///
line expxb2 age, sort connect(J) || ///
line expxb3 age, sort || ///
line expxb3a age, sort  ///
  ylabel(,angle(h)) name(linpred,replace) yline(1, lstyle(foreground)) ///
  legend(order(1 "linear" 2 "categorical" ///
  3 "unadjusted spline" 4 "adjusted spline") ///
  ring(0) pos(11) cols(1)) yscale(log) ytitle("Hazard ratio") ///
  title("Hazard ratios for age (age 60 as reference)")
