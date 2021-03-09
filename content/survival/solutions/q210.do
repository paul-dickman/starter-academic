
//==================//
// EXERCISE 210
// REVISED MAY 2015
//==================//

/*Read in the data and stset it*/
use melanoma if stage==1, clear
stset surv_mm, fail(status==1 2) id(id) scale(12)

/*Estimate relative survival for each combination of of the covariates*/
strs using popmort, br(0(1)10) mergeby(_year sex _age) by(sex year8594 agegrp) save(replace) notables

/*Restrict to first 5 years of follow-up*/
use grouped if end < 6, clear




/* Part a : Fit a main effects poisson regression model*/
glm d i.end i.sex i.year8594 i.agegrp, fam(pois) link(rs d_star) lnoff(y) eform
est store Grouped


/* Part b : see solutions to question 111 for, note that the data must be re-stset
  first*/
  
/* Part c*/

glm

/* Part d */
glm d i.sex i.year8594 i.end##i.agegrp, fam(pois) link(rs d_star) lnoff(y) eform
lrtest Grouped

/* Part e */

use individ if end < 6, clear
glm d i.end i.sex i.year8594 i.agegrp, fam(pois) link(rs d_star) lnoff(y) eform
est store Individual

est table Grouped Individual
 
/* Part f: Esteve */

ml model lf esteve (d=i.end i.sex i.year8594 i.agegrp)
ml maximize, eform("RER")
est store Esteve

/* Part g: Hakulinen-Tenkanen */
use grouped if end < 6, clear
glm ns i.end i.sex i.year8594 i.agegrp, fam(bin n_prime) link(ht p_star) eform
est store Hakulinen

est table Grouped Individual Esteve Hakulinen, eform equations(1) ///
b(%9.6f) modelwidth(10) title("Excess hazard ratios for various models")

/*Part h: */
use melanoma, clear
stset surv_mm, fail(status==1 2) id(id) scale(12)
strs using popmort, br(0(1)10) mergeby(_year sex _age) by(sex year8594 agegrp stage) save(replace) notables
use grouped if end < 6, clear

/* Part a : Fit a main effects poisson regression model*/
glm d i.end i.stage i.sex i.year8594 i.agegrp, fam(pois) link(rs d_star) lnoff(y) eform
est store Grouped
glm d i.end##i.stage i.sex i.year8594 i.agegrp, fam(pois) link(rs d_star) lnoff(y) eform
lrtest Grouped

glm d i.end i.end#i.stage i.sex i.year8594 i.agegrp, fam(pois) link(rs d_star) lnoff(y) eform

