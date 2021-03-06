+++
date = "2019-07-05"
title = "Illustration of the Brenner approach to age-standardised net survival (Pohar Perme estimator)"
tags = ["strs","software","Stata","age-standardisation"]
math = true
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/strs/age_standardised_net_survival.do).

This code illustrates how to apply the ["Brenner alternative approach"](https://www.ncbi.nlm.nih.gov/pubmed/15454258) to age-standardise net survival using external (ICSS) weights. We estimate using three approaches.  

1. Unstandardised
2. Traditional direct standardisation (ICSS weights)
3. Direct standardisation using the "Brenner approach" (ICSS weights)

With the traditional approach to direct standardisation we take the weighted average of the age-specific estimates. That is, we first obtain an estimate for each of the 5 age groups and then combine the estimates. With the Brenner approach, we apply individual weights and estimate a single life table. This is useful if, for example, we have sparse data and cannot estimate net survival in each age stratum. 

The Brenner weights are calculated as the ratio of the proportion of patients in each age group in the standard population to the proportion of patients in that age group in the patient population. 

|agegr |    n  |    % | ICSS wt | Brenner wt |
| -----| ------| -----| --------| -----------|
|15-44 |   735 | 0.05 | 0.07    |  1.4       |
|45-54 | 1,243 | 0.08 | 0.12    |  1.5       |
|55-64 | 2,767 | 0.18 | 0.23    |  1.28      |
|65-74 | 4,951 | 0.32 | 0.29    |  0.91      |
|75+   | 5,868 | 0.38 | 0.29    |  0.76      |

For example, we see that 8% of patients are in age group 45-54 in our population compared to 12% in the standard population. As such, each patient in this age group in our analyses is upweighted to represent 1.5 patients.

When using this approach with `strs` we provide the ICSS weights and the program calculates the Brenner weights for us.

When the "Brenner approach" was proposed in 2004 it was applied to the estimators of relative/net survival used at that time (Ederer II and Hakulinen). We have updated `strs` so that the approach can be used with the Pohar Perme estimator. The Pohar Perme estimator uses inverse-probability weighting (one weights by the inverse probability of expected survival). Standardisation using the Brenner approach involves applying an additional set of weights. 

We use a similar approach (applying the same weights) when performing model-based age-standardisation. [This page]({{< ref "/software/stata/model-based-standardisation.md" >}}) illustrates how the weights are calculated and used. Just to clarify, when modelling we must calculate the Brenner weights; when using `strs` we provide standard populatuion (e.g., ICSS) weights and `strs` calculates the Brenner weights.

## References

> H. Brenner, V. Arndt, O. Gefeller, and T. Hakulinen, An alternative approach to age adjustment of cancer survival rates, European Journal of Cancer, vol. 40, no. 15, pp. 2317-2322, 2004. [PubMed](https://www.ncbi.nlm.nih.gov/pubmed/15454258)

