/*******************************************
PRENATAL.SAS
Artificial data from a prenatal clinic.
Used to demonstrate the use of arrays.
id - ID number
week - gestational week of visit
weight - weight of mother
hb - hemoglobin

Paul Dickman (paul.dickman@mep.ki.se)
November 1999
*******************************************/

title;

data prenatal;
infile cards missover;
input id / week1-week10 / weight1-weight10;
cards;
1
9  16 27 31 39
76 77 80 999 84
120 118 110 115 119
2
15 28 37
80 83 88
95 94 95
;;
run;

proc print data=prenatal;
run;
