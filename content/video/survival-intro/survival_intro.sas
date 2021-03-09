/***********************************************************
* SAS code accompanying the video lecture:
*
* Introduction to survival analysis
*
* http://pauldickman.com/video/survival-intro/
*
* Paul Dickman
* April 2020
***********************************************************/
proc format;
value x 0="Maintained" 
        1 "Nonmaintained"
;
run;

data aml(label="Survival of patients with Acute Myelogenous Leukemia. From the R survival package");
input time status x;
format x x.;
label time = "Time in months to death or censoring";
label status = "Vital status; 1=dead, 0=censored";
label x = "Treatment; 0=maintenence therapy, 1=no maintenence";
cards;
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
;
run;

/* Kaplan-Meier estimates for all patients*/
proc lifetest;
time time*Status(0);
run;

/* Log-rank test for differences between treatment (x) */
/* We also get the Kaplan-Meier estimates */ 
proc lifetest;
time time*Status(0);
strata x;
run;

/* Cox regression model */
proc phreg;
model time*Status(0) = x;
run;
