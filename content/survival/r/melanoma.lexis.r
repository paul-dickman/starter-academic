# Fits the piecewise exponential model (Poisson regression) by:
# 1. splitting the follow-up using lexis()
# 2. merging in the expected rates
# 3. collapsing to obtain grouped data
# 4. fitting the model with user-defined link
#
# Paul Dickman, November 2007
#
setwd("c:/survival/r/")

library(foreign)
library(Epi)
memory.limit(4000)

# localised (stage=1) melanoma
melanoma <- subset.data.frame(read.dta("melanoma.dta",convert.factors=FALSE), stage==1)
attach(melanoma)

# Death due to any cause is the event
melanoma$Status2<-status*0
melanoma$Status2[status==1 | status==2]<-1

# Split according to time since diagnosis
split <- Lexis( entry = 0,
        exit = surv.mm/12,
        fail = Status2,
       scale = 1,
      origin = 0,
      breaks = seq(from=0, to=5, by=1 ),
     include = list( id, age, yydx, sex, agegrp, year8594),
        data = melanoma)
        
# generate attained age and attained year to be used for matching with popmort file   
split$.year <- as.integer(split$yydx+split$Entry)
split$.age <- as.integer(split$age+split$Entry)    

popmort<-read.dta("popmort.dta")

m <- merge(split, popmort, all.x = TRUE, sort = TRUE)
m$y <- (m$Exit - m$Entry)
m$d.star <- m$y * m$rate

# collapse and sum y, Fail, and d.star 
grouped <- aggregate(data.frame(m[,c(7,16,17)]), list(Time=m$Time,sex=m$sex,agegrp=m$agegrp,year8594=m$year8594), FUN=sum)

# define the link function for piecewise excess mortality model
# this code stolen from glmxp from the relsurv library (by Pohar M., Stare J.)
# the default initial values are not conducive to convergence of glm
pot <- poisson()
pot$link <- "glm relative survival model with Poisson error"
pot$linkfun <- function(mu) log(mu - d.star)
pot$linkinv <- function(eta) d.star + exp(eta)
assign(".d.star", grouped$d.star, env = .GlobalEnv)
if (any(grouped$Fail - grouped$d.star < 0)) {
    pot$initialize <- expression({
        if (any(y < 0)) stop(paste("Negative values not allowed for", 
          "the Poisson family"))
        n <- rep.int(1, nobs)
        mustart <- pmax(y, .d.star) + 0.1
    })
}
if (any(grouped$Fail - grouped$d.star < 0)) {
    n <- sum(grouped$Fail - grouped$d.star < 0)
    g <- dim(grouped)[1]
    warnme <- paste("Observed number of deaths is smaller than the expected in ", 
        n, "/", g, " groups of patients", sep = "")
}

# fit the model
attach(grouped)
local.pot <- glm(Fail ~ Time + sex + year8594 + agegrp, offset=log(y), family=pot, data=grouped)
summary(local.pot)
anova(local.pot)

# Results from Stata
# . xi: glm d i.sex i.year8594 i.agegrp i.end, fam(pois) link(rs d_star) lnoff(y)
# i.sex             _Isex_1-2           (naturally coded; _Isex_1 omitted)
# i.year8594        _Iyear8594_0-1      (naturally coded; _Iyear8594_0 omitted)
# i.agegrp          _Iagegrp_0-3        (naturally coded; _Iagegrp_0 omitted)
# i.end             _Iend_1-5           (naturally coded; _Iend_1 omitted)
# 
# Generalized linear models                          No. of obs      =        80
# Optimization     : ML                              Residual df     =        70
#                                                    Scale parameter =         1
# Deviance         =   76.0143154                    (1/df) Deviance =  1.085919
# Pearson          =  75.40696725                    (1/df) Pearson  =  1.077242
# 
# Variance function: V(u) = u                        [Poisson]
# Link function    : g(u) = log(u-d*)                [Relative survival]
# 
#                                                    AIC             =  5.460814
# Log likelihood   = -208.4325474                    BIC             = -230.7275
# 
# ------------------------------------------------------------------------------
#              |                 OIM
#            d |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
# -------------+----------------------------------------------------------------
#      _Isex_2 |  -.5719077   .0969952    -5.90   0.000    -.7620148   -.3818005
# _Iyear8594_1 |  -.4670959   .0975371    -4.79   0.000    -.6582651   -.2759268
#   _Iagegrp_1 |   .3206573   .1251442     2.56   0.010      .075379    .5659355
#   _Iagegrp_2 |   .6379465   .1282286     4.98   0.000      .386623      .88927
#   _Iagegrp_3 |   1.175554   .1715426     6.85   0.000     .8393367    1.511771
#      _Iend_2 |   1.911696   .3006243     6.36   0.000     1.322483    2.500909
#      _Iend_3 |   1.979597   .3011577     6.57   0.000     1.389338    2.569855
#      _Iend_4 |   1.690654   .3093887     5.46   0.000     1.084264    2.297045
#      _Iend_5 |   1.539031   .3166795     4.86   0.000      .918351    2.159712
#        _cons |  -5.010609   .3057016   -16.39   0.000    -5.609774   -4.411445
#            y | (exposure)
# ------------------------------------------------------------------------------


