+++
date = "2019-03-13"
title = "Replicate a Cox model using Poisson regression"
summary = "An illustration of how one can both approximate and exactly replicate estimates from a Cox model using Poisson regression"
shortsummary = "" 
tags = ["Poisson","Cox","Stata"]
math = true
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/compare-cox-poisson.do).

In this tutorial, I illustrate how one can both approximate and exactly replicate the estimated hazard ratios from a Cox model using Poisson regression. We fit 3 models for cause-specific survival:

1. Cox regression
2. Poisson regression, time split into annual intervals
3. Poisson regression, time split at every event time

Approaches (1) and (3) give identical estimates and standard errors, whereas approach (2) is similar but not identical. Bendix Carstensen provides a detailed overview of the relationship between Cox and Poisson regression (historical background, theory, examples using R, and practical advice) in ['Who needs the Cox model anyway?'](http://bendixcarstensen.com/WntCma.pdf)  

As a bonus, at the end, we will compare with the estimates obtained from a flexible parametric model. 

```stata
. use http://pauldickman.com/data/colon.dta if stage == 1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)
 
. stset surv_mm, failure(status==1) exit(time 120) id(id) noshow

                id:  id
     failure event:  status == 1
obs. time interval:  (surv_mm[_n-1], surv_mm]
 exit on or before:  time 120

------------------------------------------------------------------------------
      6,274  total observations
          0  exclusions
------------------------------------------------------------------------------
      6,274  observations remaining, representing
      6,274  subjects
      1,687  failures in single-failure-per-subject data
    371,466  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =       120

. /* Fit the Cox model */
. stcox i.sex i.year8594 i.agegrp

Cox regression -- Breslow method for ties

No. of subjects =        6,274                  Number of obs    =       6,274
No. of failures =        1,687
Time at risk    =       371466
                                                LR chi2(5)       =      189.78
Log likelihood  =   -14056.693                  Prob > chi2      =      0.0000

----------------------------------------------------------------------------------
              _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
             sex |
           Male  |          1  (base)
         Female  |   .9039195   .0451553    -2.02   0.043     .8196115    .9968998
                 |
        year8594 |
Diagnosed 75-84  |          1  (base)
Diagnosed 85-94  |    .749376   .0370269    -5.84   0.000     .6802079    .8255775
                 |
          agegrp |
           0-44  |          1  (base)
          45-59  |    .918357    .128281    -0.61   0.542     .6984112    1.207569
          60-74  |   1.249564   .1582644     1.76   0.079     .9748749    1.601651
            75+  |    2.12185   .2687012     5.94   0.000     1.655475    2.719612
----------------------------------------------------------------------------------

. estimates store Cox
 
. /* Now split and fit the Poisson model */
. /* Change the at option to vary the interval length */
. stsplit fu, at(0(12)120) trim
(no obs. trimmed because none out of range)
(27,416 observations (episodes) created)

. streg i.fu i.sex i.year8594 i.agegrp, dist(exp)

Exponential PH regression

No. of subjects =        6,274                  Number of obs    =      33,690
No. of failures =        1,687
Time at risk    =       371466
                                                LR chi2(14)      =      693.32
Log likelihood  =   -5970.8804                  Prob > chi2      =      0.0000

----------------------------------------------------------------------------------
              _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
              fu |
              0  |          1  (base)
             12  |   .8246801   .0545188    -2.92   0.004     .7244583    .9387666
             24  |   .6384144   .0485296    -5.90   0.000     .5500446    .7409815
             36  |   .5238456   .0455288    -7.44   0.000     .4417974    .6211314
             48  |   .4367139   .0436612    -8.29   0.000     .3590019     .531248
             60  |   .3770055   .0432194    -8.51   0.000     .3011391    .4719851
             72  |   .2688203   .0388012    -9.10   0.000     .2025818    .3567167
             84  |   .1391547   .0296915    -9.24   0.000      .091596    .2114068
             96  |   .1142305   .0290489    -8.53   0.000     .0693938    .1880371
            108  |   .1105764   .0311296    -7.82   0.000     .0636841    .1919968
                 |
             sex |
           Male  |          1  (base)
         Female  |   .9003567   .0449844    -2.10   0.036     .8163683    .9929858
                 |
        year8594 |
Diagnosed 75-84  |          1  (base)
Diagnosed 85-94  |    .750952   .0371166    -5.79   0.000     .6816173    .8273395
                 |
          agegrp |
           0-44  |          1  (base)
          45-59  |   .9200351   .1285153    -0.60   0.551     .6996876    1.209775
          60-74  |   1.255662   .1590357     1.80   0.072     .9796346    1.609465
            75+  |   2.160755    .273611     6.08   0.000     1.685854    2.769434
                 |
           _cons |   .0066486   .0008628   -38.63   0.000     .0051555    .0085742
----------------------------------------------------------------------------------
Note: _cons estimates baseline hazard.

. estimates store Poisson

. /* Compare the estimates */
. estimates table Cox Poisson, eform equations(1) b(%9.6f) se(%9.6f) ///
> keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
> title("Hazard ratios and standard errors for Cox and Poisson models")

Hazard ratios and standard errors for Cox and Poisson models

--------------------------------------
    Variable |    Cox       Poisson   
-------------+------------------------
         sex |
     Female  |  0.903920    0.900357  
             |  0.045155    0.044984  
             |
    year8594 |
Diagnosed..  |  0.749376    0.750952  
             |  0.037027    0.037117  
             |
      agegrp |
      45-59  |  0.918357    0.920035  
             |  0.128281    0.128515  
      60-74  |  1.249564    1.255662  
             |  0.158264    0.159036  
        75+  |  2.121850    2.160755  
             |  0.268701    0.273611  
--------------------------------------
                          legend: b/se
```
We see that estimates and standard errors are similar, but not identical.

Now split very finely (one interval for each failure time) and fit the Poisson model. The estimated hazard ratios and standard errors will be identical to those obtained from the Cox model ([Holford 1976](https://www.jstor.org/stable/2529747) and [Whitehead 1980](https://www.jstor.org/stable/2346901)).

Previously we split follow-up time using `stsplit` with the option `at(0(12)120)`. Time-at-risk for each observation was split into potentially 10 observations, in 12-month intervals from 0 to 120 months. We are now splitting at every event time by specifying the `at(failures)` option to `stsplit`. The `stsplit` command creates the variable `interval` (with values 1-112) to index the intervals. We use the `tab` command to generate 112 dummy variables to include in the model. `interval*` represents all variables that start with the word `interval` (`*` is a wildcard); in practice dummy1-dummy112.

```stata 
. use http://pauldickman.com/data/colon.dta if stage == 1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. stset surv_mm, failure(status==1) exit(time 120) id(id) noshow
[output omitted]

. stsplit, at(failures) riskset(riskset)
(112 failure times)
(357,773 observations (episodes) created)

. quietly tab riskset, gen(interval)

. streg interval* i.sex i.year8594 i.agegrp, dist(exp)
note: interval112 omitted because of collinearity

Exponential PH regression

No. of subjects =        6,274                  Number of obs    =     362,743
No. of failures =        1,687
Time at risk    =       370722
                                                LR chi2(116)     =     1150.06
Log likelihood  =   -5739.1319                  Prob > chi2      =      0.0000

----------------------------------------------------------------------------------
              _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
       interval1 |   24.02653   17.12769     4.46   0.000     5.941531    97.15913
       interval2 |   10.26062   7.325904     3.26   0.001     2.531805    41.58309
       interval3 |   5.422513   3.904378     2.35   0.019     1.322236    22.23782

[output omitted]

     interval107 |   .4486084   .5494319    -0.65   0.513     .0406781    4.947368
     interval108 |   .4625166   .4625173    -0.77   0.441     .0651515    3.283448
     interval109 |   .9395767   .9395775    -0.06   0.950     .1323518    6.670133
     interval110 |   .2413774   .2956257    -1.16   0.246     .0218873    2.661959
     interval111 |   .2477571   .3034392    -1.14   0.255     .0224658    2.732315
     interval112 |          1  (omitted)
                 |
             sex |
           Male  |          1  (base)
         Female  |   .9039195   .0451553    -2.02   0.043     .8196115    .9968998
                 |
        year8594 |
Diagnosed 75-84  |          1  (base)
Diagnosed 85-94  |    .749376   .0370269    -5.84   0.000     .6802079    .8255775
                 |
          agegrp |
           0-44  |          1  (base)
          45-59  |    .918357    .128281    -0.61   0.542     .6984112    1.207569
          60-74  |   1.249564   .1582644     1.76   0.079     .9748749    1.601651
            75+  |    2.12185   .2687012     5.94   0.000     1.655475    2.719612
                 |
           _cons |   .0014597   .0010461    -9.11   0.000     .0003583    .0059465
----------------------------------------------------------------------------------
Note: _cons estimates baseline hazard.

. estimates store Poisson_fine

. /* Compare the estimates and SEs */
. estimates table Cox Poisson_fine Poisson, eform equations(1) ///
> keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
> se b(%9.6f) se(%9.6f) modelwidth(12) ///
> title("Hazard ratios and standard errors for various models")

Hazard ratios and standard errors for various models

-----------------------------------------------------------
    Variable |     Cox        Poisson_fine     Poisson     
-------------+---------------------------------------------
         sex |
     Female  |     0.903920       0.903920       0.900357  
             |     0.045155       0.045155       0.044984  
             |
    year8594 |
Diagnosed..  |     0.749376       0.749376       0.750952  
             |     0.037027       0.037027       0.037117  
             |
      agegrp |
      45-59  |     0.918357       0.918357       0.920035  
             |     0.128281       0.128281       0.128515  
      60-74  |     1.249564       1.249564       1.255662  
             |     0.158264       0.158264       0.159036  
        75+  |     2.121850       2.121850       2.160755  
             |     0.268701       0.268701       0.273611  
-----------------------------------------------------------
                                               legend: b/se
```

Although the parameter estimates and standard errors are identical, the models are not technically identical. In the Poisson regression model we have assumed the hazards are constant within event times, an assumption that is not made with the Cox model.

We'll now fit a flexible parametric model and see that the estimates are very similar (as is usually the case). Paul Lambert, who co-authored the `stpm2` command, has written a [tutorial comparing the flexible parametric model to a Cox model](https://pclambert.net/software/stpm2/comparewithcox/) (using different data). His tutorial describes the two models and the syntax of the `stpm2` command.  

```stata
. use http://pauldickman.com/data/colon.dta if stage == 1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. stset surv_mm, failure(status==1) exit(time 120) id(id) noshow
[output omitted]

. stpm2 i.sex i.year8594 i.agegrp, scale(h) df(5) eform 
[output omitted]

. estimates store fpm

. /* Compare the estimates and SEs */
. estimates table Cox fpm Poisson, eform equations(1) ///
> keep(2.sex 1.year8594 1.agegrp 2.agegrp 3.agegrp) ///
> se b(%9.6f) se(%9.6f) modelwidth(12) ///
> title("Hazard ratios and standard errors for various models")

Hazard ratios and standard errors for various models

-----------------------------------------------------------
    Variable |     Cox            fpm          Poisson     
-------------+---------------------------------------------
         sex |
     Female  |     0.903920       0.901777       0.900357  
             |     0.045155       0.045053       0.044984  
             |
    year8594 |
Diagnosed..  |     0.749376       0.755742       0.750952  
             |     0.037027       0.037402       0.037117  
             |
      agegrp |
      45-59  |     0.918357       0.920258       0.920035  
             |     0.128281       0.128547       0.128515  
      60-74  |     1.249564       1.256194       1.255662  
             |     0.158264       0.159110       0.159036  
        75+  |     2.121850       2.149318       2.160755  
             |     0.268701       0.272218       0.273611  
-----------------------------------------------------------
                                               legend: b/se
```