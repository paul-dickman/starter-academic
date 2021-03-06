
proc fsbrowse data=hit.cases(drop=pnr namn) label printall;
title 'Printout of the cancer registry records for all women diagnosed with ovarian cancer';
run;
