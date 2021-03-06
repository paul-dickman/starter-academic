+++
date = "2019-03-02"
title = "Life table estimation of relative survival with strs"
summary = "Short tutorial illustrating how to estimate relative survival using -strs-."
tags = ["strs","software","Stata"]
external_link = "" 
math = false
[header]
image = ""
caption = ""
+++

We first load the colon cancer data (restricting to localised stage) and then use `stset` to declare the time at risk and event indicator.

```stata
. use colon if stage==1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. stset surv_mm, fail(status==1 2) id(id) scale(12)

                id:  id
     failure event:  status == 1 2
obs. time interval:  (surv_mm[_n-1], surv_mm]
 exit on or before:  failure
    t for analysis:  time/12

------------------------------------------------------------------------------
      6,274  total observations
          0  exclusions
------------------------------------------------------------------------------
      6,274  observations remaining, representing
      6,274  subjects
      3,291  failures in single-failure-per-subject data
  35,598.75  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =  20.95833
```

Survival times in completed months are stored in the variable `surv_mm`. The `scale(12)` option converts to years, as required by `strs`.

The variable `status` contains vital status, coded as follows:

| Code | Label                    |
| -----|------------------------- |
| 0    | Alive                    |
| 1    | Dead (colon cancer)      |
| 2    | Dead (other causes)      |
| 4    | Lost to follow-up        |

We specify codes 1 and 2 as events (`fail(status==1 2)`) as we wish to estimate all-cause survival, which we will then divide by expected survival to get relative survival. 

We now call `strs` to produce life tables for each sex. The `mergeby()` option specifies the variables upon which expected survival depends (i.e., the variables by which the popmort data is sorted). The `by(sex)` option specifies that we would like life tables for each sex. The `breaks(0(1)10)` option specifies the life table intervals; `0(1)10` is Stata shorthand for 'from 0 to 10 by 1'.

```stata
. strs using popmort, breaks(0(1)10) mergeby(_year sex _age) by(sex) save(replace)

         failure _d:  status == 1 2
   analysis time _t:  surv_mm/12
                 id:  id

No late entry detected - p is estimated using the actuarial method

----------------------------------------------------------------------------------------------------------------
-> sex = Male

  +------------------------------------------------------------------------------------------------------------+
  | start   end      n     d     w        p   p_star        r       cp    cp_e2    cr_e2   lo_cr_e2   hi_cr_e2 |
  |------------------------------------------------------------------------------------------------------------|
  |     0     1   2620   328     0   0.8748   0.9470   0.9238   0.8748   0.9470   0.9238     0.9098     0.9366 |
  |     1     2   2292   229   166   0.8963   0.9483   0.9452   0.7841   0.8980   0.8732     0.8549     0.8904 |
  |     2     3   1897   180   139   0.9015   0.9470   0.9519   0.7069   0.8504   0.8312     0.8097     0.8518 |
  |     3     4   1578   140   119   0.9078   0.9449   0.9607   0.6417   0.8036   0.7986     0.7742     0.8221 |
  |     4     5   1319   113   104   0.9108   0.9428   0.9660   0.5845   0.7576   0.7715     0.7444     0.7977 |
  |------------------------------------------------------------------------------------------------------------|
  |     5     6   1102   102    81   0.9039   0.9414   0.9601   0.5283   0.7132   0.7407     0.7110     0.7698 |
  |     6     7    919    71    71   0.9196   0.9409   0.9774   0.4859   0.6711   0.7239     0.6916     0.7557 |
  |     7     8    777    59    72   0.9204   0.9391   0.9800   0.4472   0.6303   0.7095     0.6745     0.7441 |
  |     8     9    646    49    62   0.9203   0.9380   0.9811   0.4115   0.5912   0.6961     0.6582     0.7337 |
  |     9    10    535    33    58   0.9348   0.9365   0.9981   0.3847   0.5537   0.6948     0.6538     0.7357 |
  +------------------------------------------------------------------------------------------------------------+

----------------------------------------------------------------------------------------------------------------
-> sex = Female

  +------------------------------------------------------------------------------------------------------------+
  | start   end      n     d     w        p   p_star        r       cp    cp_e2    cr_e2   lo_cr_e2   hi_cr_e2 |
  |------------------------------------------------------------------------------------------------------------|
  |     0     1   3654   423     1   0.8842   0.9585   0.9225   0.8842   0.9585   0.9225     0.9113     0.9329 |
  |     1     2   3230   313   203   0.9000   0.9590   0.9384   0.7958   0.9192   0.8657     0.8510     0.8797 |
  |     2     3   2714   216   178   0.9177   0.9572   0.9587   0.7303   0.8799   0.8300     0.8129     0.8463 |
  |     3     4   2320   171   194   0.9231   0.9545   0.9671   0.6741   0.8398   0.8027     0.7835     0.8211 |
  |     4     5   1955   134   135   0.9290   0.9526   0.9752   0.6262   0.8000   0.7828     0.7617     0.8032 |
  |------------------------------------------------------------------------------------------------------------|
  |     5     6   1686   131   139   0.9190   0.9503   0.9670   0.5755   0.7603   0.7569     0.7338     0.7796 |
  |     6     7   1416   109   128   0.9194   0.9477   0.9701   0.5291   0.7205   0.7343     0.7090     0.7591 |
  |     7     8   1179    73   103   0.9353   0.9460   0.9886   0.4948   0.6816   0.7260     0.6986     0.7529 |
  |     8     9   1003    53   102   0.9443   0.9437   1.0007   0.4673   0.6432   0.7265     0.6969     0.7557 |
  |     9    10    848    56    82   0.9306   0.9399   0.9901   0.4349   0.6046   0.7193     0.6871     0.7512 |
  +------------------------------------------------------------------------------------------------------------+
```
The life table quantities are as follows:
```stata 
n         Alive at start
d         Deaths during the interval
w         Withdrawals during the interval
p         Interval-specific observed survival
p_star    Interval-specific expected survival
r         Interval-specific relative survival
cp        Cumulative observed survival
cp_e2     Cumulative expected survival (Ederer II)
cr_e2     Cumulative relative survival (Ederer II)
``` 

We see that the five-year relative survival for males is `0.7715`, while for females it is `0.7828`.

