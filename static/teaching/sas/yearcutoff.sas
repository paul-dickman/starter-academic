options yearcutoff=1920;

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
