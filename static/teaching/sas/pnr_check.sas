/*******************************************
PNR_CHK.SAS
This code reads 10-digit person numbers and
checks that the check digit (the 10th digit
in the PNR) is correct.
It is assumed that PNR is a character
variable of length 10.

Paul Dickman (paul.dickman@mep.ki.se)
September 1999
*******************************************/

/*******************
Read some test data
********************/
data temp;
input  pnr $ 1-10;
cards;
3103170993
3103170939
6812241450
6812241457
;
run;


data pnr_chk;
set temp;
length product $ 18 result $ 3;
array  two_one {9} (2 1 2 1 2 1 2 1 2);
/***********************************************
multiply each of the first 9 digits in PNR by
the corresponding digit in the array two_one
and concatenate the result.
************************************************/
do i = 1 to 9;
  product=compress(product||(substr(pnr,i,1)*two_one{i}));
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
