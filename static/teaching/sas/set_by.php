<?PHP
$strPageStyle = 'main';
$strTitle = 'FIRST. and LAST. variables: Data step processing within by groups';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>If you use a by statement along with a set statement in a data step then SAS creates
    two automatic variables, FIRST.variable and LAST.variable, where variable is the name of
    the by variable.&nbsp; FIRST.variable has a value 1 for the first observation in the by
    group and 0 for all other observations in the by group. LAST.variable has a value 1 for
    the last observation in the by group and 0 for all other observations in the by group.</p>
    <p>The code shown below is available <a href="set_by.sas">here</a>.</p>
    <pre>data temp;
input group x;
cards;
1 23
1 34
1 .
1 45
2 78
2 92
2 45
2 89
2 34
2 76
3 31
4 23
4 12
;
run;


/**************************************************
The automatic variables first.group and last.group
are not saved with the data set. Here we write them
to data set variables to show their contents.
**************************************************/
data new;
set temp;
by group;
first=first.group;
last=last.group;
run;

proc print;
title 'Raw data along with first.group and last.group';
run;

/**************************************************
A common task in data cleaning is to identify
observations with a duplicate ID number. If we set
the data set by ID, then the observations which
are not duplicated will be both the first and the
last with that ID number. We can therefore write
any observations which are not both first.id and
last.id to a separate data set and examine them.
**************************************************/
data single dup;
set temp;
by group;
if first.group and last.group then output single;
else output dup;
run;

/**************************************************
We may also want to do data set processing within
each by group. In this example we construct the
cumulative sum of the variable X within each group.
**************************************************/
data cusum(keep=group sum);
set temp;
by group;
if first.group then sum=0;
sum+x;
if last.group then output;
run;

proc print data=cusum noobs;
title 'Sum of X within each group';
run;

/**************************************************
As an aside, if you simply want the sum of X within
each group, one of the many way of obtaining this
is with PROC PRINT.
**************************************************/
proc print data=temp;
title 'All data with X summed within each group';
by group;
sum x;
sumby group;
run;
</pre>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
