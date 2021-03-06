+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: Missing values"
author = "Paul Dickman"
summary = "Overview of the types of missing values (numeric, character, special) and their sort order"
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

<p>Numeric missing values are represented by a single period (.).</p>
<p>Character missing values are represented by a single blank enclosed in quotes (' ').</p>
<p>Special numeric missing values are represented by a single period followed by a single
letter or an underscore (for example .A, .S, .Z, ._).</p>
<h3>Special missing values</h3>
<p>These are only available for numeric variables and are used for distinguishing between
different types of missing values.</p>
<p>Responses to a questionnaire, for example, could be missing for one of several reasons
(Refused, illness, Dead, not home). By using special missing values, each of these can be
tabulated separately, but the variables are still treated as missing by SAS in data
analysis.</p>    

```sas
data survey;
missing A I R;
input id q1;
cards;
8401 2
8402 A
8403 1
8404 1
8405 2
8406 3
8407 A
8408 1
8408 R
8410 2
;

proc format;
value q1f
.A='Not home'
.R='Refused'
;
run;

proc freq data=survey;
table q1 / missprint;
format q1 q1f.;
run;
```
<h3>Sort order for missing values</h3>
<p>There is a serious logic error in the following code:</p>
```sas  
if age &lt; 20 then agecat=1;
else if age &lt; 50 then agecat=2;
else if age ge 50 then agecat=3;
else if age=. then agecat=9;
```
Since missing values are considered smaller than all numbers, records with age=. will be coded to agecat=1.
    <table border="1" cellspacing="1" width="80%">
      <tr>
        <td width="20%" align="center"><strong>Sort order</strong></td>
        <td width="18%" align="center"><strong>Symbol</strong></td>
        <td width="62%"><strong>Description</strong></td>
      </tr>
      <tr>
        <td width="20%" align="center">smallest</td>
        <td width="18%" align="center">_</td>
        <td width="62%">underscore</td>
      </tr>
      <tr>
        <td width="20%" align="center"> </td>
        <td width="18%" align="center">.</td>
        <td width="62%">period</td>
      </tr>
      <tr>
        <td width="20%" align="center"> </td>
        <td width="18%" align="center">A-Z</td>
        <td width="62%">special missing values A (smallest) through Z (largest)</td>
      </tr>
      <tr>
        <td width="20%" align="center"> </td>
        <td width="18%" align="center">-n</td>
        <td width="62%">negative numbers</td>
      </tr>
      <tr>
        <td width="20%" align="center"> </td>
        <td width="18%" align="center">0</td>
        <td width="62%">zero</td>
      </tr>
      <tr>
        <td width="20%" align="center">largest</td>
        <td width="18%" align="center">+n</td>
        <td width="62%">positive numbers</td>
      </tr>
    </table>
<h3>Working with missing values</h3>
<p>When transforming or creating SAS variables, the first part of the code should deal
with the case where variables are missing.</p>
    <pre>if age=. then agecat=.;
else if age &lt; 20 then agecat=1;
else if age &lt; 50 then agecat=2;
else agecat=3;</pre>
    <p>SAS version 8 introduced a new function, MISSING, that accepts either a character or numeric variable as the argument and returns the value 1 if the argument contains a missing value or zero otherwise. As such, the code above can be improved as follows:</p>
    <pre>if missing(age) then agecat=.;
else if age &lt; 20 then agecat=1;
else if age &lt; 50 then agecat=2;
else agecat=3;</pre>
    <p>The MISSING function is particularly useful if  you use special missing values since  <font face="Courier New">'if age=.</font>'
    will not identify all missing values in such cases.</p>
    <p>Note that the result of any operation on missing values will return a missing value. In
</p>
<pre>total=q1+q2+q3+q4+q5+q6;</pre>
<p>An alternative is to use:</p>
<pre>total=sum(of q1-q6);</pre>
<p>in which missing values are assumed to be zero.</p>
<p>Even if you think that a variable should not contain any missing values, you should
always write your code under the assumption that there may be missing values.</p>

## **Index**
- [Index of SAS tips and tricks](/sastips/)

