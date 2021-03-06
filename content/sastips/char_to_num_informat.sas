data test;
length x $ 6;
input x;
y61=input(x,6.1);
best61=input(x,best6.1);
y60=input(x,6.0);
best60=input(x,best6.0);
cards;
.001
0.01
10
100
10.0
1E3
1.52E3
;

proc print;
run;
