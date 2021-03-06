+++
title = 'Estimating and modelling relative survival using SAS'
date = '2019-03-01'
tags = ["software", "SAS"]
+++

This page describes SAS (version 7) code I made public in 2004. I was a heavy SAS user in the 1980s and 1990s, but from the turn of the century I moved to Stata. This code has not been updated (other than to correct an error) and reflects the methods used at the time it was published. It facilitates life table estimation of relative survival (Ederer II) and modelling using the approaches available at the time (e.g., Poisson regression). Both cohort and period approaches are supported. I have programmed the more recent developments in Stata. 

A sample data set (colon cancer) is provided. All required data and SAS files can be downloaded in a [ZIP archive](/software/sas/sas_colon.zip). Documentation is provided in the file [readme.pdf](/software/sas/readme.pdf) in the ZIP archive. Additional files can be found [here](http://pauldickman.com/survival/?dir=sas).

If the contents of the ZIP archive are extracted to the directory c:\rsmodel\sas_colon\ then the code should run without requiring alteration. The code provided will reproduce the estimates reported in Table I of the paper [Dickman et al (2004)](/pdf/Dickman2004.pdf)). Two data files are provided; colon.sas7bdat contains the cancer patient data and popmort.sas7bdat contains data on expected probabilities of death for the comparable general population.

The SAS code in survival.sas produces life table estimates of relative survival stratified by sex, age, and calendar period of diagnosis. In addition, two output data sets are created (one containing grouped data and one containing individual patient data) which are used as input data sets for modelling. The SAS code in models.sas estimates a relative survival regression model using several different approaches (described in [Dickman et al (2004)](/pdf/Dickman2004.pdf)).

**Version History**

20040619 Version 1.0

20101025 Version 1.1 (only change is to survival_period.sas)

Summary: Standard errors for period analysis were not correct and have now been corrected.
Details: I have traditionally used the actuarial approach to estimate survival and used Greenwood's method for estimating standard errors. However, for period analysis (implemented in `survival_period.sas`) I estimated survival by transforming the estimated cumulative hazard. Unfortunately standard errors were still based on Greenwood's method using an incorrect value of the effective number at risk. Note that there is no problem with Greenwood's method per se, just that I didn't calculate the effective number at risk correctly since I wasn't using it to estimate survival. I've now used the appropriate method for calculating the standard error. Technical details can be found in [this document](../expected.pdf), which described the Stata implementation. Output from SAS, using both the v1.0 and v1.1 code can be found [here](../standard_errors_period_example.pdf).



