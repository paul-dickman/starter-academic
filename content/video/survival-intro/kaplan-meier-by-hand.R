###########################################################
# R code accompanying the video lecture:
#
# Introduction to survival analysis
#
# http://pauldickman.com/video/survival-intro/
#
# This code calculates the Kaplan-Meier estimate of survival
# 'by hand' and compares to that obtained using survfit()
# Spoiler: the estimates are identical 
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

## We will implement the Kaplan-Meier estimator "by hand"
## That is, tabulate the number at risk and deaths at each unique 
## event time, which are then used to calculate survival

## Sort by unique event times and generate the start (t0)  
## and end (t1) times for the intervals
t1 <- sort(unique(aml$time))
t0 <- c(0, t1[-length(t1)])

## count the number at risk and number of deaths in each interval 
n.atrisk <- n.dead <- rep(NA, length(t1))
for(i in 1:length(t1)) {
  n.atrisk[i] <- nrow(subset(aml, time > t0[i]))
  n.dead[i] <- nrow(subset(subset(aml, time > t0[i]), time <= t1[i] & status == 1))
}

## Calculate conditional probability of surviving the interval
p <- 1 - (n.dead / n.atrisk)

## Calculate cumulative probability of surviving from time zero until
## the end of the interval (i.e., Kaplan-Meier estimate of survival)
S <- cumprod(p)

km.by.hand <- data.frame(t0,t1,n.atrisk,n.dead,p,S)
print(km.by.hand)

## Now calculate the Kaplan-Meier estimates using the R functions Surv and survfit
kmfit <- survfit(Surv(time, status) ~ 1, data = aml)

## Table of Kaplan-Meier estimates
summary(kmfit)

## Plot the Kaplan-Meier estimates
plot(kmfit,xmax=60)

## Overlay the estimates of S(t) we created "by hand"
lines(S ~ t1, type = "s", col = "red", lty = 3)





