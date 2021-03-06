+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: Printing all variables for a single observation"
author = "Paul Dickman"
summary = "Printing all variables for a single observation"
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

It is not uncommon to want to examine all variables for a single
observation. That is, for data sets containing lots of variables, print
out the values for all variables on a single page. The following code will
achieve this:

```sas
proc fsbrowse data=hit.cases label printall;
run;
```

The LABEL option causes variable labels to be printed rather than
variable names. 


The number of observations can be restricted using a
WHERE statement and the number of variables can be restricted using the
VAR statement. For example:


```sas
proc fsbrowse data=hit.cases label
printall;
where sex=2;
var kon--ulorsak;
run;
```

It is also possible to invoke the procedure using the
FSBROWSE command. For example, type `fsbrowse hit.cases`
 in the command line and use the PageUp and PageDown keys
to scroll through the observations.


The 'FS' in FSBROWSE stands for full screen. A similar
procedure, PROC FSEDIT, allows editing of the SAS data set. It is possible
to create customised screens and data entry procedures which include error
checking.

## **Index**
- [Index of SAS tips and tricks](/sastips/)

