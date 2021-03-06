+++
date = "2019-03-20"
title = "Standardised survival curves: sex differences in survival"
subtitle = "Paul Dickman, Cecilia Radkiewicz, Paul Lambert"
summary = "In this tutorial, we examine sex difference in survival for patients diagnosed with melanoma and illustrate how to estimate the causal effect of sex on patient survival using regression standardisation (also known and G-Computation). We discuss various approaches to estimating adjusted survival curves and illustrate the meansurv and stpm2_standsurv post-estimation commands to stpm2 (for fitting flexible parametric models in Stata)."
shortsummary = "" 
tags = ["Regression standardisation","meansurv","stpm2_standsurv","stpm2","Stata"]
math = true
[header]
image = ""
caption = ""
+++

{{% toc %}}

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/sex-differences.do).

{{% callout note %}}
Under construction: this page is a work in progress (April 2019). 
{{% /callout %}}

## Introduction

In this tutorial, we illustrate the use of standardised survival curves to compare the survival of males and females diagnosed with skin melanoma. Males have worse survival than females, but they also have less favourable distributions of stage and anatomical subsite (which explains some, but not all, of the difference). Estimating survival curves that are standardised to a common distribution of confounders makes it possible to compare survival curves between men and women. If our model is appropriate for confounder control then the difference between the standardised survival curves can be interpreted as the population causal effect. What we call standardised survival curves are sometimes called direct adjusted survival curves, marginal survival functions, or population-averaged survival functions. The process of obtaining standardised survival curves is called regression standardisation or G-computation ([references](#standardised-survival-curves-in-the-literature)).

Our data set contains 6,144 patients (2,921 male and 3,223 female). The first step in regression standardisation is to fit an appropriate model; we will fit a flexible parametric survival model. Based on the fitted model, we predict the survival function for each of the 6,144 patients under the assumption they are all male. We then average these 6,144 survival functions to get the standardised survival function for males. If we repeat the process under the assumption that all 6,144 patients are female then we get the standardised survival function for females. These two curves are comparable because they are both averaged over the exact same distribution of confounders (in this case the distribution among all 6,144 patients). There is a link to the counterfactual framework for causal inference. If 'being male' is considered the exposure then we are estimating (and contrasting) population average survival curves under two counterfactuals; once where everyone is exposed and once where everyone is unexposed. 

The standardised survival function ${S_s}(t|X=x)$ is given by 
	
$$
{S_s}(t|X=x) = \frac{1}{N}\sum\_{i=1}^{N}{S}(t|X=x,Z=z_i)
$$
	
where ${S}(t|X=x,Z=z_i)$ is the predicted survival function for individual $i$ when forced to take a specific value ($x$) of the exposure variable, $X$, but at the observed values of other variables, $Z$.

The process can be computationally intensive, because for each individual in our data we are predicting the survival function (i.e., survival as a function of time) and averaging these functions. Standardised survival curves can be obtained following a Cox regression model, but their are advantages to using a flexible parametric model; firstly because prediction is generally easier in a parametric framework and secondly because Paul Lambert has written the Stata commands (`predict, meansurv` and `stpm2_standsurv`) to obtain standardised survival curves after fitting a flexible parametric model. Paul Lambert has written a [tutorial](https://pclambert.net/software/stpm2/comparewithcox/) showing the similarities of the Cox model and flexible parametric model and discussing why we prefer the latter. We show [on a separate page](/software/stata/sex-differences-cox/) that estimated hazard ratios from the Cox and flexible parametric model are very similar for the data used in this tutorial (as is usally the case).

We will produce the following graph, which shows the cause-specific survival functions for men and women (not standardised) along with the survival curve we would expect to see for men if they had the same distribution of covariates (year of diagnosis, age, stage, subsite) as females. A conceptually identical graph can be found in the paper by [Andreassen and colleagues](https://www.ncbi.nlm.nih.gov/pubmed/29635144) on sex differences in bladder cancer survival. Here we are standardising to the confounder distribution for women (rather than the distribution in all patients); as such the red and the blue dashed lines are standardised to the same population and are therefore comparable.

{{< figure src="/svg/sexdiff4.svg" title="Cause-specific survival for males, females, and males if they had the same distribution of covariates as females. The dashed blue line can also be interpreted as the survival that would be observed for females if they had the cause-specific mortality of males." numbered="false" >}}

Our general aim is to estimate the magnitude of sex differences in patient survival and the extent to which observed differences can be explained my measured covariates (age, stage, subsite). We will do this by studying changes in the estimated hazard ratios and by contrasting standardised survival curves. We will also examine some other approaches for obtaining adjusted survival curves and describe why they are not recommended.

## Preparing the data

We begin by reading the data (excluding unknown (`stage==0`) stage), `stset` for cause-specific survival (death due to melanoma is the outcome) and creating dummy variables for use in modelling and prediction. `stpm2` supports Stata factor variable syntax (e.g., `i.stage`) for main effects but not for time-varying effects. We will use the `stpm2_standsurv` command for constructing standardised survival curves, which does not support factor variables for main effects or interactions. 

```stata
. use https://pauldickman.com/data/melanoma.dta if stage>0, clear
(Skin melanoma, diagnosed 1975-94, follow-up to 1995)

. stset surv_mm, fail(status==1) scale(12) exit(time 120)

. generate male=(sex==1)
. quietly tab agegrp, generate(agegrp)
. quietly tab stage, generate(stage)
. quietly tab subsite, generate(subsite)
```
We will model year of diagnosis using a restricted cubic spline, and create the basis vectors for doing so in the code below. We also create dummy variables to fit an interaction between sex and stage and a [temporary time variable](https://pclambert.net/software/stpm2/stpm2_timevar/) for use with predictions. 

```stata
. // spline variables for year of diagnosis
. rcsgen yydx, df(3) gen(yearspl) orthog
Variables yearspl1 to yearspl3 were created

. // terms for interaction between sex and stage
. generate stage2m=stage2*male
. generate stage3m=stage3*male

. // temporary time variable for predictions
. range temptime 0 10 101  
(6,043 missing values generated)
```

## Unadjusted survival curves by sex

We'll start by studying the difference in cause-specific survival between males and females without adjusting for covariates. We will estimate survival for males and females using both the Kaplan-Meier estimator and by predicting from a flexible parametric model. We could easily obtain the Kaplan-Meier estimates using `sts graph`, but to compare estimates on the same graph we will use `sts generate` to generate the Kaplan-Meier estimates and save them in the new variable `km`. We then generate the variable `fpm` containing the predicted survival from the flexible parametric survival model. When fitting the flexible parametric model, we have relaxed the proportional hazards assumptions (`tvc` option); if we don't do this then the estimates from the two methods will likely differ since the Kaplan-Meier estimator does not force hazards to be proportional. 

```stata
. sts gen km=s, by(sex)

. stpm2 i.male, scale(h) df(5) eform tvc(male) dftvc(2)

Log likelihood = -5294.5202                     Number of obs     =      6,144
------------------------------------------------------------------------------
             |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
        male |
          0  |          1  (base)
          1  |   1.683505   .0899312     9.75   0.000     1.516157    1.869325
             |
       _rcs1 |   2.233013   .0662663    27.07   0.000     2.106838    2.366744
       _rcs2 |   1.132325   .0260109     5.41   0.000     1.082475     1.18447
       _rcs3 |   1.077521   .0113923     7.06   0.000     1.055423    1.100083
       _rcs4 |   1.019101   .0069758     2.76   0.006      1.00552    1.032865
       _rcs5 |   1.002665   .0042579     0.63   0.531     .9943548    1.011046
  _rcs_male1 |   1.012582   .0398601     0.32   0.751     .9373955    1.093799
  _rcs_male2 |   1.058102   .0322312     1.85   0.064     .9967792    1.123198
       _cons |   .1594368   .0065308   -44.82   0.000      .147137    .1727648
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

. estimates store crude
. predict fpm, s

. twoway  (line km _t if male==0 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(red%50)) ///
>                 (line km _t if male==1 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(blue%50)) ///
>                 (line fpm _t if male==0 , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
>                 (line fpm _t if male==1 , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
>                 , scheme(sj) ysize(8) xsize(11) name("sexdiff1", replace) ///
>                 ytitle("Cause-specific survival") xtitle("Years since diagnosis") ///
>                 legend(label(1 "Female K-M") label(2 "Male K-M") label(3 "Female fpm") label(4 "Male fpm") ring(0) pos(7) col(1))

```

{{< figure src="/svg/sexdiff1.svg" title="Cause-specific survival (unadjusted) for males and females using both Kaplan-Meier and flexible parametric model" numbered="true" >}}                                       

We see that the estimates of cause-specific survival are similar for the two approaches. The estimated hazard ratio (1.68) for males/females in the table above does not have a simple interpretation. Our model allows the effect of sex to vary with follow-up time (the `tvc()` option) so the value of 1.68 is the effect of sex when all 3 spline variables are zero (which doesn't correspond to anything meaningful). However, an assumption of proportional hazards appears to be reasonable (based on analyses not shown here). The estimated hazard ratio from a proportional hazards model happens to be 1.68. In a [companion tutorial](/software/stata/sex-differences-cox/), we compare Cox models with flexible parametric models and assess the appropriateness of the proportional hazards assumption for sex.

## Association between sex and potential confounders

We'll now explore the association between sex and potential confounders (age at diagnosis, subsite, stage).    

```stata
. tab agegrp sex, col

  Age in 4 |          Sex
categories |      Male     Female |     Total
-----------+----------------------+----------
      0-44 |       739        896 |     1,635 
           |     25.30      27.80 |     26.61 
-----------+----------------------+----------
     45-59 |       966        847 |     1,813 
           |     33.07      26.28 |     29.51 
-----------+----------------------+----------
     60-74 |       875        936 |     1,811 
           |     29.96      29.04 |     29.48 
-----------+----------------------+----------
       75+ |       341        544 |       885 
           |     11.67      16.88 |     14.40 
-----------+----------------------+----------
     Total |     2,921      3,223 |     6,144 
           |    100.00     100.00 |    100.00 


. tab stage sex, col

  Clinical |
  stage at |          Sex
 diagnosis |      Male     Female |     Total
-----------+----------------------+----------
 Localised |     2,405      2,913 |     5,318 
           |     82.33      90.38 |     86.56 
-----------+----------------------+----------
  Regional |       227        123 |       350 
           |      7.77       3.82 |      5.70 
-----------+----------------------+----------
   Distant |       289        187 |       476 
           |      9.89       5.80 |      7.75 
-----------+----------------------+----------
     Total |     2,921      3,223 |     6,144 
           |    100.00     100.00 |    100.00 


. tab subsite sex, col            

      Anatomical |
      subsite of |          Sex
          tumour |      Male     Female |     Total
-----------------+----------------------+----------
   Head and Neck |       420        512 |       932 
                 |     14.38      15.89 |     15.17 
-----------------+----------------------+----------
           Trunk |     1,665        923 |     2,588 
                 |     57.00      28.64 |     42.12 
-----------------+----------------------+----------
           Limbs |       710      1,687 |     2,397 
                 |     24.31      52.34 |     39.01 
-----------------+----------------------+----------
Multiple and NOS |       126        101 |       227 
                 |      4.31       3.13 |      3.69 
-----------------+----------------------+----------
           Total |     2,921      3,223 |     6,144 
                 |    100.00     100.00 |    100.00 
```

We see that there men are slightly younger than women. Since survival is higher among the young, if we adjusted for age we would expect the HR to be larger than in the crude model. However, we also see that males have a worse stage distribution and are more likely to have melanoma diagnosed at subsites with worse prognosis (melanomas on the limbs have a better prognosis).

## Adjusted hazard ratios

We'll now fit some adjusted models, where calendar year of diagnosis is modelled as a restricted cubic spline. We've supressed the output from the models and just shown a table of estimates at the end. We have assumed proportional hazards for sex, in order to be able to interpret the estimated hazard ratios.

```stata
. // spline variables for year of diagnosis
. rcsgen yydx, df(3) gen(yearspl) orthog

. // estimate effect of sex adjusted for year of diagnosis and age                
. stpm2 yearspl* i.male i.agegrp, scale(h) df(5) eform ///
>       tvc(yearspl* agegrp2 agegrp3 agegrp4) dftvc(2)
[output omitted]
. estimates store adj1
 
. // estimate effect of sex adjusted additionally for stage and subsite
. stpm2 yearspl* i.male i.agegrp i.stage i.subsite, scale(h) df(5) eform ///
>       tvc(yearspl* agegrp2 agegrp3 agegrp4 stage2 stage3 subsite2 subsite3 subsite4) dftvc(2)
[output omitted]
. estimates store adj2

. // compare estimates from crude and adjusted models
. estimates table crude adj1 adj2, eform equations(1) b(%9.6f) modelwidth(12) ///
>    keep(i.male i.agegrp i.stage i.subsite)

-----------------------------------------------------------
    Variable |    crude           adj1           adj2      
-------------+---------------------------------------------
        male |
          0  |       (base)         (base)         (base)  
          1  |     1.681148       1.781544       1.350997  
             |
      agegrp |
       0-44  |                      (base)         (base)  
      45-59  |                    1.384893       1.276744  
      60-74  |                    1.865769       1.674252  
        75+  |                    2.930463       2.550103  
             |
       stage |
  Localised  |                                     (base)  
   Regional  |                                   5.312850  
    Distant  |                                  13.710885  
             |
     subsite |
Head and ..  |                                     (base)  
      Trunk  |                                   1.316520  
      Limbs  |                                   0.972087  
Multiple ..  |                                   1.213049  
-----------------------------------------------------------
```
We see that the estimated effect of sex becomes larger, compared to the crude model, when adjusting for age and year of diagnosis. This is expected, since males were younger than females. We see that some of the difference is explained by subsite and stage, but a difference remains. I omitted the output, but the 95% CI for the effect of sex from adjusted model 2 is (1.22, 1.50). That is, the difference is highly statistically significant.

## Standardized survival functions - intro

The idea behind standardised survival functions is that we wish to estimate average survival under two counterfactuals (hypothetical scenarios), one where all 6,144 individuals in our population are male and one where all 6,144 individuals are female. Conceptually, we start by predicting the survival function for each individual in the data set for the given values of explanatory variables other than sex, which is assumed to be 'male for everyone'. We then average the 6,144 survival functions to get the population-averaged (marginal) survival function for males. We then repeat the process, but under the assumption that everyone is female. The two average survival functions are standardised to the distribution of confounders in the population and therefore comparable. 

In the causal inference literature, this process is called regression standardisation or G-computation. Provided our model is sufficient for confounding control, the difference between the two marginal (or population-averaged) survival functions is an estimate of the average causal effect.

Rather than averaging over the entire population, we could average over just the females. That is, we estimate the factual average survival of the females and the counterfactual average survival if the females had the survival of males. Assuming an appropriate model, the difference between these two gives the "average causal effect among the exposed".  

[Arvid Sjölander (2016)](https://www.ncbi.nlm.nih.gov/pubmed/27179798) provides an overview of regression standardisation and its implementation in his R package, `stdreg`. We will use Paul Lambert's implementation in Stata. Paul Lambert first implemented this with the `meansurv` option to `predict` after fitting a flexible parametric model. Paul then developed the `stpm2_standsurv` command, which is a more powerful version of `predict, meansurv`. Paul has written a tutorial describing standardised survival using [stpm2_standsurv](https://pclambert.net/software/stpm2_standsurv/standardized_survival/).    

## Estimating the population average causal effect

We wish to estimate:

$$
E\left(S_s(t | X=1,Z)\right) - E\left(S_(t | X=0,Z)\right)
$$

where $X$ is the exposure of interest (being male) and $Z$ are the confounders (year, age, stage, subsite). We are interested in the expectation over the distribution of $Z$, with the key point being this distribution is forced to be the same for $X=0$ and $X=1$. If our model is sufficient for confounding control then the above formula gives the population average causal effect.

We then estimate

$$
\frac{1}{N}\sum\_{i=1}^{N}S(t|\mbox{male=1},\mbox{age}\_i,\mbox{year}\_i,\mbox{stage}\_i,\mbox{subsite}\_i) - \\\\ \frac{1}{N}\sum\_{i=1}^{N}S(t|\mbox{male=0},\mbox{age}\_i,\mbox{year}\_i,\mbox{stage}\_i,\mbox{subsite}\_i)
$$

where we are averaging the individual predicted survival curves for each of the $N = 6,144$ individuals, once where everyone is assumed to be male and once where everyone is assumed to be female.  

## Standardised survival functions - application

In order to estimate the average causal effect, our model must be sufficient for confounding control. A problem we face when studying hazard ratios is that we prefer to avoid interactions with the exposure in order to get a single estimate. In the table above, we compared hazard ratios for sex, but avoided models with time-varying effects of sex and interactions between sex and confounders in order not to complicate the model. That is, we fitted models that we knew may be over-simplistic. This is not an issue when calculating standardised survival curves. The model can be as complex as it need be; time-varying effects and interactions with the exposure do not cause any problems with the interpretation, although one does need to take care with the coding (which we discuss below).

We'll now fit a more complicated model, containing a time-varying effect of exposure (sex) and an interaction between sex and stage. This model is probably too simplistic for confounder control (additional interactions and time-varying effects are needed, and then there's the issue of unmeasured confounders). The syntax becomes slightly more complicated when we include interactions with the exposure, so we chose to illustrate the code with just one such interaction (sex and stage). The two dummy variables for the interaction between sex and stage were created in the first step ([preparing the data](#preparing-the-data)).

```stata
. stpm2 yearspl* male agegrp2 agegrp3 agegrp4 stage2 stage3 subsite2 ///
>       subsite3 subsite4 stage2m stage3m, scale(h) df(5) eform ///
>       tvc(male yearspl*) dftvc(2)
[output omitted]
```

In the first use of `predict` (below) we specify `at(male 0)`; this instructs Stata to predict a survival curve for each individual using the individual-specific covariates, except for `male` which is forced to be zero (i.e., force everyone to be female).

```stata
. // Marginal survival for males and females
. predict marginal0, meansurv at(male 0 stage2m 0 stage3m 0) timevar(temptime)
. predict marginal1, meansurv at(male 1 stage2m = stage2 stage3m = stage3) timevar(temptime)
```

In the next `predict` command, we repeat the process but force everyone to be male. We set the variable `male` to be 1 for all individuals, but specifying the interaction effects is more complex. Recall that we constructed the interaction terms as follows:

```stata
. generate stage2m=stage2*male
. generate stage3m=stage3*male
```

`stage2m` represents the additional effect of having a stage 2 cancer (compared to stage 1) for males. That is, the log hazard ratio for stage 2 (regional) versus stage 1 (localised) is the parameter estimate for `stage2` for females but for males it is the sum of `stage2 + stage2m`. To predict the marginal survival under the scenario where everyone is male, we want to set `stage2m` to be 1 for all individuals with a stage 2 cancer. That is, we set the interaction term `stage2m` to take the same value as `stage2`.

```stata
. twoway  (line marginal0 temptime , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
>     (line marginal1 temptime , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
>     , scheme(sj) ysize(8) xsize(11) name("sexdiff2", replace) ///
>     ytitle("Cause-specific survival") xtitle("Years since diagnosis") ///
>     legend(label(1 "Female (marginal)") label(2 "Male (marginal)") ring(0) pos(7) col(1))           
```
{{< figure src="/svg/sexdiff2.svg" title="Marginal (population-averaged) cause-specific survival for males and females. The curves are standardised to the distribution of confounders among the entire patient population and their difference can be interpreted as an estimate of the average causal effect." numbered="true" >}}    

## Using factor variable syntax

As an aside, the following code will give the same estimates of marginal survival. We fit the same model, but use Stata's factor variable syntax.

```stata
. stpm2 yearspl* i.male##i.stage i.agegrp i.subsite, scale(h) df(5) eform ///
>       tvc(male yearspl*) dftvc(2)

[output omitted]

. // Marginal survival for males and females
. predict marginal0, meansurv at(male 0) timevar(temptime)
. predict marginal1, meansurv at(male 1) timevar(temptime)
```
Despite modelling sex as both a factor variable (interacting with `i.stage`) and sex as a dummy variable (in the time-varying effects), the `predict` command gets it right. However, we can't use factor variable syntax for time-varying effects and cannot use it with `stpm2_standsurv` (which we will use later).

## Conditional (on covariates) survival

We'll now estimate the conditional (on sex) survival curves for males and females and compare them to the Kaplan-Meier curves. The curves would overlay if we fit a saturated model. A saturated model (which would include a five-way interaction and its time-varying effect) is too complex, but we see reasonable agreement between the model-based and non-parametric (Kaplan-Meier) estimates (Figure 3). 

To estimate conditional (on sex) survival we use the `if` qualify to restrict the observations over which the average is taken. We previously used predict without an if qualifier. That is, we previously used

```stata
predict marginal0, meansurv at(male 0) timevar(temptime)
``` 

The standardised survival curve from the above code is the average of the predicted survival curves for all 6,144 individuals (where sex is forced to be female). We now use.

```stata
predict meansurv00 if male==0, meansurv timevar(temptime)
``` 
The resulting survival curve is the average of the predicted individual survival curves for just the 3,223 females in the data set at the values of their covariates. We did not have to use the `at()` option to force them to be female, since we restricted to those observations that were female. We then estimate conditional survival for males by restricting to males (`if male==1`).

Hopefully it's obvious that the two curves we are estimating below (`meansurv00` and `meansurv11`) are not comparable since they are averaged over two groups of individuals (males and females) with different distributions of confounders.   

```stata
. predict meansurv00 if male==0, meansurv timevar(temptime)
. predict meansurv11 if male==1, meansurv timevar(temptime)

. twoway  (line km _t if male==0 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(red%50)) ///
>                 (line km _t if male==1 , sort connect(stairstep) lpattern(dash) lwidth(medthick) lcolor(blue%50)) ///
>                 (line meansurv0 temptime , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
>                 (line meansurv1 temptime , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
>                 , scheme(sj) ysize(8) xsize(11) name("sexdiff3", replace) ///
>                 ytitle("Cause-specific survival") xtitle("Years since diagnosis") ///
>                 legend(label(1 "Female K-M") label(2 "Male K-M") label(3 "Female fpm") label(4 "Male fpm") ring(0) pos(7) col(1))
```

{{< figure src="/svg/sexdiff3.svg" title="Conditional (on sex) cause-specific survival for males and females." numbered="true" >}}    

We now estimate the survival we would observe for males if they had same distribution of confounders (age, year, subsite, stage) as females. We use the if qualifier (`if male==0`) to restrict to females since we want to average over the confounder distribution of females. We then use `at(male 1 stage2m = stage2 stage3m = stage3)` to predict the average survival for males with these covariates.

```stata
. predict meansurv01 if male==0, meansurv at(male 1 stage2m = stage2 stage3m = stage3) timevar(temptime)

. twoway  (line meansurv00 temptime , sort lpattern(solid) lwidth(medthick) lcolor(red)) ///
>                 (line meansurv11 temptime , sort lpattern(solid) lwidth(medthick) lcolor(blue)) ///
>                 (line meansurv01 temptime , sort lpattern(dash) lwidth(medthick) lcolor(blue)) ///
>                 , scheme(sj) ysize(8) xsize(11) name("sexdiff4", replace) ///
>                 ytitle("Cause-specific survival") xtitle("Years since diagnosis") ///
>                 legend(label(1 "Female") label(2 "Male") label(3 "Male (adjusted)") ring(0) pos(7) col(1))              
```

{{< figure src="/svg/sexdiff4.svg" title="Cause-specific survival for males, females, and males if they had the same covariates as females." numbered="true" >}}    

Assuming an appropriate model, the difference between the red line and the dotted blue line is the "average causal effect among the exposed". We can calculate this difference, but be prepared to wait several minutes when using the `ci` option (to get confidence intervals).

```stata
. predictnl diff = predict(meansurv timevar(temptime)) - ///
>                  predict(meansurv at(male 1) timevar(temptime)) ///
>                  if male==0, ci(diff_l diff_u)
(6,076 missing values generated)
note: confidence intervals calculated using Z critical values
```
{{< figure src="/svg/sexdiff4a.svg" title="Estimated average causal effect among females (the difference between the red line and the dotted blue line in figure 4)." numbered="false" >}}    

## Proportion of the sex difference explained by confounders

We can easily calculate the proportion of the sex difference explained by confounders. 

```stata
. generate explained=(meansurv01-meansurv11)/(meansurv00-meansurv11) if temptime!=.

. list temptime meansurv00 meansurv01 meansurv11 explained if inlist(temptime,1,5,10)       

  +------------------------------------------------------+
  | temptime   means~00   means~01   means~11   explai~d |
  |------------------------------------------------------|
  |        1      0.950      0.936      0.917      0.569 |
  |        5      0.804      0.740      0.688      0.449 |
  |       10      0.745      0.676      0.620      0.444 |
  +------------------------------------------------------+
```
## Standardised survival curves using stpm2_standsurv

Whereas the `predict` command can obtain a range of quantities after fitting a flexible parametric model, the `stpm2_standsurv` command is designed to obtain standardised survival curves and contrasts between them (e.g., differences and ratios). Both commands were written by [Paul Lambert](https://pclambert.net/).

`stpm2_standsurv` is similar to the `meansurv` option of stpm2's `predict` command, but allows multiple `at` options and contrasts (differences or ratios of standardised survival curves). It is substantially faster than performing contrasts using `predictnl` with `meansurv` as partial derivatives are calculated analytically.

Here we estimate the standardised survival curves for males and females and their difference (with 95% confidence intervals). By default, the difference is calculated for at2-at1 (males - females).

```stata
. stpm2_standsurv, at1(male 0 stage2m 0 stage3m 0) ///
>                  at2(male 1 stage2m = stage2 stage3m = stage3) timevar(temptime) ci contrast(difference)

. list _at1 _at2 marginal0 marginal1 in 1/5
     +-----------------------------------------------+
     |      _at1        _at2   marginal0   marginal1 |
     |-----------------------------------------------|
  1. |         1           1           1           1 |
  2. |  .9952646   .99581718    .9952646   .99581718 |
  3. | .99016878   .99008362   .99016878   .99008362 |
  4. | .98472692    .9834952   .98472692    .9834952 |
  5. | .97900767   .97629853   .97900767   .97629853 |
     +-----------------------------------------------+
```

The estimates are the same as those we calculated using `predict, meansurv`.

```stata
. twoway  (rarea _contrast2_1_lci _contrast2_1_uci temptime, color(red%25)) ///
>            (line _contrast2_1 temptime, sort lcolor(red)) ///
>            , legend(off) ysize(8) xsize(11) ///
>            ylabel(,angle(h) format(%3.2f)) ///
>            ytitle("Difference in S(t)") name("sexdiff_contrast", replace) ///
>            xtitle("Years since diagnosis")
```

{{< figure src="/svg/sexdiff_contrast.svg" title="Estimated average causal effect (the difference between the two lines in figure 2)." numbered="true" >}}    

## Standardised survival curves in the literature

What we call standardised survival functions are sometimes called direct adjusted survival functions, marginal survival functions, or population-averaged survival functions. The procedure for obtaining directly standardised survival curves is called regression standardisation or G-computation ([Vansteelandt and Keiding (2010))](https://doi.org/10.1093/aje/kwq474).

In an influential commentary entitled [the hazards of hazard ratios](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3653612/), Miguel Hernán described issues with the interpretataion of hazard ratios and promoted the use of what he called "survival curves
adjusted for baseline confounders". The algorithm he provided is exactly the one used to obtain what we call "standardised survival curves". Professor Hernán is not the only influential epidemiologist, nor the first, to advocate for the use of standardised survival curves. Rothman, Greenland and Lash suggest the use of regression standardisation to estimate marginal measures of association "Modern Epidemiology" (3rd edition, pages 386-388, 442-445). 

Standardised survival curves were being used in the 1980s ([Chang et al (1982)](https://www.ncbi.nlm.nih.gov/pubmed/7096530),[Makuch (1982)](https://www.ncbi.nlm.nih.gov/pubmed/7042727), [Gail and Byar (1986)](https://onlinelibrary.wiley.com/doi/abs/10.1002/bimj.4710280508)).

[Martinussen et al](https://arxiv.org/pdf/1810.09192.pdf) and [Aalen et al](https://core.ac.uk/download/pdf/144149054.pdf) have followed up Hernan's article, although their focus has been on the interpetation of hazard ratios rather than standardised survival curves.

## Comparison with the Stata -margins- and -stteffects- commands

To be completed.

## Take care adjusting survival curves using sts graph

One can use `sts graph` with the `adjustfor()` option to get 'adjusted' Kaplan-Meier curves. The resulting curves may not, however, necessarily be what you want. For example:

```stata
. sts graph, by(sex) adjustfor(age) name("sexdiff5", replace)
```

{{< figure src="/svg/sexdiff5.svg" title="Adjusted survival curves using sts graph. These are the predicted survival curves at age zero from two Cox models fitted separately for males and females." numbered="true" >}}  

What Stata does is fit separate Cox models for the by variables (`sex` in this example) with the `adjustfor()` variables (`age` in this example) as covariates. It then graphs the predicted baseline survival function (i.e., the predicted survival function for patients aged zero).

If we adjust for both age and year of diagnosis (see below) it's even worse. Or maybe it's better because we will hopefully recognise that something is not quite right.  

```stata
sts graph, by(sex) adjustfor(age yydx) name("sexdiff6", replace)
```

{{< figure src="/svg/sexdiff6.svg" title="Adjusted survival curves using sts graph. These are the predicted survival curves at age zero and year of diagnosis zero from two Cox models fitted separately for males and females." numbered="true" >}}  

Since survival is improving within the range of our data (1975-1994), when we extrapolate back to the year 0 the predicted survival is very poor. One solution is to center the variables. 

```stata
. generate age70=age-70
. generate yydx1980=yydx-1980

. sts graph, by(sex) adjustfor(age70 yydx1980) name("sexdiff7", replace)
```

{{< figure src="/svg/sexdiff7.svg" title="Adjusted survival curves using sts graph. These are the predicted survival curves at age 70 and year of diagnosis 1980 from two Cox models fitted separately for males and females." numbered="true" >}}  

These curves are comparable, but findings are not generalisable since we are comparing the survival curves for just one particular covariate pattern. 

If we use `strata(sex)` rather than `by(sex)` then Stata fits a single stratified Cox model (separate baselines for males and females) rather than two separate Cox models. This is more restrictive than the previous example since we are assuming the effects of age and year are the same for males and females. 

## Predicted survival curves using stcurve

The `stcurve` command can be used to plot predicted survival curves after fitting a survival model (e.g., a Cox model).

```stata
. stcox yearspl* male agegrp2 agegrp3 agegrp4 stage2 stage3
. stcurve, survival at1(male=0) at2(male=1)
```

This will plot the predicted survival functions for males and females at the *average* values of the other covariates. The curves are, in some sense comparable, but only for one specific set of confounders and it's not clear what, for example, the average value of stage represents.  

## Standardised survival curves in R and SAS

- [A SAS macro for estimation of direct adjusted survival curves based on a stratified Cox regression model](https://www.ncbi.nlm.nih.gov/pubmed/17850917)

- [Regression standardization with the R package stdReg](https://www.ncbi.nlm.nih.gov/pubmed/27179798)