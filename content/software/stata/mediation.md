+++
date = "2019-07-01"
title = "Mediation analysis with survival data"
summary = "We will partition the total effect of sex into the natural indirect effect (mediated by stage) and the natural direct effect. We then illustrate how to estimate the proportion of the sex difference mediated by stage. Emphasis is on illustrating how these quantities can be estimated in Stata using the standsurv command; we won't discuss the neccessary assumptions and their appropriateness.   "
shortsummary = "" 
tags = ["stpm2","standsurv","Stata","mediation"]
math = true
[header]
image = ""
caption = ""
+++

The page contains links to code illustrating mediation analysis.

We use an example where interest is in sex difference in cause-specific survival of patients with melanoma, with focus on the extent to which the sex differences are mediated by stage. We partition the total effect of sex into the natural indirect effect (mediated by stage) and the natural direct effect. We then illustrate how to estimate the proportion of the sex difference mediated by stage. Emphasis is on illustrating how these quantities can be estimated in Stata using the standsurv command; we won't discuss the neccessary assumptions and their appropriateness.   

* [Link to Stata code using predict, meansurv](/software/stata/mediation_meansurv.do)
* [Link to Stata code using standsurv](/software/stata/mediation_standsurv.do)

Estimation is basedon a fitted flexible parametric model. The `predict, meansurv` postestimation command was developed by Paul Lambert for regression standardisation. `standsurv`, also developed by Paul Lambert, is more recent, more powerful, and more general. At the time of writing it is still under development and available from [Paul Lambert's web page](https://pclambert.net/software/standsurv/) rather than SSC.
