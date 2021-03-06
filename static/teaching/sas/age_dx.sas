
data temp;
length pnr $ 11 dxdat $ 6;
input pnr dxdat;

/* convert the character variable
   to a SAS date variable */
didat2=input(dxdat,yymmdd.);

/* extract the birthdate from PNR */
birth=input(substr(pnr,2,6),yymmdd.);

age_dx=floor((intck('month',birth,didat2)
        - (day(didat2) < day(birth))) / 12);

format didat2 birth date.;

cards;
96511289999 990622
93404199999 590420
;;

proc print data=temp;
title 'Calculating age at diagnosis';
var pnr dxdat birth didat2 age_dx;
run;
