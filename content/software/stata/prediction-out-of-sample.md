+++
date = "2019-10-21"
title = "Out-of-sample predictions and model-based age-standardistion with stpm2"
subtitle = "Paul Dickman, Paul Lambert"
summary = "Creating a second dataset in which to make predictions and an approach to model-based direct age-standardisation."
shortsummary = "Creating a second dataset in which to make predictions and an approach to model-based direct age-standardisation." 
tags = ["stpm2","standardisation","prediction","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/prediction-out-of-sample.do).

In this tutorial we will model all-cause survival using flexible parametric models, with a focus on estimating/predicting temporal trends in 1-year survival and 5-year survival. The same approach works if we are interested in relative survival (just include the bhazard() option when modelling). We will highlight Stata approaches to two specific features

- creating a second dataset in which we make the predictions (including out-of-sample prediction)
- direct age-standardisation (by taking the weighted average of age-specific estimates)

Our ultimate aim is to produce the following graph:

{{< figure src="/svg/prediction-out-of-sample-surv5.svg" title="Temporal trends in 5-year all-cause survival. Patients diagnosed with localised colon cancer 1975-94 with follow-up to the end of 1995." numbered="false" >}}

Patients are diagnosed 1975-94 with follow-up to the end of 1995. As such, the predictions of 5-year survival for patients diagnosed 1975-1989 are based on the actual follow-up of patients during those years, whereas the predictions for 1995-1999 are "out-of-sample". The estimates for the years 1990-1994 are partially out of sample, since patients diagnosed in these years do not have a complete 5-year follow-up.

We will model year of diagnosis using natural splines, so need to create the spline basis vectors. We create these in the patient data (the data used for fitting the model) and save the projection matrix and knot locations.

```stata
. use https://pauldickman.com/data/colon.dta if stage==1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. rcsgen yydx, df(3) gen(yearspl) orthog
Variables yearspl1 to yearspl3 were created

. matrix Ryydx = r(R)

. global knotyydx `r(knots)'
```

Now create the data set in which we will make the predictions. We must include the Stata internal variable `\_t` to the data set (the predict command requires it), but it will not used in the predictions. We will predict 1 and 5 year survival, so create two variables (`t1` and `t5`) that take the values of time at which we wish to predict (i.e., 1 and 5). 

Our new data set will contain one observation for each covariate pattern we wish to predict. We will create a data set with 49 observations, 1 observation for each year from 1975 to 1999 in 0.5 year increments.

```stata
. clear

. range yydx 1975 1999 49
number of observations (_N) was 0, now 49

. // create spline variables using patient data projection matrix and knots
. rcsgen yydx, gen(yearspl) rmatrix(Ryydx) knots($knotyydx)
Variables yearspl1 to yearspl3 were created

. gen t1=1 

. gen t5=5 

. gen _t=.
(49 missing values generated)

. save predictions, replace
file predictions.dta saved
```
This data set (with 49 observations) has now been saved (as `predictions.dta`). We will now fit a model to real patient data and, using that model, predict survival for each of the values of year in `predictions.dta`. 

We now load the colon cancer data (restricting to localised stage) and `stset`. Note that `status==1` denotes death due to colon cancer and `status==2` denotes death due to other causes. We specify both of these to be events of interest (`fail(status==1,2)`); that is, we are estimating all-cause survival. The same approach works if we are interested in estimating relative survival; we just include the `bhazard()` option when modelling using `stpm2` (in the next step). 

```stata
. use http://pauldickman.com/data/colon.dta if stage==1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

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
                                          last observed exit t =  20.95833
```

We now create the spline basis vectors to model year of diagnosis using restricted cubic splines and create new age groups corresponding to the International Cancer Survival Standard ([Corazziari et al 2004](https://doi.org/10.1016/j.ejca.2004.07.002)).  

```stata
. rcsgen yydx, df(3) gen(yearspl) orthog
Variables yearspl1 to yearspl3 were created
 
. // New age groups according to the International Cancer Survival Standard (ICSS)
. drop agegrp
. label drop agegrp
. egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
. label variable agegrp "Age group"
. label define agegrp 1 "15-44" 2 "45-54" 3 "55-64" 4 "65-74" 5 "75+" 
. label values agegrp agegrp
```

We now fit a separate model for each age group and predict 1-year and 5-year all-cause survival for each observation in `predictions.dta`.

```stata
. forvalues j = 1/5 {
  2. stpm2 yearspl? if agegrp==`j', scale(h) df(4) eform tvc(yearspl?) dftvc(1)
  3. preserve
  4. use predictions, clear
  5. predict stand1_`j', s timevar(t1)
  6. predict stand5_`j', s timevar(t5)
  7. save predictions, replace
  8. restore
  9. }
[output omitted]
```

At the end of this step, `predictions.dta` will contain the same 49 observations we first created, but we are adding 10 variables containing the age-specific predictions (1 and 5-year survival for each of the 5 age groups). Adding the `ci` option to the predict statements would give confidence intervals (see example below).

We now calculate the age-standardised estimates as the weighted average of the age-specific estimates (using the ICSS weights for colon cancer). 

```stata
. use predictions, clear
. gen rs_stand1yr = 0.07*stand1_1 + 0.12*stand1_2 + 0.23*stand1_3 + 0.29*stand1_4 + 0.29*stand1_5
. gen rs_stand5yr = 0.07*stand5_1 + 0.12*stand5_2 + 0.23*stand5_3 + 0.29*stand5_4 + 0.29*stand5_5
```

Now plot the age-specific and age-standardised estimates.

```stata 
. twoway  (line stand1_1 yydx , sort lpattern(shortdash) lwidth(medthick) lcolor(black)) ///
>                 (line stand1_2 yydx , sort lpattern(dash_dot) lwidth(medthick) lcolor(black)) ///
>                 (line stand1_3 yydx , sort lpattern(longdash) lwidth(medthick) lcolor(black)) ///
>                 (line stand1_4 yydx , sort lpattern(longdash_dot) lwidth(medthick) lcolor(black)) ///
>                 (line stand1_5 yydx , sort lpattern(solid) lwidth(medthick) lcolor(black)) ///
>                 (line rs_stand1yr yydx, sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
>                 , legend(label(1 "18-44") label(2 "45-59") label(3 "55-64") label(4 "65-74") label(5 "75+")   ///  
>                 label(6 "Age stand") ring(0) pos(6) col(2)) scheme(sj) name(rsr1_agegrp, replace) xline(1994) ///
>                 subtitle("`text`i''", size(*1.0)) ytitle("1-year RSR", size(*1.0)) xtitle("Year of diagnosis", size(*1.0)) ///
>                 ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.0) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.0))

. 
. twoway  (line stand5_1 yydx , sort lpattern(shortdash) lwidth(medthick) lcolor(black)) ///
>                 (line stand5_2 yydx , sort lpattern(dash_dot) lwidth(medthick) lcolor(black)) ///
>                 (line stand5_3 yydx , sort lpattern(longdash) lwidth(medthick) lcolor(black)) ///
>                 (line stand5_4 yydx , sort lpattern(longdash_dot) lwidth(medthick) lcolor(black)) ///
>                 (line stand5_5 yydx , sort lpattern(solid) lwidth(medthick) lcolor(black)) ///
>                 (line rs_stand5yr yydx, sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
>                 , legend(label(1 "18-44") label(2 "45-59") label(3 "55-64") label(4 "65-74") label(5 "75+")   ///  
>                 label(6 "Age stand") ring(0) pos(6) col(2)) scheme(sj) name(rsr5_agegrp, replace) ///
>                 subtitle("`text`i''", size(*1.0)) ytitle("5-year RSR", size(*1.0)) xtitle("Year of diagnosis", size(*1.0)) ///
>                 ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.0) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.0))
```

{{< figure src="/svg/prediction-out-of-sample-surv1.svg" title="Temporal trends in 1-year all-cause survival." numbered="true" >}}

{{< figure src="/svg/prediction-out-of-sample-surv5.svg" title="Temporal trends in 5-year all-cause survival." numbered="true" >}}

This is not the only approach to model-based standardisation. A more efficient approach is to use weights ([see this tutorial](../model-based-standardisation)). I have demonstrated this approach (explicitly calculating the age-specific estimates and averaging them) as some users find it more transparent.

We could also have constructed the predictions data set (`predictions.dta`) to contain observations for each combination of year and age group (i.e., 5*49=245 observations), fitted a single model adjusted for age group, and predicted survival from that model. This would have simplied the code for the predictions (no need to loop over 5 separate models) but complicated the code for age-standardisation. 

## Confidence intervals

We can obtain confidence intervals the predictions of age-specific survival by adding the `ci` option to the predict statment. An example is shown below.

Confidence intervals for the age-standardised survival are not easy to obtain with the approach we have used here. We have calculated age-standardised survival as the weighted average of age-specific survivals. The standard error of the age-standardised survival will be a function of the standard errors of the age-specific survivals which are not readily available to us. 

Following is an example of obtaining and plotting confidence intervals the predictions of age-specific survival. We simply add the `ci` option to the predict statment.

```stata
. forvalues j = 1/5 {
  2. stpm2 yearspl? if agegrp==`j', scale(h) df(4) eform tvc(yearspl?) dftvc(1)
  3. preserve
  4. use predictions, clear
  5. predict stand1_`j', s timevar(t1) ci
  6. predict stand5_`j', s timevar(t5) ci
  7. save predictions, replace
  8. restore
  9. }
[output omitted]
```

I'll now graph the predicted survival curves along with 95% confidence intervals for 2 selected age groups.

```stata
twoway 	(rarea stand5_1_lci stand5_1_uci yydx, color(red%25)) ///
        (line stand5_1 yydx , sort lpattern(shortdash) lwidth(medthick) lcolor(black)) ///
		(rarea stand5_4_lci stand5_4_uci yydx, color(blue%25)) ///
		(line stand5_4 yydx , sort lpattern(longdash_dot) lwidth(medthick) lcolor(black)) ///
		, legend(label(1 "95% CI") label(2 "18-44") label(3 "95% CI") label(4 "65-74") ///  
		label(6 "Age stand") ring(0) pos(6) col(2)) scheme(sj) name(surv5_ci, replace) ysize(8) xsize(11) ///
		subtitle("`text`i''", size(*1.0)) ytitle("5-year survival proportion", size(*1.0)) xtitle("Year of diagnosis", size(*1.0)) ///
		ylabel(0 0.2 0.4 0.6 0.8 1.0, labsize(*1.0) angle(0)) yscale(range(0 1)) xlabel(, labsize(*1.0))
```

{{< figure src="/svg/prediction-out-of-sample-surv5-ci.svg" title="Temporal trends in 5-year all-cause survival for 2 selected age groups with 95% confidence intervals." numbered="true" >}}

 