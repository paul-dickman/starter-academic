<?PHP
$strPageStyle = 'main';
$strTitle = 'Calculating age at diagnosis from PNR and diagnosis date';
require ('config.php');
require ('header.php');
require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>It is often necessary to calculate age at diagnosis from variables representing the
    personal identification number and the date of diagnosis (stored as a character variable).</p>
    <p>The first step is to create SAS date variables representing the birth date and
    diagnosis date. A SAS date variable stores dates as the number of days between January 1,
    1960 and the date. </p>
    <p>The variable DXDAT is a character variable, which is converted to a date variable
    called DIDAT2 using the input function. The SAS date variable called BIRTH is constructed
    in similar fashion, except we must first extract the substring (using the SUBSTR function)
    of the personal identification number which represents the date of birth.</p>
    <p>Age at diagnosis is then calculated as the number of completed years between the two
    dates using SAS code described <a href="age.php">here</a>.</p>
    <p>This code assumes that all dates are in the 1900s.</p>
    <p>The SAS code can be downloaded <a href="age_dx.sas">here</a>.</p>
    <pre>data temp;
length pnr $ 11 dxdat $ 6;
input pnr dxdat;

/* convert the character variable
to a SAS date variable */
didat2=input(dxdat,yymmdd.);

/* extract the birthdate from PNR */
birth=input(substr(pnr,2,6),yymmdd.);

age_dx=floor((intck('month',birth,didat2)
- (day(didat2) &lt; day(birth))) / 12);

format didat2 birth date.;

cards;
96511289999 990622
93404199999 590420
;;

proc print data=temp;
title 'Calculating age at diagnosis';
var pnr dxdat birth didat2 age_dx;
run;
</pre>
    <p>The output from this code is as follows:</p>
    <font SIZE="2"><pre>PNR          DXDAT   BIRTH    DIDAT2   AGE_DX

96511289999  990622  28NOV65  22JUN99    33
93404199999  590420  19APR34  20APR59    25</pre>
    </font><p>&nbsp;
	<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
