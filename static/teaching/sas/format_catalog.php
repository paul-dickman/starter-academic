<?PHP
$strPageStyle = 'main';
$strTitle = 'SAS permanent format catalogues';
require ('config.php');
require ('header.php');
require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p align="left"><b>Temporary vs permanent SAS data sets</b> </p>
    <p>Permanent SAS data sets can be created by specifying a two-level dataset name. </p>
    <p>The following code creates the temporary SAS data set called PAUL (or WORK.PAUL): <br>
    <span class="sascode">data paul<br>
    ...<br>
    run;<br>
    </span></p>
    <p>The following code creates the permanent SAS data set called PROJECT.PAUL:<br>
    <span class="sascode">data project.paul<br>
    ...<br>
    run;<br>
    </span></p>
    <p align="left"><b>Permanent format catalogues</b> </p>
    <p>Formats created using PROC FORMAT are stored in format catalogues. By default, the
    format catalogue is stored in the work directory and deleted at the end of the SAS session
    (along with temporary data sets). </p>
    <p>Permanent format catalogues are created using the library= option in PROC FORMAT. </p>
    <p>The following code creates the a permanent format catalogue in the library PROJECT:<br>
    <span class="sascode">proc format library=project;<br>
    value smoke<br>
    .='missing'<br>
    1='current smoker'<br>
    2='former smoker'<br>
    3='never smoked'<br>
    ;<br>
    run;<br>
    </span></p>
    <p>But how do we tell SAS where to look for the format? </p>
    <p align="left"><b>The FMTSEARCH= system option</b> </p>
    <p>This option was introduced in version 6.08?, so is not documented in the SAS Language
    manual. </p>
    <p>The online help provides the following information: </p>
    <p>FMTSEARCH = (libref-1 libref-2... libref-n) </p>
    <p>The FMTSEARCH= system option controls the order in which format catalogs are searched.
    If the FMTSEARCH= option is specified, format catalogs are searched in the order listed,
    until the desired member is found. </p>
    <p>The WORK.FORMATS catalog is always searched first, unless it appears in the FMTSEARCH
    list. The LIBRARY.FORMATS catalog is searched after WORK.FORMATS and before anything else
    in the FMTSEARCH list, unless it appears in the FMTSEARCH list. </p>
    <p>example usage: <tt>options fmtsearch=(book finsurv cancer);</tt> </p>
    <p>SAS will search for formats in the following catalogues (in order): WORK, LIBRARY,
    BOOK, FINSURV, CANCER. </p>
    <p align="left"><b>Suggested usage</b> </p>
    <ol type="1">
      <li>Define libnames and the FMTSEARCH= option in <tt>autoexec.sas</tt>. </li>
      <li>Create a SAS file called FORMATS.SAS which contains the PROC FORMAT code. </li>
    </ol>
    <p><br>
    Sample code to be included in AUTOEXEC.SAS:<br>
    <span class="sascode">libname project 'c:\project';<br>
    options fmtsearch=(project);<br>
    </span></p>
    <p>Sample code to be included in FORMATS.SAS:<br>
    <span class="sascode">/* delete the existing catalogue */<br>
    proc datasets library=project memtype=(catalog);<br>
    delete formats / memtype=catalog;<br>
    run;<br>
    <br>
    proc format library=project;<br>
    value smoke<br>
    .='missing'<br>
    1='current smoker'<br>
    2='former smoker'<br>
    3='never smoked'<br>
    ;<br>
    run;<br>
    </span></p>
    <p>The code to delete the existing catalogue is optional. </p>
    <p>The guidelines being developed by the analysis group for documenting and storing data
    files on the server will require that formats be specified in this manner in a file called
    FORMATS.SAS. </p>
    <p align="left"><b>Sample SAS code (one.sas)</b> </p>
    <pre>libname project 'c:\temp';

options fmtsearch=(project);

proc format library=project;
value smoke
.='missing'
1='current smoker'
2='former smoker'
3='never smoked'
;
run;

data project.paul;
do i=1 to 300;
smoke=mod(floor(100*ranuni(-1)),3)+1;
expose=ranuni(-1)&lt;0.5;
disease=ranuni(-1)&lt;0.2;
age=ranbin(-5,150,0.3);
output;
end;
drop i;
label
smoke='Smoking status'
expose='Exposure status'
disease='Disease status'
age='Age in years'
;
run;

proc freq;
tables smoke;
format smoke smoke.;
run;
</pre>

<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
