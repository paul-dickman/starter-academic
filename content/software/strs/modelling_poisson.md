+++
date = "2019-03-03"
title = "Modelling excess mortality using Poisson regression"
summary = "A tutorial illustrating how to model excess mortality (relative survival) using Poisson regression."
tags = ["strs","software","Stata"]
external_link = "" 
math = false
[header]
image = ""
caption = ""
+++

In this example we will model excess mortality (relative survival) as a function of time since diagnosis, sex, calendar period, and age group. This is a two-step process:

1. Run `strs` on the patient data to produce life tables for each combination of predictors and save the results in `grouped.dta`;
2. Open `grouped.dta` and fit the Poisson regression model in the framework of generalised linear models (see [The Stata Journal](/pdf/Dickman2015.pdf) for details.

We first load the colon cancer data (restricting to localised stage) and `stset` (see [here]({{< ref "/software/strs/survival.md" >}}) for details). We then run `strs`; the `notables` option suppresses the printing of life tables.

```stata
. use colon if stage==1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. stset surv_mm, fail(status==1 2) id(id) scale(12)
[output omitted]

. strs using popmort, breaks(0(1)10) mergeby(_year sex _age) ///
>      by(sex year8594 agegrp) notables save(replace)
```

We now open `grouped.dta` (restricting to the first 5 years) and fit the Poisson regression model in the framework of generalised linear models. This model requires a user-defined link function, which is specified in `rs.ado` (included with the `strs` package). 

The variable `end` is the time at the end of the life table interval. We include this in the model to allow excess mortality to vary over time since diagnosis. 

```stata
. use grouped if end < 6, clear
. glm d i.end i.sex i.year8594 i.agegrp , fam(pois) link(rs d_star) lnoffset(y) eform

Generalized linear models                   No. of obs      =         80
Optimization     : ML                       Residual df     =         70
                                            Scale parameter =          1
Deviance         =  131.4342128             (1/df) Deviance =   1.877632
Pearson          =  130.1530694             (1/df) Pearson  =    1.85933

Variance function: V(u) = u                 [Poisson]
Link function    : g(u) = log(u-d*)         [Relative survival]

                                            AIC             =    6.39959
Log likelihood   = -245.9836017             BIC             =  -175.3077

----------------------------------------------------------------------------
           |                 OIM
         d |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------+----------------------------------------------------------------
       end |
        1  |          1  (base)
        2  |   .7984084   .0730515    -2.46   0.014     .6673339     .955228
        3  |   .6230213   .0671961    -4.39   0.000     .5043086    .7696785
        4  |   .4969433   .0645561    -5.38   0.000     .3852391    .6410374
        5  |   .4334347    .065147    -5.56   0.000      .322838    .5819191
           |
       sex |
     Male  |          1  (base)
   Female  |   .9564493   .0729823    -0.58   0.560     .8235891    1.110742
           |
  year8594 |
 Dx 75-84  |          1  (base)
 Dx 85-94  |   .7308044   .0539291    -4.25   0.000     .6323935    .8445296
           |
    agegrp |
     0-44  |          1  (base)
    45-59  |   .8642841   .1353083    -0.93   0.352      .635911    1.174672
    60-74  |   1.071568   .1534869     0.48   0.629     .8092774    1.418869
      75+  |   1.436319   .2146593     2.42   0.015     1.071613    1.925147
           |
     _cons |   .0838687   .0124017   -16.76   0.000     .0627671    .1120644
     ln(y) |          1  (exposure)
----------------------------------------------------------------------------

. estimates store main
```
Because we used the `eform` option, Stata reports exponentiated parameter estimates, which are interpreted as excess hazard ratios. We see, for example, that excess mortality among patients aged 75+ at diagnosis is estimated to be 1.43 times higher than patients aged 0-44 at diagnosis. We have fitted a main effects model, so it is assumed that the excess hazard ratio for the oldest to the youngest is the same for all other combinations of covariates. In particular, it is assumed that the effect of age is the same at each point in time since diagnosis (an assumption of proportional excess hazards). 

There is evidence that the model does not fit (deviance is 131 on 70 df). We could study residuals, but experience tells us to expect non-proportional hazards by age. We will therefore fit an age by time interaction.

```stata
. glm d i.end##i.agegrp i.sex i.year8594 , fam(pois) link(rs d_star) lnoffset(y) eform

Generalized linear models                     No. of obs      =         80
Optimization     : ML                         Residual df     =         58
                                              Scale parameter =          1
Deviance         =  62.68719872               (1/df) Deviance =   1.080814
Pearson          =  59.38427551               (1/df) Pearson  =   1.023867

Variance function: V(u) = u                   [Poisson]
Link function    : g(u) = log(u-d*)           [Relative survival]

                                              AIC             =   5.840252
Log likelihood   = -211.6100946               BIC             =  -191.4703

----------------------------------------------------------------------------
           |                 OIM
         d |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------+----------------------------------------------------------------
       end |
        1  |          1  (base)
        2  |   1.946643   .7393758     1.75   0.079     .9246602    4.098175
        3  |   1.222286   .5250573     0.47   0.640       .52665    2.836765
        4  |   1.236052   .5437691     0.48   0.630     .5218824    2.927526
        5  |   .9972442   .4815703    -0.01   0.995     .3870396    2.569494
           |
    agegrp |
     0-44  |          1  (base)
    45-59  |   1.123855   .3928157     0.33   0.738     .5664919    2.229598
    60-74  |   1.713279   .5471182     1.69   0.092     .9162322    3.203691
      75+  |   3.853296   1.215987     4.27   0.000     2.075955    7.152316
           |
end#agegrp |
  2#45-59  |    .520314   .2346698    -1.45   0.147     .2149613    1.259421
  2#60-74  |   .5310847   .2141314    -1.57   0.117     .2409697    1.170483
    2#75+  |   .2272661   .0952094    -3.54   0.000     .0999856    .5165729
  3#45-59  |   1.094786   .5355257     0.19   0.853     .4197157    2.855638
  3#60-74  |   .6122161   .2814612    -1.07   0.286     .2486406    1.507431
    3#75+  |   .1734874   .0957661    -3.17   0.002      .058803    .5118427
  4#45-59  |   .6500614   .3411042    -0.82   0.412     .2324377    1.818034
  4#60-74  |   .5098014   .2441163    -1.41   0.159     .1994374    1.303153
    4#75+  |   .1372391   .0892634    -3.05   0.002     .0383563    .4910418
  5#45-59  |   .8627336   .4853465    -0.26   0.793     .2864295    2.598578
  5#60-74  |   .5827383   .3081216    -1.02   0.307     .2067296    1.642648
    5#75+  |   6.18e-06   .0049514    -0.01   0.988            0           .
           |
       sex |
     Male  |          1  (base)
   Female  |   .9391009      .0708    -0.83   0.405     .8101009    1.088643
           |
  year8594 |
 Dx 75-84  |          1  (base)
 Dx 85-94  |   .7161733   .0525238    -4.55   0.000     .6202853    .8268844
           |
     _cons |   .0462192   .0142655    -9.96   0.000     .0252407    .0846338
     ln(y) |          1  (exposure)
----------------------------------------------------------------------------

. lrtest main

Likelihood-ratio test            LR chi2(12) =     68.75
(Assumption: main nested in .)   Prob > chi2 =    0.0000
```

We see that the interaction terms (12 extra parameters) were highly statistically significant (likelihood ratio test). The deviance is now close to the residual df, meaning there is no longer evidence of lack of fit.
