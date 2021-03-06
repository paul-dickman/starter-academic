+++
date = "2021-02-03"
title = "Estimating a hazard ratio in the presence of effect modification"
subtitle = "Paul Dickman"
summary = "After fitting a flexible parametric model, we estimate and plot the hazard ratio for a covariate that is modified by another covariate."
shortsummary = "After fitting a flexible parametric model, we estimate and plot the hazard ratio for a covariate that is modified by another covariate." 
tags = ["stpm2","interaction","prediction","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/hazard_ratio_with_effect_modification.do).

In this tutorial we will model cause-specific survival using flexible parametric models, with a focus on studying whether the effect of a binary exposure of interest (sex in this case) varies as a function of year of diagnosis (modelled as a restricted cubic spline). The same approach works if we are interested in relative survival (just include the `bhazard()` option when modelling and stset with all deaths as the outcome).

We will produce the following plot.

{{< figure src="/svg/hazard_ratio_with_effect_modification.svg" title="Hazard ratio for sex (males/females) predicted from a flexible parametric model with an interaction between sex and year of diagnosis (modelled as a restricted cubic spline). The hazard ratio is assumed to be constant over follow-up time (i.e., proportional hazards)." numbered="false" >}}

We start by reading the data and creating dummy variables and interactions to be used in modelling. We `stset` with time since diagnosis as the timescale and censor at 10 years (120 months). We will model year of diagnosis as a restricted cubic spline with 3 degrees of freedom. We use the `rcsgen` command to create the 3 spline basis variables and then create the interaction between sex and year of diagnosis.

```stata
. // exclude unknown stage (stage==0)
. use https://pauldickman.com/data/melanoma.dta if stage>0, clear
(Skin melanoma, diagnosed 1975-94, follow-up to 1995)

. 
. // cause-specific survival (status==1 is death due to melanoma) 
. stset surv_mm, fail(status==1) scale(12) exit(time 120)

     failure event:  status == 1
obs. time interval:  (0, surv_mm]
 exit on or before:  time 120
    t for analysis:  time/12

------------------------------------------------------------------------------
      6,144  total observations
          0  exclusions
------------------------------------------------------------------------------
      6,144  observations remaining, representing
      1,579  failures in single-record/single-failure data
 34,495.708  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =        10

. // create dummy variables for modelling
. generate male=(sex==1)

. quietly tab agegrp, generate(agegrp)

. // spline variables for year of diagnosis
. rcsgen yydx, df(3) gen(yearspl) orthog
Variables yearspl1 to yearspl3 were created

. 
. // interaction between sex and yearspl
. generate maleyr1=male*yearspl1
. generate maleyr2=male*yearspl2
. generate maleyr3=male*yearspl3
```
We now fit the model.

```stata
. stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
>       tvc(agegrp2 agegrp3 agegrp4) dftvc(2)

[output omitted]
```

Note that sex and year of diagnosis do not appear in the `tvc()` option so are assumed to be constant over time since diagnosis.

We now predict the hazard ratio for sex.

```stata
predict hr if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) ci
```
The hazard ratio will be predicted for every observation (where sex is male) at `_t` the time of exit. Since we have assumed proportional hazards, the predicted HR is the same for all values of time so it does not matter at which value we predict.

The `predict` command after `stpm2` sets the value of any covariates not explicitly mentioned to zero. If the model contained no interactions with sex then we could use
```stata
predict hr, hrnumerator(male 1) ci
```
That is, the numerator would be the (partial) hazard for males (`male=1`) and the denominator would be the (partial) hazard for females (`male=0` which is the default if we do not explicitly define the denominator).

Our model contains an interation between sex and year, so the syntax is slightly more complicated. The (partial) hazard for males is specified by male=1, maleyr1=yearspl1, maleyr2=yearspl2, and maleyr3=yearspl3.

The syntax of `predict` specifies that "." is the observed value of the covariates. Therefore, we  predict only for males at the observed values of covariates. That is  

```stata
predict hr if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) ci
```
We can then plot the predicted hazard ratios with 95% confidence intervals.

{{< figure src="/svg/hazard_ratio_with_effect_modification.svg" title="Hazard ratio for sex (males/females) predicted from a flexible parametric model with an interaction between sex and year of diagnosis (modelled as a restricted cubic spline). The hazard ratio is assumed to be constant over follow-up time (i.e., proportional hazards)." numbered="false" >}}

We can use a likelihood ratio test to test if there is evidence that the HR varies over year of diagnosis versus the null hypothesis that it is constant over year of diagnosis. 

```stata
// fit model with interaction (i.e., model under alternative hypothesis)
. stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
>       tvc(agegrp2 agegrp3 agegrp4) dftvc(2)
[output omitted]
. estimates store interaction

// fit model without interaction (i.e., model under null hypothesis)
. stpm2 yearspl* male agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
>       tvc(agegrp2 agegrp3 agegrp4) dftvc(2)
[output omitted]
. lrtest interaction

Likelihood-ratio test                                 LR chi2(3)  =      1.05
(Assumption: . nested in interaction)                 Prob > chi2 =    0.7885
```

We see no evidence against the null hypothesis.

We can also relax the assumption that the HR for sex is constant over follow-up time. The predicted hazard ratio is then potentially different for each value of time since diagnosis.

```stata
. stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
>       tvc(yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4) dftvc(2)
[output omitted]

. // predict the HR at 1, 5, and 10 years
. generate t1=1
. generate t5=5
. generate t10=10

.           
. predict hr1 if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) timevar(t1)
. predict hr5 if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) timevar(t5) 
. predict hr10 if male, hrnumerator(male . maleyr1 . maleyr2 . maleyr3 .) timevar(t10)
```

{{< figure src="/svg/hazard_ratio_with_effect_modification_tvc.svg" title="Hazard ratio for sex (males/females) predicted from a flexible parametric model with an interaction between sex and year of diagnosis (modelled as a restricted cubic spline). The hazard ratio is allowed to vary over follow-up time (i.e., we have relaxed the proportional hazards assumption) and is predicted at 3 selected values of time." numbered="false" >}}
