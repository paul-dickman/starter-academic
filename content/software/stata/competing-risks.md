+++
date = "2019-04-04"
title = "Competing risks: Estimating crude probabilities of death"
summary = "An illustration of how to estimate cumulative incidence functions (CIFs) based on a fitted flexible parametric model"
shortsummary = "" 
tags = ["competing risks","stpm2","stpm2cif","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/competing-risks.do).

{{% alert note %}}
This page shows the Stata code with only limited comments (April 2019). 
{{% /alert %}}

## Introduction

This page illustrates how to estimate crude probabilities of death based on a fitted flexible parametric model. We will estimate both the crude probability of death due to cancer and the crude probability of death due to other causes. 

The crude probability of death due to cancer is the probability of death in the presence of competing risks (death due to other causes). It differs from the net probability of death due to cancer, which is the probability of death due to cancer in the hypothetical scenario where deaths due to competing risks have been elimitated. 

In the competing risks literature, the crude probability of death is also known as the cause-specific cumulative incidence function (CIF). In the analysis of population-based cancer registry data, it is known as the crude probability of death.  

## Setting up the data

We begin by reading the data and examining 3 observations. The variable status is coded as 0 for patients alive at the end of follow-up, 1 for patients who died due to colon cancer (hereafter called 'cancer'), and 2 for patients who died due to other causes. 

```stata
. use colon if stage!=0, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)
  
. gen female = (sex==2)

. list id status if inlist(id, 1, 2, 22), noobs

  +-------------------+
  | id         status |
  |-------------------|
  |  1   Dead: cancer |
  |  2    Dead: other |
  | 22          Alive |
  +-------------------+
```

To conduct a competing risks analysis with two outcomes we expand the data set so that each patient has two
rows of data - one for each cause of death. We create the variable `cause` to index the two observations for each patient and then create event indicators specific to each outcome.  

```stata
. expand 2
(13,208 observations created)

. // Recode and set up data for competing risk analysis
. bysort id: gen cause=_n  // cause =1 for cause 1, cause =2 for cause 2
. gen cancer=(cause==1)    // indicator for observation for cancer
. gen other=(cause==2)     // indicator for observation for other

. // Event indicator
. gen event=(cause==status)  // status=1 death due to cancer, =2 death due to other

. stset surv_mm, failure(event) scale(12) exit(time 120.5)
[output omitted]

. // Categorize age and create interactions with cause
. forvalues i = 0/3 {
  2.         gen age`i'can=(agegrp==`i' & cancer==1) 
  3.         gen age`i'oth=(agegrp==`i' & other==1) 
  4. }

. // Allow different effect of sex for cancer and other */
. gen fem_can = female*cancer

. gen fem_other = female*other

```
Each patient will have a row for cause 1 (cancer) and a row for cause 2 (other). Note that the variable `cancer` is an indicator for the cancer observation, not an indicator for death due to cancer. That is, the first observation for each id will have `cause=1` and `cancer=1`.

Similarly, `other` is an indicator for the 'other causes' observation (not death due to other causes). The variable `event` indicates if the patient has died of the cause specific to that row. For patient id 1, for example, `event` is 1 for the first row (because this patient died of cancer) but is 0 for the second row (this patient did not die of other causes). For patient id 22, the event indicator is 0 for both rows because this patient did not die of either cause.  

```stata
. list id status surv_mm cause cancer other event if inlist(id, 1, 2, 22), sepby(id)

 +--------------------------------------------------------------+
 | id         status   surv_mm   cause   cancer   other   event |
 |--------------------------------------------------------------|
 |  1   Dead: cancer      16.5       1        1       0       1 |
 |  1   Dead: cancer      16.5       2        0       1       0 |
 |--------------------------------------------------------------|
 |  2    Dead: other      82.5       1        1       0       0 |
 |  2    Dead: other      82.5       2        0       1       1 |
 |--------------------------------------------------------------|
 | 22          Alive     207.5       1        1       0       0 |
 | 22          Alive     207.5       2        0       1       0 |
 +--------------------------------------------------------------+
```

Our aim is to fit a flexible parametric model where we model mortality due to both causes simultaneously. However, the distribution of event times differs between the two causes so we would like to use different knot locations for the two causes. We will therefore begin by fitting separate models for the two causes and saving the knot locations to macro variables. 

```stata
. stpm2 fem_can age1can age2can age3can if cancer == 1, ///
>         df(4) scale(hazard) dftvc(3) tvc(fem_can age1can age2can age3can) eform nolog   
[output omitted]

. global knots_cancer `e(bhknots)'
. global knots_cancer_tvc `e(tvcknots_age1can)'

. // Fit a separate model for other and store the knot locations
. stpm2 fem_oth age1oth age2oth age3oth if other == 1, ///
>         df(4) scale(hazard) eform nolog   
[output omitted]

. global knots_other `e(bhknots)'
```

We now fit a single model using the saved knot locations and predict the cumulative probabilities of death (which we have labelled cif, cumulative incidence function). For illustration, I have just estimated the cumulative probabilities of death for males and for the youngest and oldest age groups. 

```stata
. stpm2 cancer other fem_can fem_oth age1can age2can age3can age1oth age2oth age3oth ///
>         , scale(hazard) rcsbaseoff nocons ///
>         tvc(cancer other fem_can age1can age2can age3can) eform nolog ///
>         knotstvc(cancer $knots_cancer other $knots_other ///
>         fem_can $knots_cancer_tvc ///
>         age1can $knots_cancer_tvc ///
>         age2can $knots_cancer_tvc ///
>         age3can $knots_cancer_tvc)

. // Estimate the cumulative incidence functions
. stpm2cif cancermale_age0 othermale_age0, cause1(cancer 1) cause2(other 1) 
. stpm2cif cancermale_age3 othermale_age3, cause1(cancer 1 age3can 1) cause2(other 1 age3oth 1)  
```

We now plot the cumulative probabilities of death. I have chosen to show them in both stacked and non-stacked format; code is available [here](http://pauldickman.com/software/stata/competing-risks.do).

{{< figure src="/svg/competing-non-stacked.svg" title="Crude probabilities of death due to cancer and other causes." numbered="true" >}}

{{< figure src="/svg/competing-stacked.svg" title="Crude probabilities of death due to cancer and other causes (stacked). The white part of the curve represents the probability of being alive." numbered="true" >}}
	