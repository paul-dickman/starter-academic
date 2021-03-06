+++
date = "2019-03-09"
title = "Model-based age-standardisation with stpm2"
summary = "In this tutorial, we use a model-based approach to estimate all-cause survival that is age-standardised to the International Cancer Survival Standard (ICSS). In a separate tutorial, we accomplished this by fitting a separate model for each age group and then taking the weighted average of the age-specific estimates to get the age-standardised estimates. In this tutorial we apply the weights at an individual level, which precludes the need to explicitly estimate survival within each age group."
shortsummary = "" 
tags = ["stpm2","age-standardisation","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/model-based-standardisation.do).

In this tutorial, we use a model-based approach to estimate all-cause survival that is age-standardised to the International Cancer Survival Standard (ICSS). In a [separate tutorial](/software/stata/prediction-out-of-sample/), we accomplished this by predicting survival for each age group and then taking the weighted average of the age-specific estimates to get the age-standardised estimates.

In this tutorial we will apply the weights at an individual level, which precludes the need to explicitly estimate survival within each age group. 

We begin by loading the colon cancer data (restricting to localised stage) and `stset`.

```stata
. use https://pauldickman.com/data/colon.dta if stage==1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. keep surv_mm status yydx age 

. stset surv_mm, fail(status==1,2) scale(12)

     failure event:  status == 1 2
obs. time interval:  (0, surv_mm]
 exit on or before:  failure
    t for analysis:  time/12

------------------------------------------------------------------------------
      6,274  total observations
          0  exclusions
------------------------------------------------------------------------------
      6,274  observations remaining, representing
      3,291  failures in single-record/single-failure data
  35,598.75  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
```

We now create the spline basis vectors to model year of diagnosis using restricted cubic splines and create new age groups corresponding to the International Cancer Survival Standard ([Corazziari et al 2004](https://doi.org/10.1016/j.ejca.2004.07.002)). `stpm2` supports Stata factor variable syntax (`i.`) for main effects, but not time-varying effects so we will create dummy variables for agegrp. 

```stata
. /*spline variable for year of diagnosis*/
. rcsgen yydx, df(3) gen(yearspl) orthog
Variables yearspl1 to yearspl3 were created

. // New age groups according to the International Cancer Survival Standard (ICSS)
. label drop agegrp
. egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
. label variable agegrp "Age group"
. label define agegrp 1 "15-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+" 
. label values agegrp agegrp

. // Generate dummy variables for agegrp
. quietly tab agegrp, gen(agegrp)
```

We will now create an individual weight for each observation, calculated as the proportion of patients in the given age group in the standard population (ICSS) divided by the proportion in that age group in our patient data.

In our data set, 4.73% of patients are in the youngest age group compared to 7% in the standard population. As such, each patients in the youngest age group in our population will be given a weight of `7/4.73=1.48`. At the other end of the age scale, 36.15% of the patients are in the oldest age group compared to 29% in the standard population. As such, each patients in the oldest age group in our population will be given a weight of `29/36.15=0.80`. Our population is older than the standard population, so when age-standardising we will up-weight the young and down-weight the elderly.

`_N` is a Stata system variable that contains the total number of observations in the dataset. In the code below we write the total number of observations to a local macro variable (`total`). When we reference `_N` within `bysort` its value will be the number of observations within the by group. In this way, we generate the variable `a_age` to contain the proportion of observations in each age group. 

```stata 
. // Create weights to use for age-standardisation
. recode agegrp (1=0.07) (2=0.12) (3=0.23) (4=0.29) (5=0.29), gen(ICSSwt)
(6274 differences between agegrp and ICSSwt)

. local total= _N
. bysort agegrp:gen a_age = _N/`total'
. gen w = ICSSwt/a_age

. tabstat w, statistics( mean min max) by(agegrp)

Summary for variables: w
     by categories of: agegrp (Age group)

agegrp |      mean       min       max
-------+------------------------------
 15-44 |  1.478721  1.478721  1.478721
 45-54 |  1.447846  1.447846  1.447846
 55-64 |  1.234406  1.234406  1.234406
 65-74 |  .9007227  .9007227  .9007227
   75+ |  .8022311  .8022311  .8022311
-------+------------------------------
 Total |         1  .8022311  1.478721
--------------------------------------
```
The weights are constant within each age group, and decrease with increasing age.

We have created the weights, but will not use them just yet. We now fit a flexible parametric model adjusting for calendar year of diagnosis (as a restricted cubic spline) and age group.

```stata 
. stpm2 yearspl? agegrp2 agegrp3 agegrp4 agegrp5, scale(h) df(4) eform ///
>   tvc(yearspl? agegrp2 agegrp3 agegrp4 agegrp5) dftvc(1)

Iteration 0:   log likelihood = -8253.8872  
Iteration 1:   log likelihood = -8182.2058  
Iteration 2:   log likelihood = -8179.6265  
Iteration 3:   log likelihood = -8179.6199  
Iteration 4:   log likelihood = -8179.6199  

Log likelihood = -8179.6199                     Number of obs     =      6,274

----------------------------------------------------------------------------------
                 |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-----------------+----------------------------------------------------------------
xb               |
        yearspl1 |   .8683429   .0207813    -5.90   0.000     .8285528    .9100439
        yearspl2 |   .9961899   .0220676    -0.17   0.863     .9538637    1.040394
        yearspl3 |   1.057278   .0230945     2.55   0.011     1.012969    1.103525
         agegrp2 |   1.187213   .1970927     1.03   0.301     .8574685    1.643763
         agegrp3 |   1.385942   .2046868     2.21   0.027     1.037607    1.851216
         agegrp4 |   2.308078   .3230204     5.98   0.000     1.754377    3.036532
         agegrp5 |   4.454763   .6146422    10.83   0.000     3.399232    5.838058
           _rcs1 |   2.566524   .2379096    10.17   0.000     2.140136    3.077863
           _rcs2 |   .9525124   .0121212    -3.82   0.000      .929049    .9765683
           _rcs3 |   .9850944   .0075191    -1.97   0.049     .9704669    .9999424
           _rcs4 |   1.005493   .0059038     0.93   0.351     .9939882    1.017131
  _rcs_yearspl11 |   1.036719   .0225516     1.66   0.097     .9934475    1.081875
  _rcs_yearspl21 |   1.002712   .0191478     0.14   0.887     .9658764    1.040952
  _rcs_yearspl31 |   .9806256   .0176908    -1.08   0.278     .9465581    1.015919
   _rcs_agegrp21 |   1.033909   .1184814     0.29   0.771     .8259205    1.294274
   _rcs_agegrp31 |   1.075245   .1089989     0.72   0.474      .881496     1.31158
   _rcs_agegrp41 |   1.232513   .1184007     2.18   0.030     1.020989    1.487859
   _rcs_agegrp51 |   1.091913   .1029258     0.93   0.351     .9077206    1.313481
           _cons |   .1386212   .0187748   -14.59   0.000     .1063024    .1807657
----------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.
```

We will now predict survival based on the fitted model. By default, the `predict` command will predict survival at the value of `_t` (time of end of follow-up) for each observation. For simplicity and computational efficiency, we will create a temporary time variable for which to make predictions. Paul Lambert has written a tutorial on the use of [temporary time variables](https://pclambert.net/software/stpm2/stpm2_timevar/).  

We will predict survival for each of 101 unique values of time (every 0.1 years from 0 to 10) rather than for each of the 6,274 observations in the data set.

We start with predicting the unweighted (unstandardised) marginal survival. At each of the values of time, we predict the marginal (population-averaged) survival using the meansurv option to the predict command. For time=0, the marginal survival is trivially 1. The next value of temptime is 0.1. What meansurv effectively does is it predicts the survival at time 0.1 for each of the 6,274 observations in the data set (conditional on covariates for each observation) and then takes the average of these 6,274 observations. This continues for each of the other values of temptime.

```stata 
. range temptime 0 10 101
(6,173 missing values generated)

. // marginal (population-averaged) survival
. predict s_unweighted, meansurv timevar(temptime)

. // marginal (population-averaged) survival standardised to ICSS
. predict s_weighted, meansurv meansurvwt(w) timevar(temptime)
```

Another way of conceptualising this, is that for each of the 6,274 observations in the data set we predict the survivor function (from time 0 to 10) for the individual with given values of year and age. We then average the 6,274 individual survival curves to get the marginal survival curve. This is stored in the variable `s_unweighted`.

To get the age-standardised marginal (population-averaged) survival, we apply weights when we take the average of the individual survival curves. Following is the code for plotting the two resulting curves.

```stata 
. twoway  (line s_weighted temptime , sort lpattern(shortdash) lwidth(medthick) lcolor(black)) ///
>                 (line s_unweighted temptime , sort lpattern(solid) lwidth(medthick) lcolor(black)) ///
>                 , legend(label(1 "Marginal survival (standardised)") label(2 "Marginal survival (unstandardised)") ring(0) pos(7) col(1)) ///
>                 scheme(sj) name(surv1, replace) ysize(8) xsize(11) ///
>                 subtitle("`text`i''", size(*1.0)) ytitle("All-cause survival", size(*1.0)) xtitle("Years since diagnosis", size(*1.0)) ///
>                 ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.0) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.0))
```

{{< figure src="/svg/model-based-standardisation.svg" title="Unstandardised and standardised marginal (population-averaged) all-cause survival." numbered="true" >}}

Standardised survival is higher than the unstandardised, which is as expected because our patient population is older than the standard population. The standardised survival curve is what we would see if our population had the same age-specific survival but the age distribution of the (younger) standard population. Below you see the age distribution of our population.

```stata 
. tab agegrp

  Age group |      Freq.     Percent        Cum.
------------+-----------------------------------
      15-44 |        297        4.73        4.73
      45-54 |        520        8.29       13.02
      55-64 |      1,169       18.63       31.65
      65-74 |      2,020       32.20       63.85
        75+ |      2,268       36.15      100.00
------------+-----------------------------------
      Total |      6,274      100.00
```

Now let's just estimate 5-year survival, to illustrate what `predict, meansurv` is doing. Rather than a range of temporary time variable we have just one variable, `t5`, which takes the value 5 for all observations. 

We start by predicting the 5-year survival for each observation for the given values of year and age and store it in the variable `s5`. We call this the 5-year survival conditional on covariates.

We then predict the marginal (population-averaged) 5-year survival both with and without weighting.

```stata 
. drop temptime
 
. generate t5=5

. // 5-year survival conditional on covariates
. predict s5, survival timevar(t5)

. // 5-year marginal (population-averaged) survival
. predict s5_unweighted, meansurv timevar(t5)

. // 5-year marginal (population-averaged) survival standardised to ICSS
. predict s5_weighted, meansurv meansurvwt(w) timevar(t5)
```

We can have a look at the first 5 rows in the data set. `s5` will potentially differ for each covariate pattern (since it is the predicted 5-year survival conditional on covariates).   

```stata 
. list yydx agegrp s5 s5_unweighted s5_weighted in 1/5

     +---------------------------------------------------+
     | yydx   agegrp          s5   s5_unwe~d   s5_weig~d |
     |---------------------------------------------------|
  1. | 1982    15-44   .82990125   .61272163   .64306652 |
  2. | 1987    15-44   .83144508   .61272163   .64306652 |
  3. | 1981    15-44   .82593014   .61272163   .64306652 |
  4. | 1981    15-44   .82593014   .61272163   .64306652 |
  5. | 1994    15-44   .87029606   .61272163   .64306652 |
     +---------------------------------------------------+
```

The unweighted marginal 5-year survival is simply the arithmetic average of the 6,274 values of `s5` and will be the same for all obervations in the data set. We see below that the average of `s5` is .6127216, identical to the value of `s5_unweighted` above.

```stata 
. summarize s5

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
          s5 |      6,274    .6127216    .1494382   .3118262   .8702961
```

The standardised (weighted) marginal 5-year survival is simply the weighted arithmetic average of the 6,274 values of `s5` and will be the same for all obervations in the data set. If we multiply `s5` by the weight (`w`) and average we see below that the result is identical to the value of `s5_weighted` above.

```stata  
. generate s5w=s5*w

. summarize s5w

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
         s5w |      6,274    .6430665    .2985234   .2501567   1.286925
```

I have used the terms marginal and conditional to link to the way these terms are used in the causal inference literature. The conditional survival here is conditional on covariates. One can also estimate survival conditional on already having already survived up to some value of time, which is further explained [here](http://pauldickman.com/software/stata/conditional-survival/). 

## **Possible extensions and questions**

Q: What if I want to estimate age-standardised relative survival?

A: The code is almost identical. Just add the `bhazard` option to `stpm2`.

<br>

Q: Why did you use all-cause survival (rather than relative survival) in this tutorial?

A: Because I also used all-cause survival in [this tutorial](/software/stata/prediction-out-of-sample/). In the other tutorial I did age-standardisation by first estimating age-specific estimates. This was problematic for the youngest age group where there were few cases. This illustrates the advantage of the approach using weighting, since we do not have to estimate within age strata.

## **Index**
- [Index of Stata tutorials](/software/stata/)
