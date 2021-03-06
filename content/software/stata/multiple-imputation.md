+++
date = "2019-03-13"
title = "Multiple imputation for missing covariates when modelling relative survival"
summary = "This exercise illustrates an approach to modelling relative survival with missing covariate data using multiple imputation."
shortsummary = "" 
tags = ["stpm2","imputation","missing data","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/multiple-imputation.do).

This exercise illustrates an approach to modelling relative survival with missing covariate data using multiple imputation. [Falcaro et al. (2015)](https://www.ncbi.nlm.nih.gov/pubmed/25774607) published a nice overview of methods for modelling net survival when covariate data are missing. They have also published a [paper](https://www.ncbi.nlm.nih.gov/pubmed/28315607) on multiple imputation for non-parametric estimation of net survival, which is not covered here. 

Mechanisms for missingness in survival analysis can be classifed as follows:

- Missing completely at random (MCAR)
- Covariate-dependent missing at random (CD-MAR)
- Missing at random (MAR)
- Missing not at random (MNAR)

Much of the early literature on missing data uses three classifcations (MCAR, MAR, and
MNAR). [Falcaro et al. (2015)](https://www.ncbi.nlm.nih.gov/pubmed/25774607) distinguish between MAR (where the probability of missingness depends on known covariates, the event indicator, and the survival time) and
CD-MAR (where the probability of missingness depends on known covariates, but not the the event indicator or survival time).

The analytic approach depends on the mechanism. Multiple imputation is appropriate for any of the patterns other than NMAR; if the data are MNAR then the problem is more difficult. We cannot use the observed data
to identify the mechanism, we need substantive scientific knowledge of the processes that
gave rise to the data. The validity of inference depends on the (untestable) assumptions
inherent in the mechanism.

We will proceed with multiple imputation to illustrate the approach, even if the appropriateness could be questioned (missing stage could depend on factors not available to us). 

```stata
. use http://pauldickman.com/data/colon.dta, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. stset surv_mm, failure(status=1 2) scale(12) exit(time 10*12)

     failure event:  status == 1 2
obs. time interval:  (0, surv_mm]
 exit on or before:  time 10*12
    t for analysis:  time/12

------------------------------------------------------------------------------
     15,564  total observations
          0  exclusions
------------------------------------------------------------------------------
     15,564  observations remaining, representing
     10,451  failures in single-record/single-failure data
 51,613.792  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =        10

. gen _age = min(int(age + _t),99)

. gen _year = int(yydx + mmdx/12 + _t)

. merge m:1 _year sex _age using http://pauldickman.com/data/popmort

    Result                           # of obs.
    -----------------------------------------
    not matched                         8,279
        from master                         0  (_merge==1)
        from using                      8,279  (_merge==2)

    matched                            15,564  (_merge==3)
    -----------------------------------------

. keep if _merge==3
(8,279 observations deleted)

. 
. tab stage

   Clinical |
   stage at |
  diagnosis |      Freq.     Percent        Cum.
------------+-----------------------------------
    Unknown |      2,356       15.14       15.14
  Localised |      6,274       40.31       55.45
   Regional |      1,787       11.48       66.93
    Distant |      5,147       33.07      100.00
------------+-----------------------------------
      Total |     15,564      100.00

. 
. /* Check stage distribution over age and gender */
. tab stage agegrp, column

+-------------------+
| Key               |
|-------------------|
|     frequency     |
| column percentage |
+-------------------+

  Clinical |
  stage at |             Age in 4 categories
 diagnosis |      0-44      45-59      60-74        75+ |     Total
-----------+--------------------------------------------+----------
   Unknown |        83        262        858      1,153 |     2,356 
           |     11.29      11.06      13.01      19.65 |     15.14 
-----------+--------------------------------------------+----------
 Localised |       297        993      2,716      2,268 |     6,274 
           |     40.41      41.93      41.20      38.65 |     40.31 
-----------+--------------------------------------------+----------
  Regional |       114        329        772        572 |     1,787 
           |     15.51      13.89      11.71       9.75 |     11.48 
-----------+--------------------------------------------+----------
   Distant |       241        784      2,247      1,875 |     5,147 
           |     32.79      33.11      34.08      31.95 |     33.07 
-----------+--------------------------------------------+----------
     Total |       735      2,368      6,593      5,868 |    15,564 
           |    100.00     100.00     100.00     100.00 |    100.00 

. tab stage sex, column

+-------------------+
| Key               |
|-------------------|
|     frequency     |
| column percentage |
+-------------------+

  Clinical |
  stage at |          Sex
 diagnosis |      Male     Female |     Total
-----------+----------------------+----------
   Unknown |       885      1,471 |     2,356 
           |     13.96      15.95 |     15.14 
-----------+----------------------+----------
 Localised |     2,620      3,654 |     6,274 
           |     41.32      39.61 |     40.31 
-----------+----------------------+----------
  Regional |       715      1,072 |     1,787 
           |     11.28      11.62 |     11.48 
-----------+----------------------+----------
   Distant |     2,120      3,027 |     5,147 
           |     33.44      32.82 |     33.07 
-----------+----------------------+----------
     Total |     6,340      9,224 |    15,564 
           |    100.00     100.00 |    100.00 

. 
. /* Graphs of survival by age group and stage */
. stpm2 ib1.stage##i.agegrp , df(5) bhaz(rate) scale(hazard) eform nolog

Log likelihood = -18205.571                     Number of obs     =     15,564

---------------------------------------------------------------------------------
                |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
----------------+----------------------------------------------------------------
xb              |
          stage |
       Unknown  |   1.116447   .2864249     0.43   0.668      .675246    1.845925
      Regional  |   1.853897   .3673454     3.12   0.002     1.257251     2.73369
       Distant  |   7.849335   1.117766    14.47   0.000     5.937717    10.37639
                |
         agegrp |
         45-59  |   .8300786   .1236065    -1.25   0.211     .6199652    1.111402
         60-74  |   .9399807   .1281619    -0.45   0.650     .7195512    1.227937
           75+  |   1.217131   .1711222     1.40   0.162     .9239804    1.603289
                |
   stage#agegrp |
 Unknown#45-59  |   2.091891   .6053175     2.55   0.011     1.186403    3.688467
 Unknown#60-74  |   2.183828   .5875785     2.90   0.004     1.288828    3.700342
   Unknown#75+  |   4.335722   1.161605     5.48   0.000     2.564553    7.330122
Regional#45-59  |   1.492494   .3449121     1.73   0.083     .9488588    2.347596
Regional#60-74  |    1.56255   .3337045     2.09   0.037      1.02813    2.374762
  Regional#75+  |   1.334842   .2959008     1.30   0.193     .8644497    2.061198
 Distant#45-59  |   1.311706   .2211291     1.61   0.108     .9426265    1.825295
 Distant#60-74  |   1.295841   .2001943     1.68   0.093     .9573039    1.754098
   Distant#75+  |   1.310089    .207943     1.70   0.089       .95983    1.788163
                |
          _rcs1 |   3.050329    .036273    93.79   0.000     2.980057    3.122257
          _rcs2 |   1.318658   .0119716    30.47   0.000     1.295402    1.342332
          _rcs3 |   .9920318   .0056634    -1.40   0.161     .9809937    1.003194
          _rcs4 |    1.04735   .0038704    12.52   0.000     1.039791    1.054963
          _rcs5 |   1.011087   .0029654     3.76   0.000     1.005292    1.016916
          _cons |   .1027228   .0128049   -18.26   0.000     .0804563    .1311516
---------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

. predict survival, surv

. line survival _t if stage==0, lpattern(dash) sort || ///
> line survival _t if stage==1, sort || ///
> line survival _t if stage==2, sort || ///
> line survival _t if stage==3, sort by(agegrp) ///
>  legend(order(1 "Unknown" 2 "Localised" 3 "Regional" 4 "Distant")) ///
>  name(s_by_stage, replace) ysize(8) xsize(11) ytitle("Relative survival") ///
>  xtitle("years since diagnosis")
```
{{< figure src="/svg/multiple-imputation1.svg" title="Relative survival by age group and stage." numbered="true" >}}

```stata
. /* Fit model using missing indicator approach */
. stpm2 ib1.stage i.agegrp , df(5) bhaz(rate) scale(hazard) eform nolog

Log likelihood = -18267.394                     Number of obs     =     15,564

------------------------------------------------------------------------------
             |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
       stage |
    Unknown  |   3.241262   .1571215    24.26   0.000     2.947487    3.564319
   Regional  |   2.660883   .1403817    18.55   0.000     2.399487    2.950755
    Distant  |   10.00967   .3928204    58.70   0.000     9.268619    10.80997
             |
      agegrp |
      45-59  |   1.101743   .0692448     1.54   0.123     .9740518    1.246174
      60-74  |   1.241194   .0720058     3.72   0.000     1.107793    1.390659
        75+  |   1.780897   .1042263     9.86   0.000     1.587898    1.997354
             |
       _rcs1 |   3.044807   .0362527    93.52   0.000     2.974576    3.116697
       _rcs2 |   1.320444   .0119872    30.62   0.000     1.297157    1.344149
       _rcs3 |     .99282   .0056625    -1.26   0.206     .9817836     1.00398
       _rcs4 |   1.048117   .0038603    12.76   0.000     1.040579    1.055711
       _rcs5 |   1.011472   .0029515     3.91   0.000     1.005704    1.017273
       _cons |   .0765708   .0049307   -39.90   0.000     .0674918    .0868711
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.

. 
. /* Refit model using complete records approach */
. replace stage=. if stage==0
(2,356 real changes made, 2,356 to missing)

. stpm2 ib1.stage i.agegrp , df(5) bhaz(rate) scale(hazard) eform nolog

Log likelihood = -15353.605                     Number of obs     =     13,208

------------------------------------------------------------------------------
             |     exp(b)   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
       stage |
   Regional  |   2.676154   .1410076    18.68   0.000     2.413576    2.967299
    Distant  |    10.3598   .4080125    59.36   0.000     9.590197    11.19117
             |
      agegrp |
      45-59  |   1.061092   .0688816     0.91   0.361     .9343219    1.205062
      60-74  |   1.204694   .0721444     3.11   0.002     1.071277    1.354727
        75+  |   1.557469   .0950547     7.26   0.000     1.381876    1.755373
             |
       _rcs1 |   3.141848   .0410415    87.64   0.000     3.062429    3.223326
       _rcs2 |   1.318276   .0133637    27.26   0.000     1.292342     1.34473
       _rcs3 |   1.001148    .006439     0.18   0.858     .9886073    1.013848
       _rcs4 |   1.050811   .0043694    11.92   0.000     1.042282     1.05941
       _rcs5 |   1.010931     .00336     3.27   0.001     1.004367    1.017538
       _cons |   .0807468   .0053034   -38.31   0.000     .0709936    .0918398
------------------------------------------------------------------------------
Note: Estimates are transformed only in the first equation.
``` 

We now set up the data for multiple imputation. Theory dictates that the imputation model (specified later) should contain the outcome, which we will specify using the event indicator and estimated cumulative hazard. We therefore generate the Nelson-Aalen estimate of the cumulative hazard and store it in the variable H. 
 
```stata 
. sts gen H=na

. // Declare multiple-imputation data and register variables accordingly
. mi set flong

. mi register imputed stage
(2356 m=0 obs. now marked as incomplete)

. mi register regular subsite agegrp sex

. mi register passive _rcs* _d_rcs*
```

We now multiply impute missing values using chained equations. We set the seed so as to obtain reproducible results but that step is not necessary in practice.

[Carpenter and Kenward (page 55)](https://onlinelibrary.wiley.com/doi/book/10.1002/9781119942283) suggest 30 imputations but we will use only 10 to reduce computational time.

```stata 
. // Perform imputation. 
. set seed 29390

. mi impute chained (mlogit) stage = i.subsite sex i.agegrp H _d, add(10)
note: missing-value pattern is monotone; no iteration performed

Conditional models (monotone):
             stage: mlogit stage i.subsite sex i.agegrp H _d

Performing chained iterations ...

Multivariate imputation                     Imputations =       10
Chained equations                                 added =       10
Imputed: m=1 through m=10                       updated =        0

Initialization: monotone                     Iterations =        0
                                                burn-in =        0

             stage: multinomial logistic regression

------------------------------------------------------------------
                   |               Observations per m             
                   |----------------------------------------------
          Variable |   Complete   Incomplete   Imputed |     Total
-------------------+-----------------------------------+----------
             stage |      13208         2356      2356 |     15564
------------------------------------------------------------------
(complete + incomplete = total; imputed is the minimum across m
 of the number of filled-in observations.)
```

We'll examine the imputed data for selected observation. The variable `_mi_m` is zero for the observations in the
original data and a sequential integer (1 to 10) for the imputed observations. The first observation with missing stage (`id==2287`) is a women aged 45-59 who died within 6 months of diagnosis. The distribution of imputed values is heavily weighted towards distant stage. The second observation we look at (`id==3362`) is a woman aged 75+ years at diagnosis who dies after more than 6 years after diagnosis. The distribution of imputed values is heavily weighted towards localised.

```stata  
. list id _mi_m agegrp sex stage _t _d if id==2287

        +-------------------------------------------------------------+
        |   id   _mi_m   agegrp      sex       stage          _t   _d |
        |-------------------------------------------------------------|
    63. | 2287       0    45-59   Female           .   .04166667    1 |
 15627. | 2287       1    45-59   Female     Distant   .04166667    1 |
 31191. | 2287       2    45-59   Female     Distant   .04166667    1 |
 46755. | 2287       3    45-59   Female     Distant   .04166667    1 |
 62319. | 2287       4    45-59   Female     Distant   .04166667    1 |
        |-------------------------------------------------------------|
 77883. | 2287       5    45-59   Female   Localised   .04166667    1 |
 93447. | 2287       6    45-59   Female    Regional   .04166667    1 |
109011. | 2287       7    45-59   Female     Distant   .04166667    1 |
124575. | 2287       8    45-59   Female     Distant   .04166667    1 |
140139. | 2287       9    45-59   Female     Distant   .04166667    1 |
        |-------------------------------------------------------------|
155703. | 2287      10    45-59   Female     Distant   .04166667    1 |
        +-------------------------------------------------------------+

. list id _mi_m agegrp sex stage _t _d if id==3362

        +-------------------------------------------------------------+
        |   id   _mi_m   agegrp      sex       stage          _t   _d |
        |-------------------------------------------------------------|
  2270. | 3362       0      75+   Female           .   6.2083333    1 |
 17834. | 3362       1      75+   Female   Localised   6.2083333    1 |
 33398. | 3362       2      75+   Female   Localised   6.2083333    1 |
 48962. | 3362       3      75+   Female   Localised   6.2083333    1 |
 64526. | 3362       4      75+   Female   Localised   6.2083333    1 |
        |-------------------------------------------------------------|
 80090. | 3362       5      75+   Female   Localised   6.2083333    1 |
 95654. | 3362       6      75+   Female   Localised   6.2083333    1 |
111218. | 3362       7      75+   Female   Localised   6.2083333    1 |
126782. | 3362       8      75+   Female   Localised   6.2083333    1 |
142346. | 3362       9      75+   Female   Localised   6.2083333    1 |
        |-------------------------------------------------------------|
157910. | 3362      10      75+   Female    Regional   6.2083333    1 |
        +-------------------------------------------------------------+

. list id _mi_m agegrp sex stage _t _d if id==3501

        +------------------------------------------------------+
        |   id   _mi_m   agegrp      sex       stage   _t   _d |
        |------------------------------------------------------|
  5080. | 3501       0      75+   Female           .   10    0 |
 20644. | 3501       1      75+   Female   Localised   10    0 |
 36208. | 3501       2      75+   Female   Localised   10    0 |
 51772. | 3501       3      75+   Female   Localised   10    0 |
 67336. | 3501       4      75+   Female   Localised   10    0 |
        |------------------------------------------------------|
 82900. | 3501       5      75+   Female   Localised   10    0 |
 98464. | 3501       6      75+   Female    Regional   10    0 |
114028. | 3501       7      75+   Female   Localised   10    0 |
129592. | 3501       8      75+   Female   Localised   10    0 |
145156. | 3501       9      75+   Female   Localised   10    0 |
        |------------------------------------------------------|
160720. | 3501      10      75+   Female   Localised   10    0 |
        +------------------------------------------------------+
```

We now refit the flexible parametric model, this time to the imputed data. The `mi
estimate` command effectively fits the model to each of the 10 imputed data sets and
then combines the resulting estimates. Since `stpm2` is not an official Stata command
we need to specify the `cmdok` option to specify that the command is OK for use with
imputed data. We also save the resulting estimates in order to make predictions in a
later step.

```stata
. mi estimate, dots cmdok sav(mi_stpm2,replace): ///
>     stpm2 ib1.stage i.agegrp, df(5) bhaz(rate) scale(hazard) nolog eform

Imputations (10):
  .........10 done

Multiple-imputation estimates                   Imputations       =         10
                                                Number of obs     =     15,564
                                                Average RVI       =     0.0678
                                                Largest FMI       =     0.2246
DF adjustment:   Large sample                   DF:     min       =     191.94
                                                        avg       = 161,766.44
Within VCE type:          OIM                           max       = 730,392.23

 ( 1)  [xb]_rcs1 - [dxb]_d_rcs1 = 0
 ( 2)  [xb]_rcs2 - [dxb]_d_rcs2 = 0
 ( 3)  [xb]_rcs3 - [dxb]_d_rcs3 = 0
 ( 4)  [xb]_rcs4 - [dxb]_d_rcs4 = 0
 ( 5)  [xb]_rcs5 - [dxb]_d_rcs5 = 0
------------------------------------------------------------------------------
             |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
       stage |
   Regional  |   .9669048   .0554079    17.45   0.000     .8576181    1.076191
    Distant  |    2.32957   .0381676    61.04   0.000     2.254674    2.404465
             |
      agegrp |
      45-59  |   .0781396   .0638174     1.22   0.221    -.0469585    .2032376
      60-74  |   .2059373   .0602865     3.42   0.001     .0876842    .3241903
        75+  |   .5452103   .0593367     9.19   0.000      .428899    .6615217
             |
       _rcs1 |   1.144416    .012122    94.41   0.000     1.120655    1.168176
       _rcs2 |   .2693923   .0091673    29.39   0.000     .2514247    .2873598
       _rcs3 |   -.008823   .0058069    -1.52   0.129    -.0202044    .0025583
       _rcs4 |   .0471367   .0038664    12.19   0.000      .039558    .0547154
       _rcs5 |   .0118175   .0030844     3.83   0.000     .0057721    .0178629
       _cons |  -2.569309   .0651194   -39.46   0.000    -2.697028    -2.44159
-------------+----------------------------------------------------------------
dxb          |
     _d_rcs1 |   1.144416    .012122    94.41   0.000     1.120655    1.168176
     _d_rcs2 |   .2693923   .0091673    29.39   0.000     .2514247    .2873598
     _d_rcs3 |   -.008823   .0058069    -1.52   0.129    -.0202044    .0025583
     _d_rcs4 |   .0471367   .0038664    12.19   0.000      .039558    .0547154
     _d_rcs5 |   .0118175   .0030844     3.83   0.000     .0057721    .0178629
------------------------------------------------------------------------------
```
Now predict the survival function based on the fitted model. We specify `timevar(_t)` (which is usually the default) to force recalculation of the spline variables.

Using the fact that the original data is still in the new dataset (with `_mi_m==0`), we
can refit the model using the complete records approach and obtain predictions of
survival. We will graphically compare the predicted relative survival curves from the
imputation model and the complete records model for the 60-74 age-group.

```stata 
. // predict survival using -mi predictnl-
. mi predictnl survimp2 = predict(survival at(agegrp 2) timevar(_t)) using mi_stpm2

. // compare predictions to complete case analysis
. stpm2 ib1.stage i.agegrp if _mi_m==0, df(5) scale(h) bhaz(rate) 

Log likelihood = -15353.605                     Number of obs     =     13,208

------------------------------------------------------------------------------
             |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
xb           |
       stage |
   Regional  |   .9843808   .0526904    18.68   0.000     .8811095    1.087652
    Distant  |   2.337933   .0393842    59.36   0.000     2.260741    2.415125
             |
      agegrp |
      45-59  |   .0592983   .0649158     0.91   0.361    -.0679343    .1865309
      60-74  |   .1862257   .0598861     3.11   0.002     .0688511    .3036003
        75+  |   .4430619   .0610316     7.26   0.000     .3234423    .5626816
             |
       _rcs1 |   1.144811   .0130629    87.64   0.000     1.119208    1.170414
       _rcs2 |   .2763246   .0101372    27.26   0.000      .256456    .2961932
       _rcs3 |   .0011476   .0064316     0.18   0.858    -.0114581    .0137533
       _rcs4 |   .0495627   .0041581    11.92   0.000     .0414129    .0577125
       _rcs5 |   .0108717   .0033237     3.27   0.001     .0043574    .0173861
       _cons |  -2.516437   .0656789   -38.31   0.000    -2.645166   -2.387709
------------------------------------------------------------------------------

. predict surv, survival at(agegrp 2)

. line surv survimp2 _t if stage==1 & _mi_m==0, sort || ///
> line surv survimp2 _t if stage==2 & _mi_m==0, sort || ///
> line surv survimp2 _t if stage==3 & _mi_m==0, sort ///
> title("Predicted survival for agegrp==2 (60-74)") ///
> legend(order(1 "Localised (Complete)" 2  "Localised (Imputed)" ///
>  3 "Regional (Complete)" 4 "Regional (Imputed)" ///
>  5 "Distant (Complete)" 6 "Distant (Imputed)")) ///
>  name(imputed, replace) ysize(8) xsize(11) ytitle("Relative survival") ///
>  title("Relative survival by stage") xtitle("years since diagnosis")
```

{{< figure src="/svg/multiple-imputation2.svg" title="Relative survival by stage estimated using complete case analysis and multiple imputation." numbered="true" >}}
