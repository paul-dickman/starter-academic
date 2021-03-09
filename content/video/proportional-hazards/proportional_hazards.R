###########################################################
# R code accompanying the video lecture:
#
# Understanding the proportional hazards assumption in the Cox model
#
# http://pauldickman.com/video/proportional-hazards/
#
# Paul Dickman
# August 2020
###########################################################

library(biostat3) # colon data is in this package

# Subset the data to only localised and split follow-up time at 24 months
localised <- survSplit(Surv(surv_mm, status=="Dead: cancer") ~
                           agegrp+sex+year8594,
                       cut=c(24,1000),
                       data=biostat3::colon, subset=(stage=="Localised"),
                       episode="timeband")

# Make timeband as a factor class variable, which will be made into a dummy varaible automatically in Surv()
localised <- transform(localised, timeband = factor(timeband))

# Cox model with interaction between period and timeband
summary(coxph(Surv(tstart,surv_mm,event)
              ~agegrp+sex+year8594*timeband,
              data=localised))

# Same model, but reparameterise to directly estimate the effect of period within each timeband
localised <- transform(localised,
                       later=ifelse(year8594=="Diagnosed 85-94",1,0))
summary(coxph(Surv(tstart,surv_mm,event)~agegrp+sex+later:timeband,
              data=localised))

# test if the interaction is statistically significant
fit <- coxph(Surv(tstart,surv_mm,event) ~ 
                agegrp+sex+year8594*timeband,
               data=localised)
anova(fit,test="Chisq")

# Now fit the same model, but using the tt option rather than splitting 
colon2 <- transform(colon, later=ifelse(year8594=="Diagnosed 85-94" ,1 ,0 ))

summary(coxph(Surv(surv_mm, status=="Dead: cancer")~agegrp+sex+year8594+tt(later),
                data=colon2, subset=(stage=="Localised"),
                tt = function(x, t, ...) x*(t>=24)))

# tests based on Schoenfeld residuals to check PH assumption
fit1 <- coxph(Surv(surv_mm/12,status=="Dead: cancer")~sex+agegrp+year8594,
                  data=colon, subset=(stage=="Localised"))
cox.zph(fit1) 

# plots based on Schoenfeld residuals
fit2 <- coxph(Surv(surv_mm,status=="Dead: cancer")~sex+agegrp+year8594,
              data=colon, subset=(stage=="Localised"))

plot(cox.zph(fit2)[3])

plot(cox.zph(fit2)[1]) 

# Now we include stage as well
known <- transform(colon, stage=droplevels(stage, "Unknown"))

fit3 <- coxph(Surv(surv_mm/12,status=="Dead: cancer") ~
               sex+agegrp+stage+year8594,
               data=known)
summary(fit3)

cox.zph(fit3)

# Estimates the hazard function using kernel-based methods
fit4 <- muhaz2(Surv(surv_mm,status=="Dead: cancer")~stage,
              data=known)
plot(fit4)

# Cox PH using stage as a covariate
fit5 <- coxph(Surv(surv_mm,status=="Dead: cancer")~stage, data=known)

# Hazard estimates (using kernel smoothing of the Nelson-Aalen) for coxph
plot(coxphHaz(fit5,newdata=data.frame(stage=levels(known$stage))))

# log scale of the hazard estimates above
plot(coxphHaz(fit5,newdata=data.frame(stage=levels(known$stage))),
       log="y")

# Plot the proportional hazards assumption 
fit6 <- coxph(Surv(surv_mm,status=="Dead: cancer")~stage, data=known)

plot(cox.zph(fit6))

# Stratified by agegrp
fit7 <- coxph(Surv(surv_mm/12,status=="Dead: cancer")~
             sex+year8594+strata(agegrp),
             data=colon, subset=(stage=="Localised"))
summary(fit7)
