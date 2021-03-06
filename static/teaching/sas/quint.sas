/**********************************************************
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
* proc univariate noprint data=&dsn.(where=(control=1));  *
*                                                         *
* Paul Dickman (paul.dickman@mep.ki.se)                   *
* April 1999                                              *
**********************************************************/
%macro quint(dsn,var,quintvar);

/* calculate the cutpoints for the quintiles */
proc univariate noprint data=&dsn;
  var &var;
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
data &dsn;
set &dsn;
       if &var =. then &quintvar = .;
  else if &var le &q1 then &quintvar=1;
  else if &var le &q2 then &quintvar=2;
  else if &var le &q3 then &quintvar=3;
  else if &var le &q4 then &quintvar=4;
  else &quintvar=5;
run;

%mend quint;
