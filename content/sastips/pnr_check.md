+++
date = "1999-03-09"
lastmod = "2019-03-09"
title = "SAS Tips: Verifying the check digit in Swedish national ID numbers"
author = "Paul Dickman"
summary = "A desscription of how the check digit is calculated and a SAS macro for doing it."
shortsummary = "" 
tags = ["SAS","SAStips"]
+++

Swedish personal identification numbers (PNRs) comprise 10 digits (12 if century of
birth is included). The first 6 digits represent date of birth (YYMMDD), the ninth digit
represents gender (even for females and odd for males), and the tenth digit is a check
digit which can be constructed from the preceding nine digits.
SAS code for verifying PNRs is shown below. This code can be downloaded [here](pnr_check.sas).

### Algorithm for calculating the check digit

Consider the PNR 310317-099x. First multiply each of the first nine digits in the PNR by the digits 2,1,2,1,2,1,2,1,2 and calculate the cumulative sum of each of these 9 calculations. If the product results in a number greater than 10, then add the individual digits. For example, 9 times 2 = 18, so we add 9 (the sum of 1 and 8) to the cumulative sum in the example below.

<table border="1" width="78%">
  <tr>
    <td width="8%" align="right">3</td>
    <td width="8%" align="right">1</td>
    <td width="8%" align="right">0</td>
    <td width="8%" align="right">3</td>
    <td width="8%" align="right">1</td>
    <td width="8%" align="right">7</td>
    <td width="8%" align="right">0</td>
    <td width="8%" align="right">9</td>
    <td width="8%" align="right">9</td>
    <td width="8%" align="right">&nbsp;</td>
  </tr>
  <tr>
    <td width="8%" align="right">2</td>
    <td width="8%" align="right">1</td>
    <td width="8%" align="right">2</td>
    <td width="8%" align="right">1</td>
    <td width="8%" align="right">2</td>
    <td width="8%" align="right">1</td>
    <td width="8%" align="right">2</td>
    <td width="8%" align="right">1</td>
    <td width="8%" align="right">2</td>
    <td width="8%" align="right">&nbsp;</td>
  </tr>
  <tr>
    <td width="8%" align="right">6</td>
    <td width="8%" align="right">1</td>
    <td width="8%" align="right">0</td>
    <td width="8%" align="right">3</td>
    <td width="8%" align="right">2</td>
    <td width="8%" align="right">7</td>
    <td width="8%" align="right">0</td>
    <td width="8%" align="right">9</td>
    <td width="8%" align="right">18</td>
    <td width="8%" align="right">37</td>
  </tr>
</table>

In the example above, the cumulative sum is 37. The check digit is the number we would
have to add to the product sum in order to obtain a multiple of 10. In the above example,
we would need to add 3, so the check digit is 3. If the cumulative sum is a multiple of 10
then the check digit is 0.

### SAS code for verifying the check digit

```sas
/*******************************************
PNR_CHK.SAS
This code reads 10-digit person numbers and
checks that the check digit (the 10th digit
in the PNR) is correct.
It is assumed that PNR is a character
variable of length 10.

Paul Dickman (paul.dickman@ki.se)
September 1999
*******************************************/

/*******************
Read some test data
********************/
data temp;
input pnr $ 1-10;
cards;
3103170993
3103170999
6812241450
6812241457
;
run;

data pnr_chk;
set temp;
length product $ 18 result $ 3;
array two_one {9} (2 1 2 1 2 1 2 1 2);
/*********************************************
multiply each of the first 9 digits in PNR by
the corresponding digit in the array two_one
and concatenate the result.
The COMPRESS function removes blanks.
*********************************************/
do i = 1 to 9;
product=compress(product||(substr(pnr,i,1)
                         *two_one{i}));
end;

/** Now we sum the digits **/
do i = 1 to length(product);
sum=sum(sum,substr(product,i,1));
end;

/** extract the check digit from PNR **/
chk=substr(pnr,10,1);

/** calculate the correct check digit **/
corr_chk=mod(10-mod(sum,10),10);

if chk=corr_chk then result='ok';
else result='bad';
label
chk='Actual check number'
corr_chk='Correct check number'
pnr='Personnummer (10 digits)'
;
run;

proc print data=pnr_chk;
var pnr chk product sum corr_chk result;
run;
```

## Stata code for verifying the check digit
Nicola Orsini and colleagues have written a Stata program, PNRCHECK, for 
verifying the check digit which can be <a href="http://nicolaorsini.altervista.org/commands.htm">downloaded 
from Nicola's web site</a>.

## **Index**
- [Index of SAS tips and tricks](/sastips/)

 