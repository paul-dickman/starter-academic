<?PHP
$strPageStyle = 'main';
$strTitle = 'Using PROC GENMOD for logistic regression (SAS version 6)';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

      <p>Note that these notes refer to version 6 of the SAS system. In version 
        8 it is preferable to use PROC LOGISTIC for logistic regression. See the 
        notes <a href="sas_logistic_seminar8.pdf">Logistic regression in SAS version 
        8</a>.</p>
      <p><a href="genmod1.doc">Download</a> the handout from seminar I (MS Word 
        format).</p>
    <p><a href="bronch.sas">Download</a> the SAS code from seminar II (a .SAS file).</p>
    <p>PROC GENMOD is a procedure which was introduced in SAS version 6.09 (approximately
    1993) for fitting generalised linear models. Generalised linear models include classical
    linear models with normal errors, logistic and probit models for binary data, and
    log-linear and Poisson regression models for count data. <br>
    <br>
    PROC GENMOD uses a class statement for specifying categorical (classification) variables,
    so indicator variables do not have to be constructed in advance, as is the case with, for
    example, PROC LOGISTIC. Interactions can be fitted by specifying, for example, age*sex.
    The response variable or the explanatory variable can be character (see the example
    below), while PROC LOGISTIC requires explanatory variables to be numeric.<br>
    <br>
    Another advantage of the class statement is that by using the TYPE3 option on the model
    statement, PROC GENMOD will automatically report likelihood ratio test statistics for the
    effect of each term in the model. For a categorical variable with k levels, the test will
    be based on (k-1) degrees of freedom.<br>
    <br>
    By default, PROC GENMOD uses a corner point parameterisation for categorical variables
    where the last category of each variable is used as the reference category. One method for
    specifying a reference category is to define a format for the variable using a space as
    the first character of the formatted value for all categories except the reference
    category and specifying the order=formatted option in PROC GENMOD. Since a space is sorted
    before all other characters, GENMOD will use the desired category as the reference. <br>
    <br>
    PROC GENMOD is documented in SAS/STAT Software: Changes and Enhancements through Release
    6.12. </p>
    <pre>data file1;
input year $ dose $ reject $ count;
cards;
&lt;1973 &lt;3.0 yes 4
&lt;1973 &gt;=3.0 yes 2
&lt;1973 &lt;3.0 no 9
&lt;1973 &gt;=3.0 no 16
1973+ &lt;3.0 yes 13
1973+ &gt;=3.0 yes 2
1973+ &lt;3.0 no 10
1973+ &gt;=3.0 no 12
;
run;


/* Fit a logistic regression model using PROC GENMOD */
proc genmod;
class dose year;
freq count;
model reject = dose year / error=bin link=logit type3;
make 'parmest' out=parmest;
run;


/*
PROC GENMOD does not report the odds ratio
directly, only the estimated betas (log odds ratios), 
but we can exponentiate these in a data step to 
get estimated odds ratios*/

data parmest;
set parmest;
if df gt 0;
or=exp(estimate);
low_or=exp(estimate-1.96*stderr);
hi_or=exp(estimate+1.96*stderr);
run;

proc print data=parmest label noobs;
title2 'Estimated odds ratios and 95% CIs';
var parm level1 estimate stderr or low_or hi_or;
format estimate stderr or low_or hi_or 6.3;
label
parm='Parameter'
level1='Level'
estimate='Beta estimate'
stderr='Standard Error'
or='Estimated OR'
low_or='Lower limit 95% CI'
hi_or='Upper limit 95% CI'
;
run;</pre>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
