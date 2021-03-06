+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: Working with dates"
author = "Paul Dickman"
summary = "About SAS date values, reading dates, converting character or numeric variables to SAS date variables."
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

<p>From its inception, the SAS System has stored date values as an offset in days from
January 1, 1960. Leap years, century, and fourth-century adjustments are made
automatically. Leap seconds are ignored, and the SAS System does not adjust for daylight
saving time. This method of date representation means that calculations and comparisons of
SAS date values will produce correct results, regardless of century.</p>
<p>SAS users can convert external data to or from SAS date values by the use of various
informats, formats, and functions.</p>
<h3>Reading raw data into SAS date variables</h3>
<p>Raw data can be read into SAS date variables using the appropriate informat. For
example:</p>
<pre>data temp;
input date yymmdd6.;
cards;
310317
681224
651128
990914
;
run;</pre>
<p>If you want to be able to understand printouts of these dates, it is necessary to
assign an appropriate format to the variable. For example:</p>
<pre>format date yymmdd6.;</pre>
<h3>Converting character or numeric variables to SAS date variables</h3>
<p>This can be done using the INPUT function. The following code extracts date of birth
from PNR and writes it out as a SAS date variable (click <a href="/sastips/age_dx/">here</a>
for a complete example):</p>
<pre>birth=input(substr(pnr,2,6),yymmdd.);</pre>
<p>If the values of year, month, and day are stored in separate variables, these can be
written to a single SAS date variable using the MDY function:</p>
<pre>sasdate=mdy(month, day, year);</pre>
<h3>Two-digit years (the YEARCUTOFF= option)</h3>
<p>SAS date informats, formats, and functions all accept two-digit years as well as
four-digit years. If the dates in your external data sources contain four-digit years,
then the SAS System will accept and display those four-digit years without any difficulty
as long as you choose the appropriate informat and format. </p>
<p>If dates in your external data sources or SAS program statements contain two-digit
years, you can specify the century prefix assigned to them by using the YEARCUTOFF= system
option. The YEARCUTOFF= option specifies the first year of the 100-year span that is used
to determine the century of a two-digit year. The default value of YEARCUTOFF in version
6.12 is 1900, implying that all two-digit years are assumed to be in the 1900's. If you
are working with a study where the last date of follow-up is 1992, but some individuals in
your study were born in the late 1800's, you may wish to set the YEARCUTOFF option to
1893. This would lead to SAS interpreting values for year between 93 and 99 as being in
the 1800's.</p>
<p>Let's consider an example of reading in dates with both two-digit and&nbsp; four-digit
years. Note that in this example the YEARCUTOFF= option has been set to 1920. (the code
can be downloaded <a href="../yearcutoff.sas">here</a>)</p>
<pre>options yearcutoff=1920;

data schedule;
input @1 rawdata $8. @1 date yymmdd8.;
cards;
651128
19651128
18230314
19131225
131225
run;

proc print;
format date yymmdd10.;
run;
  
<b>OUTPUT FROM PROC PRINT</b>  

OBS    RAWDATA           DATE

 1     651128      1965-11-28
 2     19651128    1965-11-28
 3     18230314    1823-03-14
 4     19131225    1913-12-25
 5     131225      2013-12-25</pre>
<p>Note that the dates in observations 1 and 2 are the same (a two-digit date of 65
defaults to 1965), but the dates in observations 4 and 5 are different (a two-digit date
of 13 defaults to 2013).</p>

## **Index**
- [Index of SAS tips and tricks](/sastips/)


