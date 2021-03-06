<?PHP
$strPageStyle = 'main';
$strTitle = 'Categorising a continuous variable into quantiles';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>Exposure variables in nutritional epidemiology are often categorised into quantiles
    (e.g. quintiles or quartiles). This page demonstrates some of the many methods of
    categorising continuous variables into quantiles. Examples show grouping into quintiles (5
    groups). <ul>
      <li><a href="#Using PROC RANK">Using PROC RANK, which is the most efficient method</a></li>
      <li><a href="#Using PROC UNIVARIATE">Using PROC UNIVARIATE, which is less efficient but more
        flexible</a></li>
      <li><a href="#macro">The PROC UNIVARIATE method as a macro</a></li>
    </ul>
    <p>&nbsp;</p>
    <h2><a name="Using PROC RANK">Using PROC RANK</a></h2>
    <p>This is the most efficient method for grouping many variables into quantiles
    (quintiles, quartiles, deciles, etc.). </p>
    <p>This method cannot, however, be used if you want to, for example, categorise the cases
    based on the distribution of the controls, for which the PROC UNIVARIATE method must be
    used.&nbsp; </p>
    <p>We first create a sample data set containing 3 continuous variables, X1, X2, and X3,
    which we would like to group into quintiles. The SAS code can be downloaded <a href="quint_rank.sas">here</a>.</p>
    <pre>/*******************************************
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

</pre>
    <p>The formula used to calculate the quantile rank of a value is <br>
    <br>
    FLOOR ( rank*k/(n+1) )<br>
    <br>
    where rank is the value's rank, k is the number of groups specified with the GROUPS=
    option, and n is the number of observations having nonmissing values of the ranking
    variable.</p>
    <p>Note that this means that when grouping variables into quintiles, the groups will be
    assigned values 0,1,2,3, and 4.</p>
    <p>In the presence of ties, the default behaviour if that each value is assigned the same
    rank, which is given by the mean of the corresponding ranks. As such, tied values are
    always assigned to the same quantile. In the example above, the 100 observations where
    X4=0 were assigned to group 1 and the the 100 observations where X4=1 were assigned to
    group 3.</p>
    <p>The handling of tied observations can be controlled using the TIES= option. </p>
    <h2><a name="Using PROC UNIVARIATE">Using PROC UNIVARIATE</a></h2>
    <p>The following SAS code demonstrates a more general method which uses PROC UNIVARIATE to
    calculate the cutpoints. This method is useful if you, for example, want the extreme
    categories to contain 10% of the data but the middle quantiles to contain 20% each. This
    method can also be used if you want to, for example, categorise the cases based on the
    distribution of the controls.</p>
    <p>The SAS code can be downloaded <a href="quint_examp1.sas">here</a>. The code is also
    given <a href="#macro">below</a> as a SAS macro.</p>
    <pre>/* create a dataset with one variable, X, 
which takes values 1 to 99 plus two obs
with missing values */
data test;
do x=1 to 100;
output;
end;
x=.;
output; output;
run;

/* create the cutpoints for the quintiles */
proc univariate noprint data=test;
var x;
output out=quintile pctlpts=20 40 60 80 pctlpre=pct;
run;

/* write the cutpoints to macro variables */
data _null_;
set quintile;
call symput('q1',pct20) ;
call symput('q2',pct40) ;
call symput('q3',pct60) ;
call symput('q4',pct80) ;
run;

/* create a new variable containing the quintiles */
data test;
set test;
if x =. then x_quint = .;
else if x &lt;= &amp;q1 then x_quint=1;
else if x &lt;= &amp;q2 then x_quint=2;
else if x &lt;= &amp;q3 then x_quint=3;
else if x &lt;= &amp;q4 then x_quint=4;
else x_quint=5;
run;


/* test to make sure it worked */
proc means data=test missing;
class x_quint;
var x;
run;</pre>
    <h2><a name="macro"></a>A SAS macro for categorising a continuous variable into quintiles</h2>
    <p>The macro can be downloaded <a href="quint.sas">here</a>.</p>
    <pre>/**********************************************************
* Macro for grouping continuous variable into quintiles.  *
* The macro requires three input variables:               *
* dsn: data set name                                      *
* var: variable to be categorised                         *
* quintvar: name of the new variable to be created        *
*                                                         *
* Sample usage:                                           *
* %quint(mydata.project,meat,meat_q);                     *
*                                                         *
* After running the macro, the dataset mydata.project     *
* will contain a new variable called meat_q with values   *
* . (missing), 1, 2, 3, 4, and 5.                         *
*                                                         *
* The cutpoints for the quintiles are calculated based    *
* on all non-missing values of the variable in question.  *
*                                                         *
* To base the cutpoints for the quintiles on, for example,*
* controls only, the code can be changed as follows:      *
* proc univariate noprint data=&amp;dsn.(where=(control=1));  *
*                                                         *
* Paul Dickman (paul.dickman@mep.ki.se)                   *
* April 1999                                              *
**********************************************************/
%macro quint(dsn,var,quintvar);

/* calculate the cutpoints for the quintiles */
proc univariate noprint data=&amp;dsn;
  var &amp;var;
  output out=quintile pctlpts=20 40 60 80 pctlpre=pct;
run;

/* write the quintiles to macro variables */
data _null_;
set quintile;
call symput('q1',pct20) ;
call symput('q2',pct40) ;
call symput('q3',pct60) ;
call symput('q4',pct80) ;
run;

/* create the new variable in the main dataset */
data &amp;dsn;
set &amp;dsn;
       if &amp;var =. then &amp;quintvar = .;
  else if &amp;var le &amp;q1 then &amp;quintvar=1;
  else if &amp;var le &amp;q2 then &amp;quintvar=2;
  else if &amp;var le &amp;q3 then &amp;quintvar=3;
  else if &amp;var le &amp;q4 then &amp;quintvar=4;
  else &amp;quintvar=5;
run;

%mend quint;</pre>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
