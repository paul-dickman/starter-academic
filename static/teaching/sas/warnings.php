<?PHP
$strPageStyle = 'main';
$strTitle = 'Customised notes and warnings in the SAS log';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>If you put a text string to the log which begins with 'ERROR:', 'WARNING:', or 'NOTE:',
    then SAS will format the text as an ERROR, WARNING, or NOTE respectively. That is the text
    will appear in the log file using the designated colour (red, green, and blue by default).</p>
    <p>This provides an efficient way performing and documenting data checking/cleaning.</p>
    <p>The SAS code shown below can be downloaded <a href="warnings.sas">here</a>.</p>
    <pre>/**************************************************
We read in some data and implement a check that
the start date occurs before the end date.
Note the use of informat and format.
**************************************************/
data temp;
input id start end;
informat start end ddmmyy6.;
format start end date8.;
if start gt end then
put 'ERROR: end before start: ' id= start= end= ;
cards;
1 281165 070599
2 230489 120193
3 011295 181089
4 020773 010399
;
run;

/**************************************************
When deleting observations or transforming variables
it if often useful to list the observations affected.
Note the syntax for specifying a constant date.
**************************************************/
data new;
set temp;
if start lt '01JAN70'd then do;
put 'WARNING: observation deleted: ' id= start= end= ;
delete;
end;
run;
</pre>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
