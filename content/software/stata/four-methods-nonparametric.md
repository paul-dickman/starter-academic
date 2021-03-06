+++
date = "2019-03-13"
title = "Non-parametric estimation of net survival with four approaches"
summary = "Estimation of relative/net survival using four difference approaches (Ederer I, Ederer II, Hakulinen, Pohar Perme)"
shortsummary = "" 
tags = ["strs","net survival","Stata","Pohar Perme"]
math = false
[header]
image = ""
caption = ""
+++

{{% callout note %}}
Under construction: Stata code and output is shown below. I plan to add additional comments. 
{{% /callout %}}

The code used in this tutorial, along with links to the data, is available [here](http://pauldickman.com/software/stata/four-methods-nonparametric.do).

```stata
. use http://pauldickman.com/data/colon.dta if stage == 1, clear
(Colon carcinoma, diagnosed 1975-94, follow-up to 1995)

. 
. stset exit, origin(dx) fail(status==1 2) id(id) scale(365.24)

                id:  id
     failure event:  status == 1 2
obs. time interval:  (exit[_n-1], exit]
 exit on or before:  failure
    t for analysis:  (time-origin)/365.24
            origin:  time dx

------------------------------------------------------------------------------
      6,274  total observations
          0  exclusions
------------------------------------------------------------------------------
      6,274  observations remaining, representing
      6,274  subjects
      3,291  failures in single-failure-per-subject data
 35,607.707  total analysis time at risk and under observation
                                                at risk from t =         0
                                     earliest observed entry t =         0
                                          last observed exit t =  20.96156

. gen long potfu = date("31/12/1995","DMY")

. strs using popmort, br(0(1)20) mergeby(_year sex _age) by(year8594) ///
>      list(start end n d w cr_e1 cr_e2 cr_hak cns_pp) pohar ederer1 potfu(potfu)

         failure _d:  status == 1 2
   analysis time _t:  (exit-origin)/365.24
             origin:  time dx
                 id:  id

No late entry detected - p is estimated using the actuarial method

------------------------------------------------------------------------------------------------------------
-> year8594 = Diagnosed 75-84

  +--------------------------------------------------------------------+
  | start   end      n     d     w    cr_e1    cr_e2   cr_hak   cns_pp |
  |--------------------------------------------------------------------|
  |     0     1   2557   339     1   0.9089   0.9089   0.9089   0.9064 |
  |     1     2   2217   253     0   0.8449   0.8425   0.8449   0.8401 |
  |     2     3   1964   176     1   0.8085   0.8039   0.8086   0.8032 |
  |     3     4   1787   154     0   0.7780   0.7720   0.7781   0.7734 |
  |     4     5   1633   129     0   0.7559   0.7489   0.7560   0.7527 |
  |--------------------------------------------------------------------|
  |     5     6   1504   129     1   0.7302   0.7229   0.7304   0.7259 |
  |     6     7   1374   114     0   0.7089   0.7014   0.7091   0.7015 |
  |     7     8   1260    86     0   0.7005   0.6921   0.7008   0.6947 |
  |     8     9   1174    67     0   0.7017   0.6925   0.7021   0.7073 |
  |     9    10   1107    75     0   0.6962   0.6868   0.6966   0.7065 |
  |--------------------------------------------------------------------|
  |    10    11   1032    67     0   0.6939   0.6844   0.6944   0.7112 |
  |    11    12    965    58   106   0.6937   0.6839   0.6939   0.7027 |
  |    12    13    801    51    87   0.6915   0.6814   0.6909   0.7018 |
  |    13    14    663    29   131   0.7042   0.6922   0.7025   0.7226 |
  |    14    15    503    27    97   0.7095   0.6966   0.7064   0.7431 |
  |--------------------------------------------------------------------|
  |    15    16    379    18    75   0.7208   0.7055   0.7157   0.7553 |
  |    16    17    286    20    63   0.7128   0.6971   0.7055   0.7549 |
  |    17    18    203    12    48   0.7146   0.7006   0.7045   0.7213 |
  |    18    19    143     5    47   0.7366   0.7248   0.7220   0.7616 |
  |    19    20     91    11    38   0.6719   0.6625   0.6544   0.7490 |
  +--------------------------------------------------------------------+

------------------------------------------------------------------------------------------------------------
-> year8594 = Diagnosed 85-94

  +--------------------------------------------------------------------+
  | start   end      n     d     w    cr_e1    cr_e2   cr_hak   cns_pp |
  |--------------------------------------------------------------------|
  |     0     1   3717   412     0   0.9328   0.9328   0.9328   0.9305 |
  |     1     2   3305   289   369   0.8897   0.8874   0.8896   0.8845 |
  |     2     3   2647   220   316   0.8540   0.8495   0.8541   0.8483 |
  |     3     4   2111   157   313   0.8285   0.8226   0.8291   0.8221 |
  |     4     5   1641   118   239   0.8075   0.8005   0.8086   0.8049 |
  |--------------------------------------------------------------------|
  |     5     6   1284   104   219   0.7791   0.7708   0.7804   0.7751 |
  |     6     7    961    66   199   0.7628   0.7534   0.7644   0.7569 |
  |     7     8    696    46   175   0.7493   0.7396   0.7513   0.7449 |
  |     8     9    475    35   164   0.7268   0.7174   0.7299   0.7175 |
  |     9    10    276    14   140   0.7226   0.7167   0.7297   0.7149 |
  |--------------------------------------------------------------------|
  |    10    11    122     8   114   0.6773   0.6800   0.6910   0.7175 |
  +--------------------------------------------------------------------+


. 
. /* Now with shorter intervals, don't show the tables as we will draw a graph */
. strs using popmort, br(0 0.01 0.25(0.25)10) mergeby(_year sex _age) by(year8594) ///
>      list(start end n d w cr_e1 cr_e2 cr_hak cns_pp) pohar ederer1 potfu(potfu) save(replace) notables

         failure _d:  status == 1 2
   analysis time _t:  (exit-origin)/365.24
             origin:  time dx
                 id:  id

No late entry detected - p is estimated using the actuarial method

.          
. /* Now graph the estimates */
. use grouped if year8594==0, clear
(Collapsed (or grouped) survival data)

. twoway ///
> (connected cr_e1 end, sort lwidth(medthick) msymbol(none) lpattern(dot)) ///
> (connected cr_e2 end, sort lwidth(medthick) msymbol(none) lpattern(shortdash)) ///
> (connected cr_hak end, sort lwidth(medthick) msymbol(none) lpattern(longdash)) ///
> (connected cns_pp end, sort lwidth(medthick) msymbol(none) lpattern(solid)), ///
> yti("Relative/net survival") yscale(range(0.6 1)) ///
> ylabel(0.6(0.1)1, format(%3.1f)) title("Localised colon carcinoma diagnosed 1975-84") ///
> xtitle("Years from diagnosis") xlabel(0(1)10) ysize(8) xsize(11) ///
> legend(order(1 "Ederer I" 2 "Ederer II" 3 "Hakulinen" 4 "Pohar Perme") ring(0) pos(1) col(1))
```

{{< figure src="/svg/four-methods-nonparametric.svg" title="Non-parametric estimates of net survival with four approaches" numbered="true" >}}
