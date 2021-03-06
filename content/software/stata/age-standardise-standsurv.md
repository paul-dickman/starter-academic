+++
date = "2021-02-10"
title = "Age-standardised survival using standsurv"
subtitle = "Paul Dickman, Paul Lambert"
summary = "After fitting a flexible parametric model, we estimate internally age-standardised 5-year survival for males and females for each year of diagnosis."
tags = ["stpm2","interaction","standsurv","age-standardisation","Stata"]
math = false
[header]
image = ""
caption = ""
+++

{{% toc %}}

## Download Stata code (do files)

There are two separate do files associated with this tutorial.

- [Age-standardisation with standsurv using an internal standard](http://pauldickman.com/software/stata/age-standardise-standsurv.do)
- [Age-standardisation with standsurv using an external standard (ICSS)](http://pauldickman.com/software/stata/age-standardise-standsurv-icss.do)

We start by describing the procedure for using `standsurv` to estimate age-standardised survival using an internal standard and then show how to use an external standard.

The do files provide fully worked examples. They include code to download the patient data (melanoma) and reproduce the results shown on this page.

{{% callout note %}}
This code uses the user-written `standsurv` command, which at the time of writing is only available from [Paul Lambert's website](https://pclambert.net/software/standsurv/).  
{{% /callout %}}

## Introduction and aims

In a [previous tutorial](/software/stata/hazard_ratio_with_effect_modification/), we estimated the hazard ratio for a binary exposure (sex) as a function of year of diagnosis. We produced the following plot.

{{< figure src="/svg/hazard_ratio_with_effect_modification.svg" title="Hazard ratio for sex (males/females) predicted from a flexible parametric model with an interaction between sex and year of diagnosis (modelled as a restricted cubic spline). The hazard ratio is assumed to be constant over follow-up time (i.e., proportional hazards). Patients diagnosed with melanoma 1975-1994 in an unspecified country with a 10 year follow-up." numbered="false" >}}

We are now going to estimate the age-standardised 5-year survival for each sex as a function of year of diagnosis and the difference in age-standardised 5-year survival between men and women. The [linked code](http://pauldickman.com/software/stata/age-standardise-standsurv.do) will produce these two graphs.

{{< figure src="/svg/age-standardise-standsurv.svg" title="Age-standardised 5-year cause-specific survival for men and women. Standard population is the age-distribution among all patients for all years. Patients diagnosed with melanoma 1975-1994 in an unspecified country with a 10 year follow-up." numbered="false" >}}

{{< figure src="/svg/age-standardise-standsurv-diff.svg" title="Difference in age-standardised 5-year cause-specific survival between men and women (women minus men). Standard population is the age-distribution among all patients for all years. Patients diagnosed with melanoma 1975-1994 in an unspecified country with a 10 year follow-up." numbered="false" >}}

We have modelled cause-specific survival, but the same approach works if we are interested in relative survival (just include the `bhazard()` option when modelling and stset with all deaths as the outcome).

The data set-up is the same as in the [previous tutorial](/software/stata/hazard_ratio_with_effect_modification/). We `stset` with time since diagnosis as the timescale and censor at 10 years (120 months). We will model year of diagnosis as a restricted cubic spline with 3 degrees of freedom. We use the `rcsgen` command to create the 3 spline basis variables and then create the interaction between sex and year of diagnosis.

## Fitting the flexible parametric model (stpm2) 

We now fit the following model.

```stata
. stpm2 yearspl* male maleyr1 maleyr2 maleyr3 agegrp2 agegrp3 agegrp4, scale(h) df(5) eform ///
>       tvc(agegrp2 agegrp3 agegrp4) dftvc(2)

[output omitted]
```
Note that sex and year of diagnosis do not appear in the `tvc()` option so are assumed to be constant over time since diagnosis.

Our model contains interaction effects between sex and year of diagnosis (without these the hazard ratio and the standardised survival would be constant over year of diagnosis). The interaction effects were constructed as follows. `male` is an indicator variable for male sex and `yearspl1`, `yearspl2`, and `yearspl3`, are the spline basis vectors for year of diagnosis.

```stata
generate maleyr1=male*yearspl1
generate maleyr2=male*yearspl2
generate maleyr3=male*yearspl3
```

In the next step we will use the fact that each of these interaction effects are zero for women and equal to the corresponding spline basis vector for men.

## Age-standardisation with standsurv using an internal standard

The `standsurv` command (written by Paul Lambert and Michael Crowther) estimates standardized survival curves and related measures based on a fitted model. It also allows various contrasts (e.g., differences) between the standardized functions. Details can be found in these pages on Paul Lambert's website:

- [standsurv backround and installation instructions](https://pclambert.net/software/standsurv/)
- [Detailed overview of standardized survival functions](https://pclambert.net/software/standsurv/standardized_survival/)
- [Standardized relative survival](https://pclambert.net/software/standsurv/standardized_relative_survival/)

We will use `standsurv` to estimate the age-standardised 5-year survival for males and for females along with the difference between them. 

If we had fitted a simpler model (without interactions) then we could make the following call to `standsurv`.

```stata
generate t5=5
standsurv, at1(male 0) at2(male 1) timevar(t5) ci contrast(difference)
```
We begin by creating a value of time at which we wish to predict. Usually we predict for a range of values of time so as to get a standardised survival function, but here we will only predict the 5-year survival.

Each of the `atn()` options creates a standardised 5-year survival; one for females (the variable `male` is set to 0) and one for males (the variable `male` is set to 1). 

The standardised 5-year survival for females is created by predicting (based on the fitted model) the 5-year survival for every observation in the data set under the assumption they are female (even if they are actually male). We then average the individual predictions to get the standardised survival for females. We then repeat the process, but assuming everyone is male. 

The key is that we predict two values of the 5-year survival for each individual, once if they were male and once if they were female. When we average these values to get the standardised estimates, the average for males and the average for females are both taken over the exact same observations (with the same distribution of age and year) so are therefore comparable. With this simple example we are standardising over both age and year of diagnosis. 

For our actual research question, we want to estimate the age-standardised 5-year survival for men and women for each year of diagnosis. Each of these estimates will be averaged over the age distribution of all patients; this is known as internal age standardisation (we are using the age distribution of the entire cohort as the standard).

The code is as follows:

```stata
generate t5=5 in 1
forvalues y = 1975/1994 {
  display "Calculating age-standardised survival for year: `y' "
  rcsgen, scalar(`y') knots(${yearknots}) rmatrix(R) gen(c) 
  standsurv , at1(male 0 maleyr1 0 maleyr2 0 maleyr3 0 yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              at2(male 1 maleyr1 `=c1' maleyr2 `=c2' maleyr3 `=c3' yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              timevar(t5) contrast(difference) ci ///
              atvar(S_male`y' S_female`y') contrastvars(S_diff`y')
}
```
We loop over each value of year of diagnosis (from 1975 to 1994).

Specifying the appropriate covariate values is more complicated because our model is more complicated. For females we have `male=0` as well as all of the sex by year interactions set to zero. Because we want to predict for females at a specific value of year of diagnosis we need to specify the appropriate values of the spline basis vectors for each year. We use the `rcsgen`command to recreate the spline basis vectors (using the same knot locations and projection matrix as previously used) and then save the resulting spline basis vectors to local macros `c1`, `c2`, and `c3` that can be fed into standsurv.  For males, the sex by year interactions will be equal to the values of the respective spline basis vectors.
  
This code will create a series of valiable with the standardised estimates for each year. For example, for 1975 we will have the following valiables.
  
```stata
. describe *1975*

              storage   display 
variable name   type    format  
--------------------------------
S_male1975      double  %10.0g                
S_male1975_lci  double  %10.0g                
S_male1975_uci  double  %10.0g                
S_female1975    double  %10.0g                
S_female~75_lci double  %10.0g                
S_female~75_uci double  %10.0g                
S_diff1975      double  %10.0g                
S_diff1975_lci  double  %10.0g                
S_diff1975_uci  double  %10.0g     
```

Similar variables are created for each of the other years. To make plotting easier we will convert from wide to long format.

```stata
keep in 1
keep id S_male* S_female* S_diff*
reshape long S_male S_male@_lci S_male@_uci ///
             S_female S_female@_lci S_female@_uci ///
			 S_diff S_diff@_lci S_diff@_uci, i(id) j(yydx) 
```

We can now easily plot, for example, the age-standardised 5-year cause-specific survival for men and women.

```stata
twoway (rarea S_male_lci S_male_uci yydx, sort color(blue%25)) ///
       (line S_male yydx, sort lcolor(blue) lpattern(dash_dot)) /// 
	   (rarea S_female_lci S_female_uci yydx, sort color(red%25)) ///
       (line S_female yydx, sort lcolor(red) lpattern(solid)) /// 
                 , ysize(8) xsize(11) ///
				 title("Age-standardised 5-year cause-specific survival") ///
 				 subtitle("Standardised to the age-distribution among all patients for all years") ///
                 ylabel(,angle(h) format(%3.2f)) ///
                 ytitle("5-year survival (age-standardised)") name("agestand", replace) ///
                 xtitle("Year of diagnosis") ///
				 legend(label(2 "men") label(4 "women") order(2 4) ring(0) position(6) col(1))		
```

{{< figure src="/svg/age-standardise-standsurv.svg" title="Age-standardised 5-year cause-specific survival for men and women. Standard population is the age-distribution among all patients for all years. Patients diagnosed with melanoma 1975-1994 in an unspecified country with a 10 year follow-up." numbered="false" >}}
	
## Age-standardisation with standsurv using an external standard (ICSS)

The code for external (ICSS) age standardisation is available [here](http://pauldickman.com/software/stata/age-standardise-standsurv-icss.do).

We have age-standardised using a so-called internal standard. That is, we used the age distribution of the patients (over all years) as the standard population. The age-standardised survival for each year of diagnosis is interpreted as the survival we would have observed if the age distribution of patients was the same at each year of diagnosis.

We will now age-standardise using an external standard population, namely the International Cancer Survival Standard (ICSS) ([Corazziari et al 2004](https://doi.org/10.1016/j.ejca.2004.07.002)). ICSS consists of three standard populations, we will use number 2 which is intended cancer sites with broadly constant incidence by age. See [this page](https://seer.cancer.gov/stdpopulations/survival.html) for an overview.

In tranditional age-standardisation we calculate survival within each age groups and then take a weighted average of the age-specific estimates. An advantage of the standsurv approach is that we apply weights at an individual level, which precludes the need to explicitly estimate survival within each age group. 

We first need to recreate our age groups in a manner consistent with ICSS.

```stata
. drop agegrp
. label drop agegrp
. drop if age < 15
(12 observations deleted)
. egen agegrp=cut(age), at(0 15 45 55 65 75 200) icodes
```

The following table shows the age distribution in the patient cohort for year of diagnosis 1975. The output has been modified to also show the percentage in the ICSS population and the ICSS weights (calculated as percent in ICSS divided by percent in patient cohort).

```stata
. tab agegrp if yydx==1975

 agegrp |  Freq.   Percent    ICSS %  weight 
--------+----------------------------------- 
  15-44 |     67     33.67     28      0.831    
  45-54 |     36     18.09     17      0.940    
  55-64 |     33     16.58     21      1.266    
  65-74 |     46     23.12     20      0.865    
    75+ |     17      8.54     14      1.639    
--------+----------------------------------- 
  Total |    199    100.00    100      
```

We can see that proportion of patient in each age group is roughly similar to the proportion in the ICSS population. 

We will now create an individual weight for each observation, calculated as the proportion of patients in the given age group in the standard population (ICSS) divided by the proportion in that age group in our patient data. The idea is to upweight (assign a weight greater than 1) those age groups that are underrepresented in our patient cohort (relative to the standard) and downweight (assign a weight less than 1) those that are overrepresented.

In our data set, 23.12% of patients are in the youngest age group compared to 28% in the standard population. As such, each patients in the youngest age group in our population will be given a weight of `28/23.12=0.831`. At the other end of the age scale, 8.54% of the patients are in the oldest age group compared to 14% in the standard population. As such, each patient in the oldest age group in our population will be given a weight of `14/8.54=1.639`. That is, for 1975 there are fewer patients in the highest age group than in the standard population so we upweight the patients in our cohort.

The age distribution differs by year of diagnosis. We see from the table below that the patients diagnosed in 1994 are, on average, older than those diagnosed 1975.

```stata
. tab agegrp if yydx==1994

 agegrp | Freq.   Percent   ICSS %  weight 
--------+--------------------------------- 
  15-44 |    70     19.23    28      1.456    
  45-54 |    77     21.15    17      0.804    
  55-64 |    79     21.70    21      0.968    
  65-74 |    70     19.23    20      1.040    
    75+ |    68     18.68    14      0.749    
--------+--------------------------------- 
  Total |   364    100.00   100      
```

We now calculate the individual weights and apply them when using `standsurv`. Note that we do not use the weights when fitting the model, only in `standsurv`. The only change to the call to `standsurv` compared to the code for internal standardisation is the addition of the `indweights(w)` option.

```stata
generate t5=5 in 1
forvalues y = 1975/1994 {
  display "Calculating age-standardised survival for year: `y' "
 
  // Create weights to use for external age-standardisation
  // Separate weights are required for each year (since age distribution varies by year)
  // total obs for each year
  count if yydx==`y'
  local total: display %3.0f r(N)
  
  // count of number of patients in each agegroup for each year
  by agegrp: egen n_age`y'=sum(yydx==`y')

  // generate weights
  gen w`y' = ICSSwt/(n_age`y'/`total') 
  // write the spline basis vectors to local macro variables
  rcsgen, scalar(`y') knots(${yearknots}) rmatrix(R) gen(c) 
  
  // estimate age-standardised survival for men and women (with difference)
  standsurv , at1(male 0 maleyr1 0 maleyr2 0 maleyr3 0 yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              at2(male 1 maleyr1 `=c1' maleyr2 `=c2' maleyr3 `=c3' yearspl1 `=c1' yearspl2 `=c2' yearspl3 `=c3') ///
              timevar(t5) contrast(difference) ci indweights(w`y') ///
              atvar(S_male`y' S_female`y') contrastvars(S_diff`y')
}
```

## Comparison of approaches to external age standardisation

{{% callout note %}}
This is work in progres and the files are here primarily so I can easily find them. 
{{% /callout %}}
	
On [another page](http://pauldickman.com/software/stata/prediction-out-of-sample/) I illustrate an approach to external age-standardisation based on fitting separate models for each age strata. These files apply the two approaches to the same data (that used above).

1. [fitting models for each age strata](http://pauldickman.com/software/stata/approach1-stratified_models.do)
2. [using standsurv as above](http://pauldickman.com/software/stata/approach2-standsurv.do)

The results are not exactly the same because the approaches use different models. Model 2 would need interactions between age and all main effects (sex, year, sex*year) to be comparable to model 1 (which fits separate models for each age group). 




	