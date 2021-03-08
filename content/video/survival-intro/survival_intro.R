###########################################################
# R code accompanying the video lecture:
#
# Introduction to survival analysis
#
# http://pauldickman.com/video/survival-intro/
#
# R code by Michael Sachs and Paul Dickman
# April 2020
###########################################################

## load the survival package
library(survival)

# look at the aml dataset
## status == 1 means dead at the time (in months), 
## status == 0 means censored at the time,
## X is treatment (maintanence therapy)
aml

## Kaplan-Meier estimate of survival function for all patients
kmfit <- survfit(Surv(time, status) ~ 1, data = aml)

## Table of Kaplan-Meier estimates
summary(kmfit)

## Plot the Kaplan-Meier estimates
plot(kmfit,xmax=60)

## Kaplan-Meier curves separately by treatment group. 
trtfit <- survfit(Surv(time, status) ~ x, data = aml)
summary(trtfit)
plot(trtfit, col = c("slateblue", "salmon"),xmax=60)
legend("bottomleft", fill = c("slateblue", "salmon"), legend = c("Maintained", "Nonmaintained"))

## logrank test to compare the survival between treatment groups.
survdiff(Surv(time, status) ~ x, data = aml)

## same test using a Cox model
coxph(Surv(time, status) ~ x, data = aml)




