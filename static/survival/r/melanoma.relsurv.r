# Modelling the Finnish localised melanoma data using the relsurv package
# Uses popmort file downloaded from HMD and fits the piecewise model using 3 approachs (Esteve, Hakulinen, and Poisson regression)
# Esteve approach diesn't converge for localsed melanoma (although does converge for distant)
# Results differ to the other approach (melanoma.lexis.r) for unknown reasons. We are using a different popmort file but that shouldn't cause large difference.
# Paul Dickman, November 2007
setwd("c:/survival/r/")

library(foreign)
library(survival)
library(relsurv)
memory.limit(4000)

# localised (stage=1) melanoma
melanoma <- subset.data.frame(read.dta("melanoma.dta",convert.factors=FALSE), stage==1)
attach(melanoma)

# Death due to any cause is the event
melanoma$Status2<-status*0
melanoma$Status2[status==1 | status==2]<-1

# Download rates files from http://www.mortality.org/
# # 6. Life Tables By year of death (period) 1x1
# Save tables by gender in text files
# The transrate.hmd command translate these to R ratetables
Finlandpop <- transrate.hmd("Finlandmales.txt","Finlandfemales.txt")
attributes(Finlandpop)$dimid

# The relsurv package requires time in days (exit and dx are dates of exit and diagnosis)
melanoma$surv.dd <- exit - dx

# Ésteve additive survival model
model1<-rsadd(Surv(surv.dd,Status2)~sex+factor(agegrp)+year8594+ratetable(age=age*365.24,sex=sex,year=dx),melanoma,ratetable=Finlandpop,int=5)
summary(model1)

# Hakulinen-Tenkanen additive model
model2<-rsadd(Surv(surv.dd,Status2)~sex+factor(agegrp)+year8594+ratetable(age=age*365.24,sex=sex,year=dx),melanoma,ratetable=Finlandpop,method="glm.bin",int=5)
summary(model2)

# GLM Poisson
model3<-rsadd(Surv(surv.dd,Status2)~sex+factor(agegrp)+year8594+ratetable(age=age*365.24,sex=sex,year=dx),melanoma,ratetable=Finlandpop,method="glm.poi",int=5)
summary(model3)
