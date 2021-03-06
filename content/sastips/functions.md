+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: SAS sample statistic functions"
author = "Paul Dickman"
summary = "SAS sample statistic functions"
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

You should be familiar with <a href="/sastips/variable_lists/">'variable
lists'</a> before reading this page.

Sample statistics for a single variable across all observations are
simple to obtain using, for example, PROC MEANS, PROC UNIVARIATE, etc. The
simplest method to obtain similar statistics across several variables
within an observation is with a 'sample statistics function'.

For example:


`sum_wt=sum(of weight1 weight2 weight3 weight4 weight5);`


Note that this is equivalent to


`sum_wt=sum(of weight1-weight5);`


but is not equivalent to


`sum_wt=weight1 + weight2 + weight3 + weight4 + weight5;`


since the SUM function returns the sum of non-missing arguments,
whereas the '+' operator returns a missing value if any of the arguments
are missing.


The following are all valid arguments for the SUM function:

<font face="Courier New">sum(of variable1-variablen)</font> where n is an
integer greater than 1

<font face="Courier New">sum(of x y z)

sum(of array-name{*})

sum(of _numeric_)

sum(of x--a)</font> where x precedes a in the PDV order


A comma delimited list is also a valid argument, for example:

<font face="Courier New">sum(x, y, z)</font>


However, I recommend always using an argument preceded by OF, since
this minimises the chance that you write something like

<font face="Courier New">sum_wt=sum(weight1-weight5);</font>


which is a valid SAS expression, but evaluates to the difference
between weight1 and weight5.


Other useful sample statistic functions are:


MAX(argument,...) returns the largest value



MIN(argument,...) returns the smallest value



MEAN(argument,...) returns the arithmetic mean (average)



N(argument,....) returns the number of nonmissing arguments



NMISS(argument,...) returns the number of missing values



STD(argument,...) returns the standard deviation



STDERR(argument,...) returns the standard error of the mean



VAR(argument,...) returns the variance


<b>Example usage</b>

You may, for example, have collected weekly test scores over a 20 week
period and wish to calculate the average score for all observations with
the proviso that a maximum of 2 scores may be missing.


```sas
if nmiss(of test1-test20) le 2 then
 testmean=mean(of test1-test20);
else testmean=.;`
```

<b>References</b>

Function arguments: SAS Language, version 6, first edition, pages 50-51.


Functions: SAS Language, version 6, first edition, chapter 11, page
521.


Type 'help functions' in the command line to access the online help.


## **Index**
- [Index of SAS tips and tricks](/sastips/)


