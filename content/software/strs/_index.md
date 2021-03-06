+++
date = "2019-03-02"
title = "strs: estimating and modelling relative/net survival"
subtitle = "Paul Dickman, Enzo Coviello"
author = "Paul Dickman, Enzo Coviello"
summary = "This page describes the Stata `strs` command and related files for estimating and modelling relative and survival."
tags = ["strs","software","Stata"]
math = true
[header]
image = ""
caption = ""
+++

{{% toc %}}

## Introduction and features
This page describes the Stata `strs` command and related files for estimating and modelling relative and survival. This work is performed in collaboration with Enzo Coviello. Features include:

* Life table estimation of relative survival with 3 approaches for expected survival (Ederer I, Ederer II, or Hakulinen)
* [Pohar Perme estimator](https://doi.org/10.1111/j.1541-0420.2011.01640.x) of net survival
* Estimation using a cohort, period, or hybrid approach
* Standardisation (e.g., by age)
* Crude probabilities of death using the method of [Cronin and Feuer](https://www.ncbi.nlm.nih.gov/pubmed/10861774)
* Estimates are saved for modelling or easy tabular/graphical presentation

Sample data sets and do files with worked examples are provided with the package. Further details of the command can be found in our paper in [The Stata Journal](/pdf/Dickman2015.pdf).

## Installing and updating
The package can be installed by typing the following command at the Stata command prompt:

```stata
net install http://www.pauldickman.com/rsmodel/stata_colon/strs, all
```

The package can be updated using the Stata `adoupdate` command (from the Stata command line).

## Details

Sample do files are provided to reproduce the estimates reported in Table I of [Dickman et al (2004)](/pdf/Dickman2004.pdf)). Two input data files are provided; `colon.dta` contains the cancer patient data and `popmort.dta` contains data on expected probabilities of death for the corresponding general population.

Running `survival.do` produces life table estimates of relative survival stratified by sex, age, and calendar period of diagnosis. In addition, two output data sets are created (one containing grouped data and one containing individual patient data) which are used as input data for modelling. `models.do` contains code for modelling excess mortality using several different approaches (described in [Dickman et al (2004)](/pdf/Dickman2004.pdf))).

`strs` is the command for estimating relative survival (see the help file for details and `survival.do` for an example). Period estimation is illustrated in `survival_period.do`. The various approaches to modelling excess mortality are defined using ado files; `ht.ado` (Hakulinen-Tenkanen), `esteve.ado` (Estève et al.), and `rs.ado` (Poisson regression). An example of how to fit the models is provided in `models.do`.

## History

Version history can be found [here]({{< ref "/software/strs/history/history.md" >}}).

`strs` can be updated using the `adoupdate` command. 

## Suggested citation

If you use this package, please cite the associated paper in The [Stata Journal](/pdf/Dickman2015.pdf).

> Paul W. Dickman & Enzo Coviello, 2015. Estimating and modeling relative survival, The Stata Journal, StataCorp LP, vol. 15(1), pages 186-215.

## Examples
- [Illustration of the algorithm used by strs]({{< ref "/software/strs/life_table_algorithm.md" >}})
- [Life table estimation of relative survival (Ederer II) with strs]({{< ref "/software/strs/survival.md" >}})
- [Modelling excess mortality using Poisson regression]({{< ref "/software/strs/modelling_poisson.md" >}})
- [Brenner approach to age-standardisation (Pohar Perme estimator)]({{< ref "/software/strs/age_standardised_net_survival.md" >}})





