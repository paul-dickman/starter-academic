//Multi-state models practical solutions

//Question 1:

//(a)

//load the data
use bcdata.dta, clear

//find four patients with different profiles and list
list pid rf rfi os osi age size nodes pr if pid==1417 | pid==2765 | pid==435 | pid==955

/*
      +------------------------------------------------------------------------+
      |  pid      rf   rfi      os        osi   age        size   nodes     pr |
      |------------------------------------------------------------------------|
   8. | 1417    97.9     1    98.2      alive    40     <=20 mm       0      0 |
  42. | 2765    35.4     1    50.5   deceased    26   >20-50mmm       0    401 |
 114. |  435   103.9     0   106.2   deceased    66   >20-50mmm       0   2596 |
 116. |  955   146.0     0   146.0      alive    62   >20-50mmm       0     59 |
      +------------------------------------------------------------------------+
*/

//(b)
su age
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
         age |      2,982    55.05835    12.95299         24         90
*/
tab size
/*
     Tumour |
    size, 3 |
classes (t) |      Freq.     Percent        Cum.
------------+-----------------------------------
    <=20 mm |      1,387       46.51       46.51
  >20-50mmm |      1,291       43.29       89.81
     >50 mm |        304       10.19      100.00
------------+-----------------------------------
      Total |      2,982      100.00
*/
su nodes
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
       nodes |      2,982    2.712274    4.383844          0         34
*/
hist nodes
centile nodes
/*
                                                       -- Binom. Interp. --
    Variable |       Obs  Percentile    Centile        [95% Conf. Interval]
-------------+-------------------------------------------------------------
       nodes |     2,982         50           1               1           1
*/
su pr
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
          pr |      2,982    161.8313    291.3111          0       5004
*/
hist pr
//highly skewed, so we explore the log(pr+1) transformation stored in in pr_1
su pr

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
          pr |      2,982    161.8313    291.3111          0       5004

su pr_1
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        pr_1 |      2,982    3.426186     2.23544          0   8.518193
*/
hist pr_1

tab hormon
/*
   Hormonal |
    therapy |      Freq.     Percent        Cum.
------------+-----------------------------------
         no |      2,643       88.63       88.63
        yes |        339       11.37      100.00
------------+-----------------------------------
      Total |      2,982      100.00
*/

//(c) Create a transition matrix for an illness-death process
matrix define tmat = (.,1,2\.,.,3\.,.,.)
mat list tmat
/*
tmat[3,3]
    c1  c2  c3
r1   .   1   2
r2   .   .   3
r3   .   .   .
*/

//(d) msset the data
msset, id(pid) transmatrix(tmat) states(rfi osi) times(rf os)

tab _trans1 _status
/*
tab _trans1 _status

           |  Event (transition)
  _trans== |       indicator
    1.0000 |         0          1 |     Total
-----------+----------------------+----------
         0 |     3,228      1,272 |     4,500 
         1 |     1,464      1,518 |     2,982 
-----------+----------------------+----------
     Total |     4,692      2,790 |     7,482 
*/
tab _trans2 _status
/*

           |  Event (transition)
  _trans== |       indicator
    2.0000 |         0          1 |     Total
-----------+----------------------+----------
         0 |     1,905      2,595 |     4,500 
         1 |     2,787        195 |     2,982 
-----------+----------------------+----------
     Total |     4,692      2,790 |     7,482 
*/
tab _trans3 _status
/*
           |  Event (transition)
  _trans== |       indicator
    3.0000 |         0          1 |     Total
-----------+----------------------+----------
         0 |     4,251      1,713 |     5,964 
         1 |       441      1,077 |     1,518 
-----------+----------------------+----------
     Total |     4,692      2,790 |     7,482 
*/

//Compare with r(freqmatrix) returned after msset
mat list r(freqmatrix)
/*
r(freqmatrix)[3,3]
      c1    c2    c3
r1     0  1518   195
r2     0     0  1077
r3     0     0     0
*/
//There were 1518 transitions from state 1 to 2, 195 transitions from state 1 to 3, and 1077 transitions from state 2 to 3.

//(e) declare the data to be survival data
stset _stop, enter(_start) failure(_status==1) scale(12) 
/*
     failure event:  _status == 1
obs. time interval:  (0, _stop]
 enter on or after:  time _start
 exit on or before:  failure
    t for analysis:  time/12

------------------------------------------------------------------------------
       7482  total observations
          0  exclusions
------------------------------------------------------------------------------
       7482  observations remaining, representing
       2790  failures in single-record/single-failure data
  38474.539  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =  19.28268
*/

list pid rf rfi os osi _t0 _t _d _st _trans if pid==1417 | pid==2765 | pid==435 | pid==955, sepby(pid) noobs
/*
  +-----------------------------------------------------------------------------------+
  |  pid      rf   rfi      os        osi         _t0          _t   _d   _st   _trans |
  |-----------------------------------------------------------------------------------|
  |  435   103.9     0   106.2   deceased           0   8.8459956    0     1        1 |
  |  435   103.9     0   106.2   deceased           0   8.8459956    1     1        2 |
  |-----------------------------------------------------------------------------------|
  |  955   146.0     0   146.0      alive           0   12.167009    0     1        1 |
  |  955   146.0     0   146.0      alive           0   12.167009    0     1        2 |
  |-----------------------------------------------------------------------------------|
  | 1417    97.9     1    98.2      alive           0   8.1615334    1     1        1 |
  | 1417    97.9     1    98.2      alive           0   8.1615334    0     1        2 |
  | 1417    97.9     1    98.2      alive   8.1615334   8.1806984    0     1        3 |
  |-----------------------------------------------------------------------------------|
  | 2765    35.4     1    50.5   deceased           0   2.9486653    1     1        1 |
  | 2765    35.4     1    50.5   deceased           0   2.9486653    0     1        2 |
  | 2765    35.4     1    50.5   deceased   2.9486653   4.2080768    1     1        3 |
  +-----------------------------------------------------------------------------------+
*/

//Question 2: Analysis

//(a) Fit a weibull proportional transitions model
// I assume transition 1 is the reference group
streg _trans2 _trans3, dist(weibull)
/*
Weibull regression -- log relative-hazard form 

No. of subjects =        7,482                  Number of obs    =       7,482
No. of failures =        2,790
Time at risk    =  38474.53852
                                                LR chi2(2)       =     2701.63
Log likelihood  =   -5725.5272                  Prob > chi2      =      0.0000

------------------------------------------------------------------------------
          _t | Haz. Ratio   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
     _trans2 |   .1284585   .0097721   -26.98   0.000      .110665     .149113
     _trans3 |   3.234194   .1347826    28.17   0.000     2.980526    3.509452
       _cons |   .1111983   .0047299   -51.64   0.000     .1023038    .1208661
-------------+----------------------------------------------------------------
       /ln_p |  -.1248857   .0197188    -6.33   0.000    -.1635337   -.0862376
-------------+----------------------------------------------------------------
           p |   .8825978   .0174037                      .8491379    .9173763
         1/p |   1.133019   .0223417                      1.090065    1.177665
------------------------------------------------------------------------------
*/
//The underlying event rate from post-surgery to death is substantially lower than the 
//rate from post-surgery to relapse. The event rate from post-surgery to death is 
//substantially higher (3.23 times) than post-surgery to relapse.

//(b) fit a stratified Weibull model
streg _trans2 _trans3, dist(weibull) ancillary(_trans2 _trans3)
/*
Weibull regression -- log relative-hazard form 

No. of subjects =        7,482                  Number of obs    =       7,482
No. of failures =        2,790
Time at risk    =  38474.53852
                                                LR chi2(2)       =      935.32
Log likelihood  =   -5656.1627                  Prob > chi2      =      0.0000

------------------------------------------------------------------------------
          _t |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
_t           |
     _trans2 |  -3.168605   .2013437   -15.74   0.000    -3.563232   -2.773979
     _trans3 |   2.352642   .1522638    15.45   0.000      2.05421    2.651073
       _cons |  -2.256615   .0477455   -47.26   0.000    -2.350194   -2.163035
-------------+----------------------------------------------------------------
ln_p         |
     _trans2 |   .4686402    .063075     7.43   0.000     .3450155     .592265
     _trans3 |  -.6043193    .087695    -6.89   0.000    -.7761984   -.4324403
       _cons |  -.0906001   .0224852    -4.03   0.000    -.1346702   -.0465299
------------------------------------------------------------------------------
*/
//There is statistically significiant evidence against the null of no difference between the shape parameters of transition1, and transitions 2 and 3.

//(c)
streg age _trans2 _trans3, dist(weibull) ancillary(_trans2 _trans3)
/*
Weibull regression -- log relative-hazard form 

No. of subjects =        7,482                  Number of obs    =       7,482
No. of failures =        2,790
Time at risk    =  38474.53852
                                                LR chi2(3)       =      968.10
Log likelihood  =   -5639.7693                  Prob > chi2      =      0.0000

------------------------------------------------------------------------------
          _t |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
_t           |
         age |   .0085662   .0014941     5.73   0.000     .0056379    .0114946
     _trans2 |  -3.173808   .2017164   -15.73   0.000    -3.569165   -2.778451
     _trans3 |   2.324363   .1505177    15.44   0.000     2.029354    2.619373
       _cons |    -2.7353   .0971366   -28.16   0.000    -2.925684   -2.544916
-------------+----------------------------------------------------------------
ln_p         |
     _trans2 |   .4697586   .0630304     7.45   0.000     .3462214    .5932959
     _trans3 |  -.5827026   .0858211    -6.79   0.000    -.7509089   -.4144963
       _cons |  -.0873818   .0224793    -3.89   0.000    -.1314404   -.0433231
------------------------------------------------------------------------------
*/
gen age1 = age * _trans1
gen age2 = age * _trans2
gen age3 = age * _trans3
streg age1 age2 age3 _trans2 _trans3, dist(weibull) ancillary(_trans2 _trans3)
/*
Weibull regression -- log relative-hazard form 

No. of subjects =        7,482                  Number of obs    =       7,482
No. of failures =        2,790
Time at risk    =  38474.53852
                                                LR chi2(5)       =     1314.91
Log likelihood  =   -5466.3633                  Prob > chi2      =      0.0000

------------------------------------------------------------------------------
          _t |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
_t           |
        age1 |  -.0021734    .002071    -1.05   0.294    -.0062325    .0018857
        age2 |   .1289129   .0078069    16.51   0.000     .1136116    .1442142
        age3 |   .0063063   .0023447     2.69   0.007     .0017107    .0109019
     _trans2 |  -11.78602    .623599   -18.90   0.000    -13.00825   -10.56379
     _trans3 |   1.861322   .2348573     7.93   0.000      1.40101    2.321634
       _cons |   -2.13714   .1230997   -17.36   0.000    -2.378411   -1.895869
-------------+----------------------------------------------------------------
ln_p         |
     _trans2 |   .5773103   .0617153     9.35   0.000     .4563505    .6982701
     _trans3 |   -.585393   .0865301    -6.77   0.000    -.7549889    -.415797
       _cons |  -.0913214   .0224979    -4.06   0.000    -.1354165   -.0472262
------------------------------------------------------------------------------
*/

//(d) There is no "right" or "wrong" answer to this. Covariates ideally should be included
//on clinical grounds. Model selection criteria can also be used as a guide.
//Here is an example assuming covariate effects are shared across transitions.

tab size, gen(sz)
streg age sz2 sz3 nodes pr_1 hormon _trans2 _trans3, dist(weibull) anc(_trans2 _trans3)
/*
Weibull regression -- log relative-hazard form 

No. of subjects =        7,482                  Number of obs    =       7,482
No. of failures =        2,790
Time at risk    =  38474.53852
                                                LR chi2(8)       =     1447.74
Log likelihood  =   -5399.9501                  Prob > chi2      =      0.0000

------------------------------------------------------------------------------
          _t |      Coef.   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
_t           |
         age |   .0057077   .0015244     3.74   0.000     .0027199    .0086955
         sz2 |   .3093331   .0433666     7.13   0.000     .2243362    .3943301
         sz3 |   .5512543   .0630247     8.75   0.000     .4277283    .6747804
       nodes |   .0556569   .0035249    15.79   0.000     .0487483    .0625655
        pr_1 |  -.0625563   .0085625    -7.31   0.000    -.0793385   -.0457741
      hormon |    .008858   .0601825     0.15   0.883    -.1090976    .1268135
     _trans2 |  -3.167934   .1996567   -15.87   0.000    -3.559254   -2.776614
     _trans3 |    1.61072   .1323433    12.17   0.000     1.351332    1.870109
       _cons |  -2.773123   .1033154   -26.84   0.000    -2.975618   -2.570629
-------------+----------------------------------------------------------------
ln_p         |
     _trans2 |   .4564874   .0608312     7.50   0.000     .3372605    .5757143
     _trans3 |  -.2929238   .0640362    -4.57   0.000    -.4184324   -.1674152
       _cons |  -.0390461   .0219133    -1.78   0.075    -.0819953    .0039032
------------------------------------------------------------------------------
*/


//Question 3: Transition probabilities

//(a)
cap drop prob_*
predictms , transmat(tmat) trans1(age 50 hormon 1) trans2(_trans2 1 age 50 hormon 1) ///
	trans3(_trans3 1 age 50 hormon 1) graph

//(b)
cap drop prob_*
predictms , transmat(tmat) trans1(age 50) trans2(_trans2 1 age 50) ///
	trans3(_trans3 1 age 50) graph graphopts(name(g1,replace) title("Aged=50, tumour <=20mm"))

cap drop prob_*
predictms , transmat(tmat) trans1(age 50 sz3 1) trans2(_trans2 1 age 50 sz3 1) ///
	trans3(_trans3 1 age 50 sz3 1) graph graphopts(name(g2,replace) title("Aged=50, tumour > 50mm"))

graph combine g1 g2

//The detrimental influence of a larger tumuor size at baseline has greatly increased the probability of dying, over time.


//(c)
cap drop prob_*
predictms , transmat(tmat) trans1(age 50 sz3 1) trans2(_trans2 1 age 50 sz3 1) ///
	trans3(_trans3 1 age 50 sz3 1) 


//Question 4

//(a) 
streg age sz2 sz3 nodes pr_1 hormon if _trans1==1, dist(weibull) 
est store m1
streg age sz2 sz3 nodes pr_1 hormon if _trans2==1, dist(weibull) 
est store m2
streg age sz2 sz3 nodes pr_1 hormon if _trans3==1, dist(weibull) 
est store m3

//(b)
cap drop prob_*
predictms , transmat(tmat) model1(m1) model2(m2) model3(m3)  ///
	at(age 50 hormon 1) graph 

//(c)
cap drop prob_*
predictms , transmat(tmat) model1(m1) model2(m2) model3(m3)  ///
	at(age 50 hormon 1 sz3 1)  graph

//(d)
cap drop prob_*
predictms , transmat(tmat) model1(m1) model2(m2) model3(m3)  ///
	at(age 50 hormon 1) at2(age 50 hormon 1 sz3 1) ci
	
forvalues i=1/3 {
	twoway (rarea prob_1_`i'_lci prob_1_`i'_uci  _time, col(ltblue))(line prob_1_`i' _time)	///
	, name(g`i',replace) title("State `i'") legend(off) ylabel(-0.4(0.2)0.4)	///
	ylabel(,angle(h) format(%2.1f))
}
graph combine g1 g2 g3, xcommon ycommon rows(1) title("Prob(Size <=20 mm) - Prob(Size >50mmm)")

cap drop prob_*
predictms , transmat(tmat) model1(m1) model2(m2) model3(m3)  ///
	at(age 50 hormon 1) at2(age 50 hormon 1 sz3 1) ci ratio
	
forvalues i=1/3 {
	twoway (rarea prob_1_`i'_lci prob_1_`i'_uci  _time, col(ltblue))(line prob_1_`i' _time)	///
	, name(g`i',replace) title("State `i'") legend(off) ///
	ylabel(0(1)6,angle(h) format(%2.1f))
}
graph combine g1 g2 g3, xcommon ycommon rows(1) title("Prob(Size <=20 mm) / Prob(Size >50mmm)")





