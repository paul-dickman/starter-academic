/*******************************************
create a dataset containing three variables,
X1, X2, and X3 which are random variables
from a standard normal distribution. The
value of X1 is missing with probability 5%.
X4 contains the values 0 and 1 with equal
frequency.
*******************************************/

data test;
do id=1 to 200;
x1=rannor(-1);
x2=rannor(-1);
x3=rannor(-1);
if ranuni(-1) le 0.05 then x1=.;
x4=mod(id,2);
output;
end;
run;

proc print;
run;

/******************************************
The output data set from PROC RANK contains
the variables containing the quantiles (with
names defined in the ranks statement) along
with all variables in the input data set.

If the input data set is large, you may want
to limit the variables in the output data
set to the id variable and the newly
created quintiles.

To construct quintiles, groups=5, must be
specified, otherwise the ranks (1,2,3,4,..)
are output.
*******************************************/
proc rank
     groups=5
     out=quint(keep=id x1q x2q x3q x4q);
var x1 x2 x3 x4;
ranks x1q x2q x3q x4q;
run;

/******************************************
Now we merge the dataset containing the
quintiles onto the main data set.
*******************************************/
data new;
merge test quint;
by id;
run;

/******************************************
Test to see what happened for X1 (missing).
*******************************************/
proc means data=new missing;
class x1q;
var x1;
run;

/******************************************
Test to see what happened for X4 (ties).
*******************************************/
proc means data=new missing;
class x4q;
var x4;
run;
