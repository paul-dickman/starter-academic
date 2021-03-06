+++
date = "2019-05-03"
title = "Interpretation of interaction effects"
subtitle = "Paul Dickman, Caroline Weibull"
summary = "Illustrates Stata factor variable notation and how to reparameterise a model to get the estimated effect of an exposure for each level of a modifier. Illustrates how we can fit a single model with interactions that is equivalent to stratified models."
shortsummary = "" 
tags = ["stcox","Stata","interactions"]
math = true
[header]
image = ""
caption = ""
+++

{{% toc %}}

The code used in this tutorial is available [here](/software/stata/parameterising-interactions.do). 

## Introduction

This tutorial illustrates Stata factor variable notation with a focus on how to reparameterise a statistical model to get the effect of an exposure for each level of a modifier. We will study survival of patients diagnosed with melanoma, focusing on differences in survival between males and females. In epidemiological language, sex is the exposure and we call the estimated hazard ratio the 'effect of sex'. We will investigate whether the effect of sex is modified by anatomical subsite. That is, we will fit an interaction between sex and subsite.  In epidemiological language, subsite is the modifier and we are interested in estimating the effect of sex for each level of the modifier. 

We will adjust for stage (in categories) and year of diagnosis (as a restricted cubic spline) but our model is much simpler than what would be required for a rigorous scientific study of sex differences in patient survival. The focus of this tutorial is on illustrating statistical concepts and data analysis in Stata, not a scientific study of sex differences in survival.

Stata has a rich framework for working with factor variables, although `fvvarlist` is not a term one would naturally search for. We highly recommend looking at the help file. 

```stata
help fvvarlist
```  
We recommend setting the following option (which can be set permanently). This specifies that base levels of factor variables are reported in coefficient tables.

```stata
set showbaselevels on
```  

## Preparing the data

We read the data, excluding patients with `stage==0` (unknown), create the spline basis variables for year of diagnosis, and illustrate the coding of the exposure variable (`sex`) and modifier (`subsite`). We `stset` with death due to melanoma as the outcome (i.e., we will model cause-specific mortality).

```stata
. use https://pauldickman.com/data/melanoma.dta if stage>0, clear
(Skin melanoma, diagnosed 1975-94, follow-up to 1995)

. // spline variables for year of diagnosis
. rcsgen yydx, df(3) gen(yearspl) orthog
Variables yearspl1 to yearspl3 were created

. codebook sex subsite
---------------------------------------------------------
sex                                                   Sex
---------------------------------------------------------
          type:  numeric (byte)
         label:  sex

         range:  [1,2]                     units:  1
 unique values:  2                     missing .:  0/6,144

    tabulation:  Freq.   Numeric  Label
                 2,921         1  Male
                 3,223         2  Female

---------------------------------------------------------
subsite                      Anatomical subsite of tumour
---------------------------------------------------------
         type:  numeric (byte)
        label:  melsub

        range:  [1,4]                     units:  1
unique values:  4                     missing .:  0/6,144

   tabulation:  Freq.   Numeric  Label
                  932         1  Head and Neck
                2,588         2  Trunk
                2,397         3  Limbs
                  227         4  Multiple and NOS


. // cause-specific survival (status==1 is death due to melanoma) 
. stset surv_mm, fail(status==1) scale(12) exit(time 120)
[output omitted] 
```  

## Main effects model
We'll start by fitting a main effects model.

```stata
. // main effects model
. stcox i.sex i.subsite i.agegrp i.stage yearspl*

Cox regression -- Breslow method for ties

No. of subjects =        6,144                  Number of obs    =       6,144
No. of failures =        1,579
Time at risk    =  34495.70833
                                                LR chi2(12)      =     1728.47
Log likelihood  =   -12391.973                  Prob > chi2      =      0.0000

-----------------------------------------------------------------------------------
               _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
              sex |
            Male  |          1  (base)
          Female  |   .7491124   .0404733    -5.35   0.000     .6738418     .832791
                  |
          subsite |
   Head and Neck  |          1  (base)
           Trunk  |   1.404551   .1101098     4.33   0.000     1.204503    1.637825
           Limbs  |   1.028769   .0853752     0.34   0.733      .874337    1.210479
Multiple and NOS  |   1.352698   .1526057     2.68   0.007     1.084356    1.687445
                  |
           agegrp |
            0-44  |          1  (base)
           45-59  |   1.282252   .0944769     3.37   0.001      1.10983    1.481461
           60-74  |   1.642131   .1179264     6.91   0.000     1.426529     1.89032
             75+  |   2.592047    .222304    11.11   0.000     2.190991    3.066516
                  |
            stage |
       Localised  |          1  (base)
        Regional  |   4.676851   .3598114    20.05   0.000     4.022228    5.438014
         Distant  |   13.27193   .8935656    38.40   0.000     11.63121    15.14409
                  |
         yearspl1 |   .9047125   .0257987    -3.51   0.000     .8555352    .9567167
         yearspl2 |   .9063623   .0248673    -3.58   0.000     .8589106    .9564354
         yearspl3 |   .9709451   .0269668    -1.06   0.288      .919504    1.025264
-----------------------------------------------------------------------------------
. estimates store main
```  

The estimated hazard ratio for sex is 0.749, indicating that females experience 25% lower cause-specific mortality than males. This estimate is assumed to apply for every point in follow-up (i.e., proportional hazards) and for every combination of subsite, age group, stage, and year of diagnosis.

We will now partially relax that assumption, by fitting an interaction between sex and subsite. We are now allowing the effect of sex to differ for each subsite, but the estimates are assumed the same for each combination of age group, stage, and year of diagnosis and at each point in the follow-up.  

## Interaction model (default parameterisation)
We will start by using the default parameterisation of interaction effects.

```stata
. stcox i.sex##i.subsite i.agegrp i.stage yearspl*

Cox regression -- Breslow method for ties

No. of subjects =        6,144                  Number of obs    =       6,144
No. of failures =        1,579
Time at risk    =  34495.70833
                                                LR chi2(15)      =     1735.79
Log likelihood  =   -12388.312                  Prob > chi2      =      0.0000

-----------------------------------------------------------------------------------
               _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
------------------+----------------------------------------------------------------
              sex |
            Male  |          1  (base)
          Female  |    .628822   .0855549    -3.41   0.001     .4816336    .8209915
                  |
          subsite |
   Head and Neck  |          1  (base)
           Trunk  |   1.298793   .1291657     2.63   0.009     1.068778    1.578311
           Limbs  |   .9656877   .1105328    -0.31   0.760     .7716281    1.208552
Multiple and NOS  |   1.084464   .1547194     0.57   0.570     .8199268     1.43435
                  |
      sex#subsite |
    Female#Trunk  |   1.187256   .1867563     1.09   0.275     .8722676    1.615991
    Female#Limbs  |   1.159554   .1902997     0.90   0.367     .8406138    1.599505
 Female#Multiple  |   1.790329   .3885472     2.68   0.007     1.170039    2.739462
                  |
           agegrp |
            0-44  |          1  (base)
           45-59  |   1.285638   .0947599     3.41   0.001     1.112704    1.485449
           60-74  |   1.648806    .118435     6.96   0.000     1.432277    1.898069
             75+  |   2.570516   .2214068    10.96   0.000     2.171219    3.043246
                  |
            stage |
       Localised  |          1  (base)
        Regional  |   4.619355   .3562432    19.84   0.000     3.971339     5.37311
         Distant  |   13.23336   .8954071    38.17   0.000     11.58978    15.11001
                  |
         yearspl1 |   .9043927   .0258057    -3.52   0.000     .8552027     .956412
         yearspl2 |   .9053973   .0248939    -3.61   0.000     .8578974    .9555271
         yearspl3 |   .9697156   .0269117    -1.11   0.268     .9183786    1.023922
-----------------------------------------------------------------------------------
. estimates store inter
```  

## Testing significance of the interaction

Before attempting to interpret the estimates, we will test the statistical significance of the interaction effect. In the main effects model we estimated one hazard ratio for the effect of sex, whereas we are now estimating four hazard ratios (one for each subsite). The interaction model therfore has 3 additional parameters. The likelihood ratio test (`lrtest` command) suggests there is some evidence of an interaction (p=0.06). That is, there is evidence that the effect of sex is not the same for the four subsites.
```stata
. lrtest main

Likelihood-ratio test                                 LR chi2(3)  =      7.32
(Assumption: main nested in inter)                    Prob > chi2 =    0.0623
```
For completeness, we'll also use a Wald test (`test` command) although, since the Wald test is an approximation to the LR test, the LR test is preferred. 

```stata
// Wald test
. test 2.sex#2.subsite 2.sex#3.subsite 2.sex#4.subsite

 ( 1)  2.sex#2.subsite = 0
 ( 2)  2.sex#3.subsite = 0
 ( 3)  2.sex#4.subsite = 0

           chi2(  3) =    7.49
         Prob > chi2 =    0.0578
```  
The first line in the coefficient table reports a hazard ratio for sex of 0.6288. This is the estimated effect of sex for the reference level of subsite (head and neck). To get the estimated effect of sex for the other levels of subsite we need to multiply by the interaction effects. That is, the estimated effect of sex for patients with melanomas on the trunk is given by 0.6288*1.187=0.746

Similarly, the estimated effect of sex for patients with melanomas on the limbs is given by 0.6288*1.159554=0.729   

## Using lincom

We can easily get the effects of sex for each subsite by multiplying the estimated hazard ratios, but this does not give us standard errors or confidence intervals. In a future step we will show how to get these directly in the regression output, but first we show how these can be obtained using the `lincom` (linear combination of parameters) command. Here we see the code for estimating the effect of sex for patients with melanoma on the trunk (subsite 2). The estimated hazard ratio is the same as that previously calculated (0.6288*1.187=0.746) but we now get a confidence interal.

```stata
. // effect of sex for level 2 of subsite (trunk)
. lincom 2.sex + 2.sex#2.subsite, eform

 ( 1)  2.sex + 2.sex#2.subsite = 0

------------------------------------------------------------------------------
          _t |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         (1) |   .7465727   .0598051    -3.65   0.000     .6380953    .8734915
------------------------------------------------------------------------------
```  

We previously multiplied the estimated hazard ratios, but now we sum the parameter estimates (log hazard ratios) and exponentiate the result.

The Cox model is often written as 

$$
h_i(t|\mathbf{x}\_i)=h\_0(t)\exp\left(\mathbf{x}\_i\beta\right)
$$
or
$$
\ln(h_i(t|\mathbf{x}\_i))=\ln(h\_0(t)) + \mathbf{x}\_i\beta
$$
 
The parameters ($\beta$) are interpreted as log hazard ratios, but `stcox` by default reports $\exp(\beta)$ (which are interpreted as hazard ratios). When combining parameter estimates, we do it on the original scale. We therefore sum the parameter estimates and exponentiate the result (`eform` option).

## Reparameterising the model

We can reparameterise the model so that Stata gives us the estimated effects of sex for each level of subite. We get the same estimates (and confidence intervals) as with lincom but without the extra step. The trick is to specify the interaction term (with a single hash) and the main effect of the modifier (`subsite`). Note that we are fitting the exact same model as previously and estimating the exact same number of parameters, we are just changing what the parameters represent. 

```stata
. stcox i.sex#i.subsite i.subsite i.agegrp i.stage yearspl*

Cox regression -- Breslow method for ties

No. of subjects =        6,144                  Number of obs    =       6,144
No. of failures =        1,579
Time at risk    =  34495.70833
                                                LR chi2(15)      =     1735.79
Log likelihood  =   -12388.312                  Prob > chi2      =      0.0000

------------------------------------------------------------------------------------------
                      _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------------------+----------------------------------------------------------------
             sex#subsite |
   Female#Head and Neck  |    .628822   .0855549    -3.41   0.001     .4816336    .8209915
           Female#Trunk  |   .7465727   .0598051    -3.65   0.000     .6380953    .8734915
           Female#Limbs  |   .7291532   .0692519    -3.33   0.001     .6053065    .8783392
Female#Multiple and NOS  |   1.125798   .1931375     0.69   0.490     .8043252    1.575757
                         |
                 subsite |
          Head and Neck  |          1  (base)
                  Trunk  |   1.298793   .1291657     2.63   0.009     1.068778    1.578311
                  Limbs  |   .9656877   .1105328    -0.31   0.760     .7716281    1.208552
       Multiple and NOS  |   1.084464   .1547194     0.57   0.570     .8199268     1.43435
                         |
                  agegrp |
                   0-44  |          1  (base)
                  45-59  |   1.285638   .0947599     3.41   0.001     1.112704    1.485449
                  60-74  |   1.648806    .118435     6.96   0.000     1.432277    1.898069
                    75+  |   2.570516   .2214068    10.96   0.000     2.171219    3.043246
                         |
                   stage |
              Localised  |          1  (base)
               Regional  |   4.619355   .3562432    19.84   0.000     3.971339     5.37311
                Distant  |   13.23336   .8954071    38.17   0.000     11.58978    15.11001
                         |
                yearspl1 |   .9043927   .0258057    -3.52   0.000     .8552027     .956412
                yearspl2 |   .9053973   .0248939    -3.61   0.000     .8578974    .9555271
                yearspl3 |   .9697156   .0269117    -1.11   0.268     .9183786    1.023922
------------------------------------------------------------------------------------------
```  
For completeness, this is how we test significance of the interaction in the new parameterisation. We could also use a likelihood ratio test with the same syntax used previously (and the same result).
```stata
. // test significance of the interaction effect
. test 2.sex#1.subsite=2.sex#2.subsite=2.sex#3.subsite=2.sex#4.subsite

 ( 1)  2.sex#1b.subsite - 2.sex#2.subsite = 0
 ( 2)  2.sex#1b.subsite - 2.sex#3.subsite = 0
 ( 3)  2.sex#1b.subsite - 2.sex#4.subsite = 0

           chi2(  3) =    7.49
         Prob > chi2 =    0.0578
```  
In the default parameterisation, the interaction terms represented the departure of the hazard ratio from the hazard ratio in the reference level. We therefore tested the null hypothesis that the interaction effects were all zero. Now we are estimating the hazard ratios for each subsite, so the null hypothesis is that they are equivalent (not neccesarily zero).  

## Stratified models

It's also possible to estimate the effect of sex for each subsite by fitting four separate models (one for each subsite). For example, here we refit the model for subsite 2 (trunk).

```stata
. stcox i.sex i.agegrp i.stage yearspl* if subsite==2

Cox regression -- Breslow method for ties

No. of subjects =        2,588                  Number of obs    =       2,588
No. of failures =          732
Time at risk    =     14424.75
                                                LR chi2(9)       =      661.72
Log likelihood  =   -5163.1008                  Prob > chi2      =      0.0000
------------------------------------------------------------------------------
          _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
         sex |
       Male  |          1  (base)
     Female  |   .7277464   .0586213    -3.95   0.000     .6214614    .8522087
             |
[output omitted]
```  
We get the estimated effect of sex for subsite 2 (trunk), but the estimate (0.7277) is slightly different from that we obtained previously (0.74657) as we are making different assumptions. Fitting a stratified model is equivalent to assuming an interaction between subsite and all variables in the model. Previously we fitted an interaction  between sex and subsite, but assumed the effects of age, stage, and year of diagnosis were the same for all subsites. We are now, effectively, assuming the effects of age, stage, and year of diagnosis are different for each subsite. This may well be a more appropriate model. However, we might also be estimating a number of unnecessary parameters. Our preference is to fit a single model containing appropriate interactions, although if we have a complex model and know that all interactions are required then we might fit stratified models. 

For example, we can fit a single model that is identical to the four stratified models as follows.

```stata  
. stcox i.sex#i.subsite i.subsite i.agegrp#i.subsite ///
>   i.stage#i.subsite c.yearspl*#i.subsite, strata(subsite)

Stratified Cox regr. -- Breslow method for ties

No. of subjects =        6,144                  Number of obs    =       6,144
No. of failures =        1,579
Time at risk    =  34495.70833
                                                LR chi2(36)      =     1512.61
Log likelihood  =   -10477.437                  Prob > chi2      =      0.0000
--------------------------------------------------------------------------------------------
                        _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
---------------------------+----------------------------------------------------------------
               sex#subsite |
     Female#Head and Neck  |   .6262703   .0906769    -3.23   0.001     .4715388    .8317757
             Female#Trunk  |   .7277464   .0586213    -3.95   0.000     .6214614    .8522087
             Female#Limbs  |   .7233878    .070645    -3.32   0.001     .5973709    .8759883
  Female#Multiple and NOS  |   1.186297   .2169155     0.93   0.350     .8289919    1.697604
                           |
[output omitted]
```  
The `strata` option spefies a so-called stratified Cox model, which is effectively an interaction between the strata variable (subsite) and follow-up time. That is, we estimate the same number of parameters as in the four stratified models but within a single model. This gives us the possibility to omit unnecessary interactions. Even if all of these interactions are required, estimating a single model gives the possibility to test contrasts of interest that cannot be done when we fit stratified models.   

