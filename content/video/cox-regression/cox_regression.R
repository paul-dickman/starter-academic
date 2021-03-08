###########################################################
# R code accompanying the video lecture:
#
# Introduction to Cox regression
#
# http://pauldickman.com/video/cox-regression/
#
# Paul Dickman
# August 2020
###########################################################

library(biostat3) # colon data is in this package
library(dplyr) # for data manipulation

# Create indicator variables for "distant" and "dead"
colon2 <- transform(biostat3::colon, distant = (stage == "Distant"),
                      dead = status %in% c("Dead: cancer"))

summary(coxph(Surv(surv_mm,dead)~distant, data=colon2))

# Now adjust for age (in two categories)
fit <- coxph(Surv(surv_mm,dead) ~ I(age>=75) +
               I(stage=="Distant"), data=colon2)
summary(fit)

# Now fit model to just the individuals with localised stage
fit1 <- coxph(Surv(surv_mm/12, status=="Dead: cancer") ~ sex + agegrp + year8594,
               subset=(stage=="Localised"), data=colon)
summary(fit1)

# Test the effect of age (Wald test)
library(car)
linearHypothesis(fit1, c("agegrp45-59","agegrp60-74","agegrp75+"))

# Test the effect of age (likelihood ratio test test)
fit2 <- coxph(Surv(surv_mm/12, status=="Dead: cancer") ~ sex + year8594,
                subset=(stage=="Localised"), data=colon)
anova(fit1,fit2,test="Chisq")

# Now model age as a continuous variable
fit3 <- coxph(Surv(surv_mm/12, status=="Dead: cancer") ~ sex + age + year8594,
               subset=(stage=="Localised"), data=colon)
summary(fit3)
