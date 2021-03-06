+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: permanent format catalogues"
author = "Paul Dickman"
summary = "SAS permanent format catalogues"
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

<p align="left"><b>Temporary vs permanent SAS data sets</b> </p>
<p>Permanent SAS data sets can be created by specifying a two-level dataset name. </p>
<p>The following code creates the temporary SAS data set called PAUL (or WORK.PAUL):</p> 

```sas
data paul
...
run;
```

The following code creates the permanent SAS data set called PROJECT.PAUL:

```sas
data project.paul
...
run;
```

<p align="left"><b>Permanent format catalogues</b> </p>
<p>Formats created using PROC FORMAT are stored in format catalogues. By default, the
format catalogue is stored in the work directory and deleted at the end of the SAS session
(along with temporary data sets). </p>
<p>Permanent format catalogues are created using the library= option in PROC FORMAT. </p>

The following code creates the a permanent format catalogue in the library PROJECT:

```sas
proc format library=project;
value smoke
.='missing'
1='current smoker'
2='former smoker'
3='never smoked'
;
run;
```

<p>But how do we tell SAS where to look for the format? </p>
<p align="left"><b>The FMTSEARCH= system option</b> </p>
<p>This option was introduced in version 6.08?, so is not documented in the SAS Language
manual. </p>
<p>The online help provides the following information: </p>
<p>FMTSEARCH = (libref-1 libref-2... libref-n) </p>
<p>The FMTSEARCH= system option controls the order in which format catalogs are searched.
If the FMTSEARCH= option is specified, format catalogs are searched in the order listed,
until the desired member is found. </p>
<p>The WORK.FORMATS catalog is always searched first, unless it appears in the FMTSEARCH
list. The LIBRARY.FORMATS catalog is searched after WORK.FORMATS and before anything else
in the FMTSEARCH list, unless it appears in the FMTSEARCH list. </p>
<p>example usage: <tt>options fmtsearch=(book finsurv cancer);</tt> </p>
<p>SAS will search for formats in the following catalogues (in order): WORK, LIBRARY,
BOOK, FINSURV, CANCER. </p>

<b>Suggested usage</b>

1. Define libnames and the FMTSEARCH= option in <tt>autoexec.sas</tt>. 
2. Create a SAS file called FORMATS.SAS which contains the PROC FORMAT code.

Sample code to be included in AUTOEXEC.SAS:

```sas
libname project 'c:\project';
options fmtsearch=(project);
```

Sample code to be included in FORMATS.SAS:

```sas
/* delete the existing catalogue */
proc datasets library=project memtype=(catalog);
delete formats / memtype=catalog;
run;

proc format library=project;
value smoke
.='missing'
1='current smoker'
2='former smoker'
3='never smoked'
;
run;
```

<p>The code to delete the existing catalogue is optional. </p>
<p>The guidelines being developed by the analysis group for documenting and storing data
files on the server will require that formats be specified in this manner in a file called
FORMATS.SAS. </p>
<p align="left"><b>Sample SAS code (one.sas)</b> </p>

```sas
libname project 'c:\temp';

options fmtsearch=(project);

proc format library=project;
value smoke
.='missing'
1='current smoker'
2='former smoker'
3='never smoked'
;
run;

data project.paul;
do i=1 to 300;
smoke=mod(floor(100*ranuni(-1)),3)+1;
expose=ranuni(-1)&lt;0.5;
disease=ranuni(-1)&lt;0.2;
age=ranbin(-5,150,0.3);
output;
end;
drop i;
label
smoke='Smoking status'
expose='Exposure status'
disease='Disease status'
age='Age in years'
;
run;

proc freq;
tables smoke;
format smoke smoke.;
run;
```

## **Index**
- [Index of SAS tips and tricks](/sastips/)

