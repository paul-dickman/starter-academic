<?PHP
$strPageStyle = 'main';
$strTitle = 'SAS Formats and Informats';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>An informat is a specification for how raw data should be read. A format is a layout
    specification for how a variable should be printed or displayed.</p>
    <p>SAS contains many internal formats and informats, or user defined formats and informats
    can be constructed using PROC FORMAT. To see a list of all internal formats and informats,
    type <font face="Courier New">'help format</font>' in the command line and then click on <font face="Courier New">'SAS Formats and Informats</font>' in the resulting window.</p>
    <p>The following code shows how SAS informats can be used:</p>
    <pre>input  @1 pnr       10.
       @11 sex       1.
       @12 surname  $15
       @27 diadate  yymmdd6.
; </pre>
    <p>Formats are much more widely used in our department then informats.</p>
    <p>The following code shows how a user-defined format can be created.</p>
    <pre>proc format;
value sex
1,3,5,7,9='Male'
0,2,4,6,8='Female'
;</pre>
    <p>The code above only creates the format, it does not associate it with any variable.
    Formats can be associated with variables in either data steps or proc steps.</p>
    <p>Assume we create a SAS data set in a data step, and include the following line in the
    data step.</p>
    <pre>format bmi 6.2 sex sex.;</pre>
    <p>We have applied the SAS system format 6.2 to the variable bmi and the user-defined
    format sex to the variable sex. Whenever we display information from this data set (using
    PROC FREQ or PROC PRINT, for example) bmi will always be rounded to 2 decimal places and
    sex will be displayed according to the given format. Note that applying a format does not
    affect the value of the variable. BMI will still be stored using many significant digits
    and sex will be stored as an integer between 0 and 9.</p>
    <p>We can also specify formats in individual proc steps, which override the default format
    (if a default format exists). We could, for example, use the following code, which would
    produce a listing of the actual values of the variable sex.</p>
    <pre>proc freq;
tables sex;
format sex 2.;
run; </pre>
    <p>If we did not assign formats to the variables bmi or sex in a data step, we can assign
    them is a proc step, in which case the formats are only used within that proc step. For
    example:</p>
    <pre>proc freq;
tables sex bmi;
format bmi 6.2 sex sex.;
run;</pre>
    <p>Any calculations made using a variable in a data step will be based on the raw data
    (i.e. the format is ignored). When fitting statistical models, however, the model is
    fitted to the formatted value.</p>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
