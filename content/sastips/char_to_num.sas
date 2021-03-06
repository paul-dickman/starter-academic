
data temp;
length char4 $ 4;
infile cards missover;
input numeric char4;

/* convert character to numeric */
new_num=input(char4,?? best4.);

/* convert numeric to character */
new_char=put(numeric,4.0);

output;
cards;
001
002   ww
789 1234
009 0009
1   9999
;;
run;

proc print;
run;
