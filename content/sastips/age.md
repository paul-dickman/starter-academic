+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: Accurately calculating age in only one line"
author = "Paul Dickman"
summary = "Accurately calculating age in only one line"
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

<p>This SAS code was written by Billy Kreuter, who posted it to the SAS-L mailing list
several years ago. Billy authored an article
in SAS Communications (4th quarter 1998) which discusses this issue in greater detail.</p>
<p>The following code calculates age in completed years from the variables <em>birth</em>
and <em>somedate</em>.</p>
<pre>age = floor((intck('month',birth,somedate)
- (day(somedate) &lt; day(birth))) / 12); </pre>
<p>This can be conveniently set up as a macro: </p>
<pre>%macro age(date,birth);
floor ((intck('month',&amp;birth,&amp;date)
- (day(&amp;date) &lt; day(&amp;birth))) / 12) 
%mend age;</pre>
<p>The macro is used in a SAS DATA step as follows: </p>
<pre>age = %age(somedate,birth); </pre>
<p>For example, the following lines: </p>
<pre>age = %age('28aug1998'd,'24mar1955'd);
put age=; </pre>
<p>will cause the following message to be placed on the log: </p>
<pre>AGE=43 </pre>
<p>The approach is to first calculate the number of completed months between 
  the two dates and then divide by 12 and round down to get the number of 
  completed years. </p>
<p>The following code could be used to calculate the number of completed 
  months between the dates birth and somedate.</p>
<pre>months = intck('month',birth,somedate) 
   - (day(somedate) < day(birth));</pre>
<p>The first part of the code uses the intck function to calculate the number 
  of times a 'month boundary' (e.g from January to February) is crossed 
  between the two dates. Crossing a 'month boundary' does not necessarily 
  mean that a completed month has elapsed so a correction needs to be made 
  when the end date (somedate) is less than the start date (birth)..</p>
<p>To convert completed months to completed years one uses</p>
<pre>years=floor(months/12);</pre>
<p>The floor function simply rounds a real number down to the nearest integer, 
  for example floor(4.93)=4.</p>
<p>See also the notes on <a href="../age_dx/">Calculating age at diagnosis 
  from PNR and diagnosis date</a>.

## **Index**
- [Index of SAS tips and tricks](/sastips/)

