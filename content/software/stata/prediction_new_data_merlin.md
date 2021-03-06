+++
date = "2019-11-25"
title = "Predicting in a new data set with merlin"
subtitle = "Paul Dickman, Michael Crowther"
summary = "Illustrates how to fit a model using patient data and then predict in a second dataset specifically constructed to contain only the covariates for which we wish to predict. Age is modelled using a restricted cubic spline."
tags = ["stpm2","merlin","prediction","fillin","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/prediction_new_data_merlin.do).

Last month I posted a [tutorial](/software/stata/prediction_new_data/) illustrating how, after fitting a Royston-Parmar model with `stpm2`, to predict in a second dataset specifically constructed to contain only the covariates for which we wish to predict. Because we modelled age as a restricted cubic spline, we needed to use `rcsgen` to generate the spline basis functions prior to model fitting, taking care to save the knot locations and projection matrix so as to generate spline basis functions in the prediction step.

A week ago, Michael Crowther posted a [tutorial](https://www.mjcrowther.co.uk/2019/11/15/reason-no.-437-to-use-merlin-modelling-and-prediction-with-non-linear-effects/) showing how modelling and predicting with splines is considerably easier with [`merlin`](https://www.mjcrowther.co.uk/software/merlin/). The `rcs()` element type in `merlin` makes it possible to model age as a restricted cubic spline without the need to explicitly create the spline basis functions and, more importantly, generate predictions from the fitted model at specified values of age without creating the spline basis functions.  

Here we reproduce the analysis made using `stpm2` by fitting the same model using `merlin` and making the same predictions.

```stata 
. use https://pauldickman.com/data/colon if age>=40&age<=90, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. // Create an indicator variable for sex
. generate female=(sex==2)

. // All-cause death as outcome, censor at 5 years
. stset surv_mm, failure(status=1,2) scale(12) id(id) exit(time 60.5)

                id:  id
     failure event:  status == 1 2
obs. time interval:  (surv_mm[_n-1], surv_mm]
 exit on or before:  time 60.5
    t for analysis:  time/12

------------------------------------------------------------------------------
     15,002  total observations
          0  exclusions
------------------------------------------------------------------------------
     15,002  observations remaining, representing
     15,002  subjects
      9,035  failures in single-failure-per-subject data
   36,602.5  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =  5.041667
```
We now fit a Royston-Parmar model using [merlin](https://www.mjcrowther.co.uk/software/merlin/). We are reproducing the following model fitted using stpm2 in a [previous tutorial](/software/stata/prediction_new_data/). 

```stata
. stpm2 female rcsage1-rcsage4, scale(hazard) df(5) tvc(female) dftvc(2)
```

We are using 5 df for the baseline log cumulative hazard, 4 df for age, and 2 df for the time-varying effect of sex.

```stata 
. merlin (_t female female#rcs(_t, df(2) event log orthog) ///
>            rcs(age, df(4) orthog) ///
>                    , family(rp, df(5) failure(_d)) timevar(_t))   
variables created: _rcs1_1 to _rcs1_5
variables created for model 1, component 2: _cmp_1_2_1 to _cmp_1_2_2
variables created for model 1, component 3: _cmp_1_3_1 to _cmp_1_3_4

Fitting full model:

Iteration 0:   log likelihood = -25002.846  
Iteration 1:   log likelihood =  -19416.38  
Iteration 2:   log likelihood = -19344.041  
Iteration 3:   log likelihood = -19266.091  
Iteration 4:   log likelihood =   -19265.5  
Iteration 5:   log likelihood = -19265.499  

Mixed effects regression model                  Number of obs     =     15,002
Log likelihood = -19265.499
------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
_t:          |            
      female |  -.0995722   .0238004    -4.18   0.000    -.1462202   -.0529242
female#rcs~1 |   .0046899   .0198375     0.24   0.813    -.0341909    .0435707
female#rcs~2 |   .0374478   .0126096     2.97   0.003     .0127334    .0621621
     rcs():1 |   .3069031   .0111876    27.43   0.000     .2849759    .3288303
     rcs():2 |  -.0964885   .0110371    -8.74   0.000    -.1181208   -.0748561
     rcs():3 |  -.0452527   .0107874    -4.19   0.000    -.0663957   -.0241097
     rcs():4 |  -.0322202   .0101819    -3.16   0.002    -.0521763   -.0122641
       _cons |  -.7881003    .018171   -43.37   0.000    -.8237147   -.7524859
------------------------------------------------------------------------------
    Warning: Baseline spline coefficients not shown - use ml display
```
We now create a new dataset in which to generate the predictions. Although we are clearing the data in memory, the results from the last fitted model are still available in `e()` for prediction.
```stata
. clear

. range age 20 100 81
number of observations (_N) was 0, now 81

. range female 0 1 2
(79 missing values generated)

. range _t 0 6 25
(56 missing values generated)

. fillin age female _t

. drop if missing(age, female, _t)
(2,268 observations deleted)
```
The outcome variable (`_d`) must exist in the data set in order to predict. We will set it to missing for all observations. 

At the time of writing, `merlin` does not predict survival at time 0 (the 162 missing values generated below) so we set survival to 1 at time zero.

```stata
. generate _d=.
(4,050 missing values generated)

. predict s2, survival timevar(_t)
variables created: _rcs1_1 to _rcs1_5
(162 missing values generated)

. // Set survival to 1 at time zero
. replace s2=1 if _t==0
(162 real changes made)
```

 

