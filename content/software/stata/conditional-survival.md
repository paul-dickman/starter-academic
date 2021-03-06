+++
date = "2019-03-13"
title = "Conditional survival"
summary = "Estimate conditional (on surviving some time) relative survival using several approaches. We estimate from both life tables and based on a flexible parametric model."
shortsummary = "" 
tags = ["conditional survival","stpm2","strs","Stata"]
math = true
[header]
image = ""
caption = ""
+++

{{% toc %}}

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/conditional-survival.do).

## Introduction

In this tutorial, I illustrate how to estimate net survival conditional on surviving some time since diagnosis. We estimate conditional survival using both a non-parametric (life table) approach and based on a flexible parametric model. 

The term 'conditional survival' is sometimes used to mean 'conditional on covariates' (to distinguish from marginal survival) and sometimes used to mean 'conditional on having survived up to some time $s$'. Here we estimate the latter.

The conditional survival function $\mbox{CS}(t|s)$ is defined as the probability of surviving an additional $t$ years given a patient has already survived $s$ years. 

$$
\mbox{CS}(t|s) = P(T > t+s | T > s) = \frac{S(s+t)}{S(s)}
$$

We will estimate conditional net survival (CNS), 

$$
\mbox{CNS}(t|s) = \frac{S_N(s+t)}{S_N(s)}
$$

where $S_N(t)$ is net survival. We will estimate net survival 5 years post diagnosis, conditional on having survived 1 year, using 3 approaches:

* Non-parametric (Pohar Perme estimator) by taking the ratio of $S(5) / S(1)$ in a standard cohort life table.
* Non-parametric (Pohar Perme estimator) by restricting the cohort to patients who survive 1 year (i.e., late entry)
* By predicting $S(5) / S(1)$ from a flexible parametric model

Care must be taken when reporting estimates of conditional survival. We will estimate "net survival 5 years post diagnosis conditional on having survived 1 year", which is denoted by $\mbox{CNS}(4|1)$ (the probability of surviving 4 additional years conditional on surviving 1 year). One can see reports presenting "conditional 5-year survival" and it is not clear if this represents 5 years in addition to $s$ or survival up to 5 years post diagnosis conditional on survival to $s$.

We have chosen to use the same notation as [Belot et al (2019)](https://www.dovepress.com/summarising-and-communicating-on-survival-data-according-to-the-audien-peer-reviewed-article-CLEP). References to the use of conditional survival can be found in their tutorial paper.
 
## Estimating S(5)/S(1) from a life table

Estimating conditional survival is not difficult. We simply divide the 5-year survival by the 1-year survival from a standard cohort life table. We'll use the Pohar Perme estimates, but any estimates can be used. The disadvantage of this approach is that we don't get the standard error.

We use `strs` with the pohar option to get the Pohar Perme estimates. By default, `strs` uses the actuarial approach for estimation (i.e., estimation is performed on the survival scale) but if late entry is detected it estimates the cumulative hazard and then transforms to the survival scale. We will use late entry in the next step, so specify the `ht` option (hazard transformation) to force the same approach to estimation here.   

```stata
. use https://pauldickman.com/data/colon.dta, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)
[output omitted]

. strs using http://pauldickman.com/data/popmort, br(0(1)10) mergeby(_year sex _age) ///
>      pohar ht list(n d y cns_pp lo_cns_pp hi_cns_pp)

The conditional survival proportion (p) is estimated by transforming the
estimated cumulative hazard rather than by the actuarial method (default for cohort analysis).
See http://pauldickman.com/rsmodel/stata_colon/standard_errors.pdf for details.

  +---------------------------------------------------------------------+
  | start   end       n      d         y   cns_pp   lo_cns~p   hi_cns~p |
  |---------------------------------------------------------------------|
  |     0     1   15564   5474   12076.1   0.6827     0.6749     0.6905 |
  |     1     2   10089   1885    8685.3   0.5769     0.5681     0.5855 |
  |     2     3    7536    918    6782.8   0.5299     0.5206     0.5392 |
  |     3     4    6114    609    5553.6   0.5006     0.4905     0.5105 |
  |     4     5    5028    456    4608.7   0.4793     0.4685     0.4900 |
  |---------------------------------------------------------------------|
  |     5     6    4210    355    3844.7   0.4607     0.4488     0.4726 |
  |     6     7    3511    254    3208.9   0.4514     0.4382     0.4645 |
  |     7     8    2939    196    2699.1   0.4460     0.4313     0.4606 |
  |     8     9    2476    158    2280.9   0.4435     0.4261     0.4607 |
  |     9    10    2085    146    1892.9   0.4414     0.4210     0.4615 |
  +---------------------------------------------------------------------+

. 
. di 0.4793/0.6827
.70206533
```

In the life table heading, `cns_pp` stands for cumulative net survival (Pohar Perme). It's unfortunate that `cns` is the same acronym as conditional net survival, but they are distinct quantities.

The estimated 5-year net survival is 0.4793, the estimated 1-year net survival is 0.6827, so CNS(4|1) = 0.4793 / 0.6827 = 0.7021 

## Estimation from a life table with late entry

We now restrict the cohort to individuals who survived at least 1 year, by specifying the `enter` option to `stset`.  

```stata  
. stset exit, origin(dx) enter(time dx+365.24) fail(status==1 2) id(id) scale(365.24)

                id:  id
     failure event:  status == 1 2
obs. time interval:  (exit[_n-1], exit]
 enter on or after:  time dx+365.24
 exit on or before:  failure
    t for analysis:  (time-origin)/365.24
            origin:  time dx

------------------------------------------------------------------------------
     15,564  total observations
      5,475  observations end on or before enter()
------------------------------------------------------------------------------
     10,089  observations remaining, representing
     10,089  subjects
      5,444  failures in single-failure-per-subject data
 46,387.985  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         1
                                          last observed exit t =  20.96156
 
. strs using http://pauldickman.com/data/popmort, br(0(1)10) mergeby(_year sex _age) ///
>      pohar list(n d y cns_pp lo_cns_pp hi_cns_pp)

Late entry detected for at least one observation (probably because you are using a
period analysis). The conditional survival proportion (p) is estimated by transforming the
estimated cumulative hazard rather than by the actuarial method (default for cohort analysis).
See http://pauldickman.com/rsmodel/stata_colon/standard_errors.pdf for details.

  +--------------------------------------------------------------------+
  | start   end       n      d        y   cns_pp   lo_cns~p   hi_cns~p |
  |--------------------------------------------------------------------|
  |     1     2   10089   1885   8685.3   0.8450     0.8365     0.8531 |
  |     2     3    7536    918   6782.8   0.7762     0.7656     0.7863 |
  |     3     4    6114    609   5553.6   0.7332     0.7210     0.7449 |
  |     4     5    5028    456   4608.7   0.7020     0.6882     0.7154 |
  |     5     6    4210    355   3844.7   0.6748     0.6589     0.6902 |
  |--------------------------------------------------------------------|
  |     6     7    3511    254   3208.9   0.6612     0.6432     0.6785 |
  |     7     8    2939    196   2699.1   0.6533     0.6328     0.6730 |
  |     8     9    2476    158   2280.9   0.6496     0.6248     0.6732 |
  |     9    10    2085    146   1892.9   0.6465     0.6170     0.6744 |
  +--------------------------------------------------------------------+
```

The estimates in the `cns_pp` column are now the net survival up to the end of the interval conditional on surviving one year. The estimate of $CNS(4|1)=0.7020$ is the same as before but we now get a 95% confidence interval.

## Model-based estimation

We now use a model-based approach. As with the first life table approach, we estimate survival from diagnosis and divide the estimated 5-year survival by the estimated 1-year survival. 

As we are modelling net survival, we need to merge in the external rate. 

```stata 
. // Return to orginal stset (everyone at risk from diagnosis) and merge in expected rates
. stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)

. gen _age = min(int(age + _t),99)
. gen _year = int(yydx + _t)
. sort _year sex _age
. merge m:1 _year sex _age using popmort, keep(match master)

    Result                           # of obs.
    -----------------------------------------
    not matched                             0
    matched                            15,564  (_merge==3)
    -----------------------------------------
 
. // Fit the model without covariates
. stpm2, scale(hazard) df(5) bhazard(rate) 

Log likelihood = -22186.158                     Number of obs     =     15,564
------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
       _rcs1 |   .9455202   .0108963    86.77   0.000     .9241638    .9668766
       _rcs2 |    .322622   .0085993    37.52   0.000     .3057676    .3394763
       _rcs3 |  -.0299373   .0055147    -5.43   0.000    -.0407458   -.0191288
       _rcs4 |   .0365856   .0033271    11.00   0.000     .0300647    .0431066
       _rcs5 |   .0055546   .0025757     2.16   0.031     .0005062     .010603
       _cons |  -.9952705   .0133883   -74.34   0.000    -1.021511   -.9690299
------------------------------------------------------------------------------
```

Rather than just estimate CNS(4|1) we'll estimate $\mbox{CNS}(t|1)$ for a range of values of $t$. We'll first predict the unconditional relative survival at each value of `_t` and store the estimates in a new variable `s`.

Next we want to predict $S(t) / S(1)$ for a range of values of $t$ (where $t$ is now time since diagnosis). 

We will create two [temporary time variables](https://pclambert.net/software/stpm2/stpm2_timevar/), timevar will take 100 values between 1 and 5 while t1 will be set to 1 for each of the observations. We then predict the ratio of S(timevar) / S(t1).

```stata
. predict s, survival ci

. range timevar 1 5 100
(15,464 missing values generated)

. gen t1 = 1 in 1/100
(15,464 missing values generated)

. // Predict S(t) / S(1)  [where t is time since diagnosis]
. predictnl condsurv = predict(survival timevar(timevar)) / predict(survival timevar(t1)) 
(15,464 missing values generated)
```
The variable `condsurv` contains the predicted conditional survival, but we should predict on the log scale to get more appropriate confidence intervals. 

```stata
. predictnl condsurv1 = ln(predict(survival timevar(timevar)) / ///
>                      predict(survival timevar(t1))) , ///
>                                          ci(condsurv1_lci condsurv1_uci)  
(15,464 missing values generated)
note: confidence intervals calculated using Z critical values

. replace condsurv1=exp(condsurv1)
(100 real changes made)

. replace condsurv1_lci=exp(condsurv1_lci)
(100 real changes made)

. replace condsurv1_uci=exp(condsurv1_uci)
(100 real changes made)

. // List S(5)/S(1)                                                        
. list condsurv1 condsurv1_lci condsurv1_uci if timevar==5        

       +--------------------------------+
       | condsu~1   cond~lci   cond~uci |
       |--------------------------------|
  100. | .6903092   .6792465   .7015522 |
       +--------------------------------+
```

Estimates of CNS(4|1) with 95% CIs from the model-based and life-table approaches.

```stata
 | approach   | condsurv |  cond~lci  | cond~uci|
 |------------------------------------|---------|
 | model      |.6903     | .6792      |.7016    | 
 | life table |.6748     | .6589      |.6902    | 
```
         
```stata
. // Plot conditional survival (with CIs) for each value of t     
. twoway  (rarea condsurv1_lci condsurv1_uci timevar, sort) ///
>         (line condsurv1 timevar, sort lpattern(solid)) ///
>         , ytitle("Relative survival conditional on surviving 1 year")  ///
>         ylabel(0(0.2)1,angle(h) format(%3.1f)) xlabel(0(1)5) scheme(sj) ///
>                 legend(off) ysize(8) xsize(11) name(condsurv1,replace)
```

{{< figure src="/svg/conditional-survival1.svg" title="Relative survival conditional on surviving 1 year subsequent to diagnosis. With 95% confidence limits." numbered="true" >}}

We'll now predict survival conditional on surviving 3 years.

```stata 
. gen t3 = 3 in 1/100             
(15,464 missing values generated)

. predictnl condsurv3 = ln(predict(survival timevar(timevar)) / ///
>                      predict(survival timevar(t3))) , ///
>                                          ci(condsurv3_lci condsurv3_uci)  
(15,464 missing values generated)
note: confidence intervals calculated using Z critical values

. replace condsurv3=exp(condsurv3)
(100 real changes made)

. replace condsurv3_lci=exp(condsurv3_lci)
(100 real changes made)

. replace condsurv3_uci=exp(condsurv3_uci)
(100 real changes made)

. twoway  (rarea s_lci s_uci _t if _t<5, sort) ///
>         (line s _t if _t<5, sort lpattern(solid)) ///
>                 (rarea condsurv1_lci condsurv1_uci timevar, sort) ///
>         (line condsurv1 timevar, sort lpattern(dash) lcolor(blue)) ///
>                 (rarea condsurv3_lci condsurv3_uci timevar if timevar>=3, sort) ///
>         (line condsurv3 timevar if timevar>=3, sort lpattern(dash_dot) lcolor(red)) ///
>         , ytitle("Relative survival") scheme(sj)  ysize(8) xsize(11) ///
>                 legend(order(2 "Unconditional" 4 "Conditional on surviving 1 year"  ///
>                 6 "Conditional on surviving 3 years") ring(0) pos(7) col(1)) ///
>         ylabel(0(0.2)1,angle(h) format(%3.1f)) xlabel(0(1)5) name(condsurv,replace)
```

