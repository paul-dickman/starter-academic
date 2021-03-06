/*****************************************************************
MODELS.SAS (Requires SAS version 8 or higher)

Relative survival regression models fitted to
Colon carcinoma diagnosed in Finland 1975-1994 (follow-up to 1995).

The following approaches to fitting the model are used:
1. Grouped data, Binomial error structure (Hakulinen-Tenkanen model)
2. Grouped data, Poisson error structure
3. Exact survival times, Poisson GLM fitted to collapsed data
4. Exact survival times, Poisson GLM fitted to individual level data
5. Exact survival times, full likelihood (Esteve approach)

Reproduces the results from Table I in:
Dickman PW, Sloggett A, Hills M, Hakulinen T. Regression models for
relative survival. Statistics in Medicine 2004;23:51-64.

http://www.pauldickman.com/rsmodel/

Paul Dickman (paul.dickman@meb.ki.se)
Version 1.0 - June 2004
*****************************************************************/

title1 'Colon carcinoma diagnosed in Finland 1975-1994 (follow-up to 1995)';

libname colon 'c:\coursetemp\sas\';
options fmtsearch=(colon work library) orientation=portrait;

/* Data file containing individual records */
%let individ=colon.individ ;

/* Data file containing collapsed data */
%let grouped=colon.grouped ;

/*************************************************************************
Grouped survival times
Binomial error structure (Hakulinen-Tenkanen)
This approach should not be used for modelling period estimates
**************************************************************************/
ods output parameterestimates=parmest /* parameter estimates */
           modelinfo=modelinfo        /* Model information */
           modelfit=modelfit          /* Model fit information */
           convergencestatus=converge /* Whether the model converged */
           type3=type3estimates;      /* Type III estimates */

proc genmod data=&grouped(where=(fu le 5)) order=formatted;
title2 'Binomial error model fitted to grouped data [model 1 in Dickman et al. (2004)]';
title3 'Main effects model (follow-up, sex, age, and dgnyear)';
fwdlink link = log(-log(_mean_/p_star));
invlink ilink = exp(-exp(_xbeta_))*p_star;
class fu sex age yydx;
model ns/l_prime = fu sex yydx age / error=bin type3;
format fu fu. age age. yydx yydx.;
run;

ods output close;

data parmest;
set parmest;
if df gt 0 then do;
rer=exp(estimate);
low_rer=exp(estimate-1.96*stderr);
hi_rer=exp(estimate+1.96*stderr);
end;
run;

proc print data=parmest label noobs;
title4 'Estimates for beta and relative excess risks (RER=exp(beta))';
    id parameter; by parameter notsorted;
    var level1 estimate stderr rer low_rer hi_rer;
    format estimate stderr rer low_rer hi_rer 6.3;
    label
        parameter='Parameter'
        level1='Level'
        estimate='Estimate'
        stderr='Standard Error'
        rer='Estimated RER'
        low_rer='Lower limit 95% CI'
        hi_rer='Upper limit 95% CI';
run;

/*************************************************************************
Grouped survival times
Poisson error structure
**************************************************************************/
ods output parameterestimates=parmest /* parameter estimates */
           modelinfo=modelinfo        /* Model information */
           modelfit=modelfit          /* Model fit information */
           convergencestatus=converge /* Whether the model converged */
           type3=type3estimates;      /* Type III estimates */

proc genmod data=&grouped(where=(fu le 5)) order=formatted;
title2 'Poisson error model fitted to grouped data (person-time approximated)  [model 2 in Dickman et al. (2004)]';
title3 'Main effects model (follow-up, sex, age, and dgnyear)';
fwdlink link = log(_MEAN_-d_star_group);
invlink ilink= exp(_XBETA_)+d_star_group;
class fu sex age yydx;
model d = fu sex yydx age / error=poisson offset=ln_y_group type3;
format fu fu. age age. yydx yydx.;
run;

ods output close;

data parmest;
set parmest;
if df gt 0 then do;
rer=exp(estimate);
low_rer=exp(estimate-1.96*stderr);
hi_rer=exp(estimate+1.96*stderr);
end;
run;

proc print data=parmest label noobs;
title4 'Estimates for beta and relative excess risks (RER=exp(beta))';
    id parameter; by parameter notsorted;
    var level1 estimate stderr rer low_rer hi_rer;
    format estimate stderr rer low_rer hi_rer 6.3;
    label
        parameter='Parameter'
        level1='Level'
        estimate='Estimate'
        stderr='Standard Error'
        rer='Estimated RER'
        low_rer='Lower limit 95% CI'
        hi_rer='Upper limit 95% CI';
run;

/*****************************************************************************
Exact survival times
Poisson error structure fitted to individual level data
******************************************************************************/

ods output parameterestimates=parmest /* parameter estimates */
           modelinfo=modelinfo        /* Model information */
           modelfit=modelfit          /* Model fit information */
           convergencestatus=converge /* Whether the model converged */
           type3=type3estimates;      /* Type III estimates */

proc genmod data=&individ(where=(fu le 5)) order=formatted;
title2 'Regression model with a Poisson error structure fitted to individual data  [model 3 in Dickman et al. (2004)]';
title3 'Main effects model (follow-up, sex, age, and dgnyear)';
fwdlink link = log(_MEAN_-d_star);
invlink ilink= exp(_XBETA_)+d_star;
class fu sex age yydx;
model d = fu sex yydx age / error=poisson offset=ln_y type3;
format fu fu. age age. yydx yydx.;
run;

ods output close;

data parmest;
set parmest;
if df gt 0 then do;
rer=exp(estimate);
low_rer=exp(estimate-1.96*stderr);
hi_rer=exp(estimate+1.96*stderr);
end;
run;

proc print data=parmest label noobs;
title4 'Estimates for beta and relative excess risks (RER=exp(beta))';
    id parameter; by parameter notsorted;
    var level1 estimate stderr rer low_rer hi_rer;
    format estimate stderr rer low_rer hi_rer 6.3;
    label
        parameter='Parameter'
        level1='Level'
        estimate='Estimate'
        stderr='Standard Error'
        rer='Estimated RER'
        low_rer='Lower limit 95% CI'
        hi_rer='Upper limit 95% CI';
run;

/*************************************************************************
Exact survival times
Poisson error structure fitted to collapsed data
**************************************************************************/
ods output parameterestimates=parmest /* parameter estimates */
           modelinfo=modelinfo        /* Model information */
           modelfit=modelfit          /* Model fit information */
           convergencestatus=converge /* Whether the model converged */
           type3=type3estimates;      /* Type III estimates */

proc genmod data=&grouped(where=(fu le 5)) order=formatted;
title2 'Poisson error model fitted to collapsed data (based on exact survival times)  [model 4 in Dickman et al. (2004)]';
title3 'Main effects model (follow-up, sex, age, and dgnyear)';
fwdlink link = log(_MEAN_-d_star);
invlink ilink= exp(_XBETA_)+d_star;
class fu sex age yydx;
model d = fu sex yydx age  / error=poisson offset=ln_y type3;
format fu fu. age age. yydx yydx.;
run;

ods output close;

data parmest;
set parmest;
if df gt 0 then do;
rer=exp(estimate);
low_rer=exp(estimate-1.96*stderr);
hi_rer=exp(estimate+1.96*stderr);
end;
run;

proc print data=parmest label noobs;
title4 'Estimates for beta and relative excess risks (RER=exp(beta))';
    id parameter; by parameter notsorted;
    var level1 estimate stderr rer low_rer hi_rer;
    format estimate stderr rer low_rer hi_rer 6.3;
    label
        parameter='Parameter'
        level1='Level'
        estimate='Estimate'
        stderr='Standard Error'
        rer='Estimated RER'
        low_rer='Lower limit 95% CI'
        hi_rer='Upper limit 95% CI';
run;

/*****************************************************************************
Full likelihood estimation from individual data (Esteve approach).
We use PROC NLP (part of SAS/OR) to maximise the likelihood.
We first need to create dummy variables in a data step. 
******************************************************************************/
proc datasets library=work memtype=data kill nodetails nolist nowarn; quit;

data nlp_data;
set &individ(where=(fu le 5));
length default=3;
** make indicator variables for year of dx 1985-94 **;
year8594=(yydx ge 85);
** make indicator variables for age **;
age_gr1=0; age_gr2=0; age_gr3=0; age_gr4=0;
if age=. then put 'ERROR: Age is missing ' _n_= ;
else if age le 44 then age_gr1=1;
else if age le 59 then age_gr2=1;
else if age le 74 then age_gr3=1;
else if age le 99 then age_gr4=1;
else put 'ERROR: Age out of range ' _n_= age= ;
** make indicator variables for follow-up **;
fu2=(fu=2);fu3=(fu=3);fu4=(fu=4);fu5=(fu=5);
** Recode sex to 1=female, 0=male **;
sex2=sex-1;
drop sex age fu;
run;

ods output parameterestimates(match_all)=par_est;

proc nlp data=nlp_data cov=2 vardef=n;
title2 'Full likelihood estimation from individual data (Esteve approach) [model 3 in Dickman et al. (2004)]';
max loglike;
parms int fu_2-fu_5 female year2 age2-age4;
theta = int+fu_2*fu2+fu_3*fu3+fu_4*fu4+fu_5*fu5+year2*year8594
        +age2*age_gr2+age3*age_gr3+age4*age_gr4+female*sex2;
loglike = d*log(-log(p_star)+exp(theta))-exp(theta)*y;
run;

ods output close;

data parmest;
set par_est1;
rer=exp(estimate);
low_rer=exp(estimate-1.96*appstderr);
hi_rer=exp(estimate+1.96*appstderr);
run;

proc print data=parmest label noobs;
title4 'Estimates for beta and relative excess risks (RER=exp(beta))';
    id parameter; by parameter notsorted;
    var estimate appstderr rer low_rer hi_rer;
    format estimate appstderr rer low_rer hi_rer 6.3;
    label
        parameter='Parameter'
        estimate='Estimate'
        appstderr='Standard Error'
        rer='Estimated RER'
        low_rer='Lower limit 95% CI'
        hi_rer='Upper limit 95% CI';
run;

title; footnote;
