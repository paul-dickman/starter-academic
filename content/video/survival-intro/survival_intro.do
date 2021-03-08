***********************************************************
* Stata code accompanying the video lecture:
*
* Introduction to survival analysis
*
* http://pauldickman.com/video/survival-intro/
*
* Paul Dickman
* April 2020
***********************************************************
//Start of Stata code//
clear all
input time status   x
   9     1    0       
  13     1    0     
  13     0    0     
  18     1    0
  23     1    0
  28     0    0
  31     1    0
  34     1    0
  45     0    0
  48     1    0
 161     0    0
   5     1    1
   5     1    1
   8     1    1
   8     1    1
  12     1    1
  16     0    1
  23     1    1
  27     1    1
  30     1    1
  33     1    1
  43     1    1
  45     1    1
end

label data "Survival of patients with Acute Myelogenous Leukemia. From the R survival package."
label variable time "Time in months to death or censoring"
label variable status "Vital status; 1=dead, 0=censored"
label variable x "Treatment; 0=maintenence therapy, 1=no maintenence"

label define x 0 "Maintained" 1 "Nonmaintained"
label values x x

stset time, fail(status)

* Table of Kaplan-Meier estimates
sts list

* Plot the Kaplan-Meier estimates
sts graph, scheme(plotplain)

* Kaplan-Meier curves separately by treatment group
sts graph, by(x)

* Logrank test to compare the survival between treatment groups
sts test x

* same test using a Cox model
stcox x
//End of Stata code//
