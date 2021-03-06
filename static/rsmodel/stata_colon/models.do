************************************************************************
* MODELS.DO
*
* Estimate various relative survival (excess mortality) models.
* The input data files are constructed using SURVIVAL.DO.
*
* INDIVID.DTA contains subject-band observations
* GROUPED.DTA contains collapsed data (i.e. life table rows) 
*
* Paul Dickman (paul.dickman@ki.se)
* Apr 2004 v 1.0
* Nov 2010 v 1.3.2 updated to Stata 11 syntax; added table of estimates
*
*************************************************************************

/********************************************************************* 
Fit the model using the full likelihood approach (Esteve approach)
The file esteve.ado must be somewhere Stata can find it.
(for example, in c:\ado\personal\)
***********************************************************************/
use individ if end < 6, clear
ml model lf esteve (d=i.end i.sex i.year8594 i.agegrp)
ml maximize, eform("EHR")
estimates store esteve

/********************************************************************* 
Fit the Poisson GLM to individual data
The file rs.ado must be somewhere Stata can find it.
(for example, in c:\ado\personal\)
***********************************************************************/
use individ if end < 6, clear
glm d i.end i.sex i.year8594 i.agegrp , fam(pois) link(rs d_star) lnoffset(y) eform
estimates stor individ

/*********************************************************************   
Fit the Poisson GLM using exact survival times (to collapsed data)   
***********************************************************************/
use grouped if end < 6, clear
glm d i.end i.sex i.year8594 i.agegrp , fam(pois) link(rs d_star) lnoffset(y) eform
estimates store grouped

/********************************************************************* 
Fit the Hakulinen-Tenkanen model
The file ht.ado must be somewhere Stata can find it.
(for example, in c:\ado\personal\)
***********************************************************************/
use grouped if end < 6, clear
glm ns i.end i.sex i.year8594 i.agegrp , fam(bin n_prime) link(ht p_star) eform
estimates store HT

/* Compare the estimates and SEs */
est table esteve individ grouped HT, eform equations(1) ///
se b(%7.4f) se(%7.4f) modelwidth(10) ///
title("Excess hazard ratios and standard errors for various models")

