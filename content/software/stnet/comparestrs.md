+++
date = "2019-03-02"
title = "Comparison of life table estimators of relative/net survival"
subtitle = "Paul Dickman, Enzo Coviello"
summary = "In this tutorial, we estimate net survival using both the Ederer II approach and the Pohar Perme approach. We do this using both -stnet- and -strs- (and get the same results). "
tags = ["strs","stnet","software","Stata"]
math = false
[header]
image = ""
caption = ""
+++

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stnet/comparestrs.do).

In this tutorial we will estimate net survival using both the Ederer II approach and the Pohar Perme approach. We will do this using both `stnet` and `strs` (and get the same results).

We first load the colon cancer data (restricting to localised stage) and `stset`.

```stata
. use colon if stage==1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. stset exit, origin(dx) fail(status==1,2) id(id) scale(365.24)
[output omitted]

. generate birthdate=dx-age*365.24
```
In some [other examples]({{< ref "/software/strs/survival.md" >}}), we `stset` using pre-calculated survival times (`surv_mm`). Here we specify the day of diagnosis (`dx`) and day of exit (`exit`) and let Stata calculate the survival time for us. `stnet` requires that we specify a date of birth; we don't have this in our data set so we approximate it from day of diagnosis and age (in completed years) at diagnosis. Note that the day part of day of diagnosis has also been simulated (before the data were made available).

`stnet` requires us to specify date of birth and date of diagnosis; it then calculates attained age and attained year (i.e., the values of age and year during follow-up). `strs` requires us to specify age at diagnosis and year of diagnosis; it then calculates attained age and attained year. Our data set uses the `strs` default variables names for age at diagnosis (`age`) and year of diagnosis (`yydx`) so we don't need to specify them in the code. `strs` allows decimal values for year of diagnosis, but the variable in the data set in yhear as an integer. Because `stnet` calculates year of diagnosis as a decimal, we will update the variable we have in our data from an integer to a decimal so that `stnet` and `strs` calculate year in the same way.    

```stata
. replace yydx = 1960 + dx/365.241
```

We now call `stnet`.

```stata
. stnet using popmort, mergeby(_year sex _age) ///
>  breaks(0(.083333333)10) diagdate(dx) birthdate(birthdate) ederer ///
>  list(n d cre2 cns locns upcns secns) listyearly

         failure _d:  status == 1 2
   analysis time _t:  (exit-origin)/365.24
             origin:  time dx
                 id:  id

Cumulative net survival according to Pohar Perme, Stare and Estève method.
and cumulative relative survival according to Ederer II method.

  +----------------------------------------------------------------------+
  | start   end      n    d     cre2      cns    locns    upcns    secns |
  |----------------------------------------------------------------------|
  | .9167     1   5566   44   0.9207   0.9202   0.9112   0.9282   0.0043 |
  | 1.917     2   4681   34   0.8662   0.8651   0.8532   0.8760   0.0058 |
  | 2.917     3   3950   32   0.8276   0.8277   0.8136   0.8408   0.0069 |
  | 3.917     4   3324   22   0.7983   0.7994   0.7831   0.8146   0.0080 |
  | 4.917     5   2835   23   0.7755   0.7797   0.7612   0.7970   0.0091 |
  |----------------------------------------------------------------------|
  | 5.917     6   2367   16   0.7476   0.7508   0.7292   0.7710   0.0107 |
  | 6.917     7   1981    6   0.7271   0.7279   0.7033   0.7509   0.0121 |
  | 7.917     8   1667    9   0.7162   0.7187   0.6907   0.7446   0.0137 |
  | 8.917     9   1410   11   0.7115   0.7212   0.6891   0.7505   0.0157 |
  | 9.917    10   1173    9   0.7065   0.7198   0.6803   0.7554   0.0192 |
  +----------------------------------------------------------------------+
```

We see that the Pohar Perme (`cns`) and Ederer II (`cre2`) approaches give similar estimates of net survival, especially in the first 5 years. The two estimates will be even closer if we stratify on age (see later example). 

We now call `strs` using the `pohar` option. The `ht` option specifies that the hazard transformation approach to estimation (rather than the actuarial) is used. The results are identical to those obtained with `stnet`. 

```stata
. strs using popmort, breaks(0(.083333333)10) mergeby(_year sex _age) ///
>      ht pohar list(n d cr_e2 cns_pp lo_cns_pp hi_cns_pp) notables save(replace)

         failure _d:  status == 1 2
   analysis time _t:  (exit-origin)/365.24
             origin:  time dx
                 id:  id

The conditional survival proportion (p) is estimated by transforming the
estimated cumulative hazard rather than by the actuarial method (default).
See http://pauldickman.com/rsmodel/stata_colon/standard_errors.pdf for details.
       
. use grouped, clear
(Collapsed (or grouped) survival data)

. list end n d cr_e2 cns_pp lo_cns_pp hi_cns_pp if floor(end)==end

     +---------------------------------------------------------+
     | end      n    d    cr_e2   cns_pp   lo_cns~p   hi_cns~p |
     |---------------------------------------------------------|
 12. |   1   5566   44   0.9207   0.9202     0.9112     0.9282 |
 24. |   2   4681   34   0.8662   0.8651     0.8532     0.8760 |
 36. |   3   3950   32   0.8276   0.8277     0.8136     0.8408 |
 48. |   4   3324   22   0.7983   0.7994     0.7831     0.8146 |
 60. |   5   2835   23   0.7755   0.7797     0.7612     0.7970 |
     |---------------------------------------------------------|
 72. |   6   2367   16   0.7476   0.7508     0.7292     0.7710 |
 84. |   7   1981    6   0.7271   0.7279     0.7033     0.7509 |
 96. |   8   1667    9   0.7162   0.7187     0.6907     0.7446 |
108. |   9   1410   11   0.7115   0.7212     0.6891     0.7505 |
120. |  10   1173    9   0.7065   0.7198     0.6803     0.7554 |
     +---------------------------------------------------------+
```

## Age-specific estimates

We now estimate survival within age groups, by including the `by(agegrp)` option to `strs`. The Ederer II and Pohar Perme estimates will be identical if expected survival is identical for all individuals. This won't happen in practice, but the difference between them (i.e., the bias in Ederer II) will be propoprtional to the heterogeneity in expected survival. As such, performing the analysis within age groups will reduce the heterogeneity in expected survival and therefore the bias in in Ederer II [(Lambert et al 2015)](https://bmcmedresmethodol.biomedcentral.com/articles/10.1186/s12874-015-0057-3).

We see from the results below, that the Ederer II and Pohar Perme estimates are closer than they were when all ages were analysed in a single life table. The biggest differences are for the oldest age group, which is to be expected because the heterogeneity in expected survival is greater for that age group.  

```stata
. strs using popmort, breaks(0(.083333333)10) mergeby(_year sex _age) by(agegrp) ///
>      ht pohar list(n d cr_e2 cns_pp lo_cns_pp hi_cns_pp) notables save(replace)

[output omitted]

. use grouped, clear
(Collapsed (or grouped) survival data)

. list agegrp end n d cr_e2 cns_pp lo_cns_pp hi_cns_pp if floor(end)==end

     +------------------------------------------------------------------+
     | agegrp   end      n    d    cr_e2   cns_pp   lo_cns~p   hi_cns~p |
     |------------------------------------------------------------------|
 12. |   0-44     1    288    3   0.9618   0.9618     0.9315     0.9788 |
 24. |   0-44     2    254    0   0.8916   0.8916     0.8490     0.9227 |
 36. |   0-44     3    229    1   0.8498   0.8498     0.8016     0.8870 |
 48. |   0-44     4    207    1   0.8101   0.8101     0.7576     0.8523 |
 60. |   0-44     5    183    1   0.7797   0.7798     0.7242     0.8255 |
     |------------------------------------------------------------------|
 72. |   0-44     6    167    1   0.7555   0.7554     0.6973     0.8040 |
 84. |   0-44     7    149    0   0.7484   0.7483     0.6890     0.7980 |
 96. |   0-44     8    137    0   0.7410   0.7409     0.6803     0.7918 |
108. |   0-44     9    125    0   0.7271   0.7267     0.6640     0.7798 |
120. |   0-44    10    115    1   0.7179   0.7174     0.6528     0.7721 |
     |------------------------------------------------------------------|
132. |  45-59     1    947    3   0.9589   0.9589     0.9431     0.9704 |
144. |  45-59     2    850    5   0.9188   0.9188     0.8978     0.9356 |
156. |  45-59     3    739    6   0.8670   0.8670     0.8412     0.8889 |
168. |  45-59     4    647    1   0.8381   0.8382     0.8098     0.8628 |
180. |  45-59     5    586    4   0.8076   0.8078     0.7768     0.8350 |
     |------------------------------------------------------------------|
192. |  45-59     6    505    0   0.7803   0.7805     0.7472     0.8101 |
204. |  45-59     7    452    0   0.7704   0.7707     0.7357     0.8017 |
216. |  45-59     8    401    1   0.7464   0.7464     0.7089     0.7798 |
228. |  45-59     9    356    0   0.7512   0.7513     0.7127     0.7855 |
240. |  45-59    10    315    1   0.7512   0.7517     0.7116     0.7872 |
     |------------------------------------------------------------------|
252. |  60-74     1   2496   19   0.9386   0.9385     0.9265     0.9486 |
264. |  60-74     2   2118   12   0.8795   0.8791     0.8629     0.8935 |
276. |  60-74     3   1810   11   0.8367   0.8360     0.8170     0.8533 |
288. |  60-74     4   1546    8   0.8032   0.8025     0.7810     0.8221 |
300. |  60-74     5   1330   12   0.7713   0.7693     0.7454     0.7913 |
     |------------------------------------------------------------------|
312. |  60-74     6   1127    6   0.7377   0.7361     0.7098     0.7604 |
324. |  60-74     7    956    4   0.7177   0.7161     0.6874     0.7426 |
336. |  60-74     8    801    3   0.7122   0.7119     0.6808     0.7407 |
348. |  60-74     9    676    7   0.7015   0.7004     0.6660     0.7320 |
360. |  60-74    10    546    4   0.6885   0.6879     0.6497     0.7229 |
     |------------------------------------------------------------------|
372. |    75+     1   1835   19   0.8768   0.8758     0.8564     0.8927 |
384. |    75+     2   1459   17   0.8229   0.8212     0.7961     0.8436 |
396. |    75+     3   1172   14   0.7978   0.7978     0.7676     0.8245 |
408. |    75+     4    924   12   0.7757   0.7775     0.7416     0.8091 |
420. |    75+     5    736    6   0.7748   0.7812     0.7382     0.8180 |
     |------------------------------------------------------------------|
432. |    75+     6    568    9   0.7559   0.7565     0.7037     0.8012 |
444. |    75+     7    424    2   0.7195   0.7208     0.6596     0.7729 |
456. |    75+     8    328    5   0.7077   0.7117     0.6398     0.7718 |
468. |    75+     9    253    4   0.7102   0.7340     0.6463     0.8032 |
480. |    75+    10    197    3   0.7226   0.7470     0.6314     0.8311 |
     +------------------------------------------------------------------+
```
