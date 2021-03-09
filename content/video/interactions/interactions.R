###########################################################
# R code accompanying the video lecture:
#
# Understanding interactions in the Cox model
#
# http://pauldickman.com/video/interactions/
#
# Paul Dickman
# August 2020
###########################################################
# Start of R code =========================================

library(biostat3)  # data are in this package
library(dplyr)    # for data manipulation

## Read melanoma data, restrict to localised, and create a death indicator
melanoma.l <- biostat3::melanoma %>%
              filter(stage=="Localised") %>%
              mutate(death_cancer = as.numeric(status=="Dead: cancer"))

melanoma.l2 <- mutate(melanoma.l,
               ## Create a death indicator (only count deaths within 120 months)
               death_cancer = death_cancer * as.numeric( surv_mm <= 120),
               ## Create a new time variable (censor at 120 months)
               surv_mm = pmin(surv_mm, 120))

# main effects model
summary(
        coxph(Surv(surv_mm/12, death_cancer) ## EC: I added /12 on surv_mm, to make sure the time unit is in years (to be consistent with preivous materials?), whereas it does not change the output
              ~ sex + year8594 + agegrp,
              data = melanoma.l2)
        )

# interaction model
# Adding interaction between sex & year8594
summary(
        coxph(Surv(surv_mm/12, death_cancer) 
              ~ sex + year8594 + sex:year8594 + agegrp,
              data = melanoma.l2)
        )

# Same model as above
summary(
        coxph(Surv(surv_mm/12, death_cancer) 
              ~ sex*year8594 + agegrp,
              data = melanoma.l2)
        )
# Fitting the same model, but with different parameterisation.
summary(
        coxph(Surv(surv_mm/12, death_cancer) 
               ~ year8594 + sex:year8594 + agegrp,
                data = melanoma.l2)
)

# Fitting the same model, but with another different parameterisation.
summary(
        coxph(Surv(surv_mm, death_cancer) 
              ~ sex:year8594 + agegrp,
                data = melanoma.l2)
        )

# interaction between sex and age group
summary(
        coxph(Surv(surv_mm, death_cancer) 
              ~ year8594 + agegrp + sex + sex:agegrp,
              data = melanoma.l2)
       )

# Reparameterise to get the four HRs for sex
summary(
        coxph(Surv(surv_mm, death_cancer) 
              ~ year8594 + agegrp + sex:agegrp,
              data = melanoma.l2)
        )

# Preparation for testing interaction effects
fit1 <- coxph(Surv(surv_mm, death_cancer) 
              ~ year8594 + agegrp + sex,
              data = melanoma.l2)

fit2 <- coxph(Surv(surv_mm, death_cancer) 
              ~ year8594 + agegrp + sex + sex:agegrp,
              data = melanoma.l2)

## test the significance of the 3 interaction effects (Wald test)
library(car)
linearHypothesis(fit2, c("agegrp45-59:sexFemale","agegrp60-74:sexFemale","agegrp75+:sexFemale"))

## same test using likelihood ratio test
anova(fit1,fit2,test="Chisq")

# End of R code ============================================================
