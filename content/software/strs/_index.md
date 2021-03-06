---
date: '2019-03-02'
title: strs - estimating and modelling relative/net survival
subtitle: Paul Dickman, Enzo Coviello
author: Paul Dickman, Enzo Coviello
summary: This page describes the Stata `strs` command and related files for estimating and modelling relative and survival.
tags: ["strs","software","Stata"]
math: true
copyright_license:
  enable: false
---

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
net install https://www.pauldickman.com/strs/strs, all
```
The package can be updated using the Stata `adoupdate` command (from the Stata command line).

{{% callout warning %}}
On 11 March 2021, the `strs` package was moved to a new directory on my server so older versions may need to be reinstalled rather than updated.  
{{% /callout %}}

## Details

Sample do files are provided to reproduce the estimates reported in Table I of [Dickman et al (2004)](/pdf/Dickman2004.pdf)). Two input data files are provided; `colon.dta` contains the cancer patient data and `popmort.dta` contains data on expected probabilities of death for the corresponding general population.

Running `survival.do` produces life table estimates of relative survival stratified by sex, age, and calendar period of diagnosis. In addition, two output data sets are created (one containing grouped data and one containing individual patient data) which are used as input data for modelling. `models.do` contains code for modelling excess mortality using several different approaches (described in [Dickman et al (2004)](/pdf/Dickman2004.pdf))).

`strs` is the command for estimating relative survival (see the help file for details and `survival.do` for an example). Period estimation is illustrated in `survival_period.do`. The various approaches to modelling excess mortality are defined using ado files; `ht.ado` (Hakulinen-Tenkanen), `esteve.ado` (Estève et al.), and `rs.ado` (Poisson regression). An example of how to fit the models is provided in `models.do`.

## History

Version history can be found [here](/software/strs/history/history/).

`strs` can be updated using the `adoupdate` command. 

## License

`strs` is licensed under [the GNU General Public License](https://www.gnu.org/licenses/gpl.html)

`strs` is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

`strs` is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See [the GNU General Public License](https://www.gnu.org/licenses/gpl.html) for more details.

## Suggested citation

If you use this package, please cite the associated paper in The [Stata Journal](/pdf/Dickman2015.pdf).

> Paul W. Dickman & Enzo Coviello, 2015. Estimating and modeling relative survival, The Stata Journal, StataCorp LP, vol. 15(1), pages 186-215.

## Examples
- [Illustration of the algorithm used by strs](/software/strs/life_table_algorithm/)
- [Life table estimation of relative survival (Ederer II) with strs](/software/strs/survival/)
- [Modelling excess mortality using Poisson regression](/software/strs/modelling_poisson/)
- [Brenner approach to age-standardisation (Pohar Perme estimator)](/software/strs/age_standardised_net_survival/)

## Extended index (with summary of each page)

