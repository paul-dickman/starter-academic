data temp;
input  date yymmdd6.;
today='14sep99'd;
days=today-date;
yy=year(date);
dd=day(date);
cards;
310317
681224
651128
990914
;
run;

proc print;
format date weekdate.;
run;
