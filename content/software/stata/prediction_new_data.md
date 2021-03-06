+++
date = "2019-10-20"
title = "Predicting in a new data set with stpm2"
subtitle = "Paul Dickman, Paul Lambert"
summary = "Illustrates how to fit a model using patient data and then predict in a second dataset specifically constructed to contain only the covariates for which we wish to predict. Age is modelled using a restricted cubic spline."
tags = ["stpm2","prediction","fillin","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/prediction_new_data.do).

In this tutorial we model all-cause survival using flexible parametric models. The same principles apply if one is interested in cause-specific survival (change `stset`) or relative/net survival (use the `bhazard()` option with `stpm2`).

We fit the model to the patient data amd then predict survival in a second data set, specifically constructed to contain only the covariates for which we wish to predict.

The code below fits a flexible parametric model for all cause survival with sex and age as covariates. Age is modelled using a restricted cubic spline with 4 df. When we generate the spline basis vectors, we also store the projection matrix and knot locations to use when generating the spline basis vectors in the data set that will be used for prediction.

```stata
. use https://pauldickman.com/data/colon if age>=40&age<=90, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. // Create an indicator variable for sex
. generate female=(sex==2)

. // All-cause death as outcome, censor at 5 years
. stset surv_mm, failure(status=1,2) scale(12) id(id) exit(time 60.5)

[output deleted]
 
. // Generate splines for age; store knot locations and projection matrix         
. rcsgen age, gen(rcsage) df(4) orthog
Variables rcsage1 to rcsage4 were created

. matrix Rage = r(R)

. global knotsage `r(knots)'

. // fit model allowing non-proportional hazards for sex
. stpm2 female rcsage1-rcsage4, scale(hazard) df(5) tvc(female) dftvc(2)
```

We now create the a data set containing the covariate patters for which we wish to predict. We will create one observation for each combination of:

* age (81 integer values from 20 to 100)
* sex (2 categories)
* time-since diagnosis, `_t` (25 values between 0 and 6)  
 
We begin by creating the variables `age` (81 unique values), `sex` (2 unique values), and `_t` (25 unique values). The data set will at this stage have 81 observations (sex will be missing for 79 observations and `_t` missing for 56 observations).

The `fillin` command 'rectangularises' the data set. That is, it expands the data set to create all combinations of values of the specified variables. Missing values are treated as unique categories, which is not what we want in this application, so we drop all observations with missing values.

This leaves us with a data set with 81*2*25=4050 observations. We create the spline variables for age using the projection matrix and knot locations stored from the patient data. We can then use the `predict` command to predict survival for each observation using the most recently fitted model (which was fitted to the patient data).  
 
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

. rcsgen age, gen(rcsage) rmatrix(Rage) knots($knotsage)
Variables rcsage1 to rcsage4 were created

. predict s2, survival timevar(_t)
```