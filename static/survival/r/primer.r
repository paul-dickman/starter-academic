#load the data

library(relsurv)
library(foreign)
colon <- read.dta("colon.dta")
melanoma <- read.dta("melanoma.dta")
popmort <- read.dta("popmort.dta")
source("life.r")


#make ratetable
males <- popmort[popmort$sex==1,]
females <- popmort[popmort$sex==2,]
males <- matrix(males[,4],byrow=F,nrow=length(unique(males[,3])),ncol=length(unique(males[,2])))
females <- matrix(females[,4],byrow=F,nrow=length(unique(females[,3])),ncol=length(unique(females[,2])))
finpop <- transrate(males,females,yearlim=c(1951,2000),int.length=1)

########################
#rearrange the data sets

#melanoma
melanoma$time <- as.numeric(melanoma$exit - melanoma$dx)
melanoma$cens <- as.numeric(melanoma$status)==2|as.numeric(melanoma$status)==3
 melanoma$aged <- as.numeric(melanoma$dx - melanoma$bdate)
melanoma$dx <- as.date(as.date(as.numeric(melanoma$dx))+as.date("1Jan70"))

#colon
colon$time <- as.numeric(colon$exit - colon$dx)
colon$cens <- as.numeric(colon$status)==2|as.numeric(colon$status)==3
 colon$aged <- colon$age*365.241
colon$dx <- as.date(as.date(as.numeric(colon$dx))+as.date("1Jan70"))

####################
#try all options - continuous version

#my function
fit <- rs.surv(Surv(time,cens)~ratetable(age=aged,sex=as.integer(sex),year=dx),method="pohar-perme",data=colon[colon$dx < as.date("1Jan85")&colon$stage=="Localised",],ratetable=finpop)

#ederer 2
fite <- rs.surv(Surv(time,cens)~ratetable(age=aged,sex=as.integer(sex),year=dx),method="ederer2",data=colon[colon$dx < as.date("1Jan85")&colon$stage=="Localised",],ratetable=finpop)

#hakulinen
fith <- rs.surv(Surv(time,cens)~ratetable(age=aged,sex=as.integer(sex),year=dx),method="hakulinen",data=colon[colon$dx < as.date("1Jan85")&colon$stage=="Localised",],ratetable=finpop)

#ederer 1
fite1 <- rs.surv(Surv(time,cens)~ratetable(age=aged,sex=as.integer(sex),year=dx),method="ederer1",data=colon[colon$dx < as.date("1Jan85")&colon$stage=="Localised",],ratetable=finpop)

#life table estimates for different lengths of time intervals
fit.lt <- rs.surv.lt(Surv(time,cens)~ratetable(age=aged,sex=as.integer(sex),year=dx),data=colon[colon$dx < as.date("1Jan85")&colon$stage=="Localised",],ratetable=finpop,int=c(0:21))
fit.lt3 <- rs.surv.lt(Surv(time,cens)~ratetable(age=aged,sex=as.integer(sex),year=dx),data=colon[colon$dx < as.date("1Jan85")&colon$stage=="Localised",],ratetable=finpop,int=c(0:84)/4)
fit.lt12 <- rs.surv.lt(Surv(time,cens)~ratetable(age=aged,sex=as.integer(sex),year=dx),data=colon[colon$dx < as.date("1Jan85")&colon$stage=="Localised",],ratetable=finpop,int=c(0:252)/12)
 
#plot colon data 
plot(fit,ylim=c(0.6,1),xscale=365.241,col="orange",mark.time=F,lwd=2,conf.int=F,xlim=c(0,20))
abline(h=.7,lty=3,col="grey")
 abline(h=.8,lty=3,col="grey") 
 abline(h=.9,lty=3,col="grey")
 abline(h=.6,lty=3,col="grey")
lines(fite1,col=1,lty=3,mark.time=F,lwd=2,xscale=365.241)
lines(fite,col=2,lty=2,mark.time=F,lwd=2,xscale=365.241)
lines(fith,col=3,mark.time=F,lwd=2,xscale=365.241)
lines(c(0,fit.lt[,2]),c(1,fit.lt$ede2),type="l",lty=1,col=5,lwd=1)
lines(c(0,fit.lt[,2]),c(1,fit.lt$mpp),type="l",lty=1,col=1,lwd=1)
lines(c(0,fit.lt[,2]),c(1,fit.lt$ede),type="l",lty=1,col=6,lwd=1)
legend(x=14,y=1,col=c("black","green","red","orange"),lty=c(3,1,2,1),legend=c("Ederer I","Hakulinen","Ederer II","Pohar-Perme"),lwd=2)

#plot data - 3 month intervals
plot(fit,ylim=c(0.6,1),xscale=365.241,col="white",mark.time=F,lwd=2,conf.int=F,xlim=c(0,20))
abline(h=.7,lty=3,col="grey")
 abline(h=.8,lty=3,col="grey")
 abline(h=.9,lty=3,col="grey")
 abline(h=.6,lty=3,col="grey")
lines(c(0,fit.lt3[,2]),c(1,fit.lt3$ede2),type="l",lty=2,col=2,lwd=1)
lines(c(0,fit.lt3[,2]),c(1,fit.lt3$mpp),type="l",lty=1,col="orange",lwd=2)
lines(c(0,fit.lt3[,2]),c(1,fit.lt3$ede),type="l",lty=1,col=1,lwd=2)
legend(x=14,y=1,col=c("black","red","orange"),lty=c(3,2,1),legend=c("Ederer I","Ederer II","Pohar-Perme"),lwd=2)


#12 month intervals
plot(fit,ylim=c(0.6,1),xscale=365.241,col="white",mark.time=F,lwd=2,conf.int=F,xlim=c(0,20))
abline(h=.7,lty=3,col="grey")
 abline(h=.8,lty=3,col="grey")
 abline(h=.9,lty=3,col="grey")
 abline(h=.6,lty=3,col="grey")
lines(c(0,fit.lt12[,2]),c(1,fit.lt12$ede2),type="l",lty=2,col=2,lwd=1)
lines(c(0,fit.lt12[,2]),c(1,fit.lt12$mpp),type="l",lty=1,col="orange",lwd=2)
lines(c(0,fit.lt12[,2]),c(1,fit.lt12$ede),type="l",lty=1,col=1,lwd=2)
legend(x=14,y=1,col=c("black","red","orange"),lty=c(3,2,1),legend=c("Ederer I","Ederer II","Pohar-Perme"),lwd=2)
