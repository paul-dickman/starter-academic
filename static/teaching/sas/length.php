<?PHP
$strPageStyle = 'main';
$strTitle = 'The LENGTH statement';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>In SAS, the length of a variable is the number of bytes SAS allocates for storing the
    variable. It is not necessarily the same as the number of characters in the variable. </p>
    <p>Why use it? To reduce the size (in terms of disk space) of SAS data sets.</p>
    <p>By default, SAS uses 8 bytes to store numeric variables. Variables containing integer
    values can be stored using less than 8 bytes.</p>
    <table CELLSPACING="1" BORDER="1" WIDTH="274" align="center">
      <caption>Largest integer represented exactly by length for SAS variables under Windows</caption>
      <tr>
        <td WIDTH="25%" HEIGHT="17" align="right">Length in bytes</td>
        <td WIDTH="75%" HEIGHT="17" align="right">Largest integer represented exactly</td>
      </tr>
      <tr>
        <td WIDTH="25%" HEIGHT="17" align="right"><p ALIGN="RIGHT">3</td>
        <td WIDTH="75%" HEIGHT="17" align="right"><p ALIGN="RIGHT">8,192</td>
      </tr>
      <tr>
        <td WIDTH="25%" HEIGHT="17" align="right"><p ALIGN="RIGHT">4</td>
        <td WIDTH="75%" HEIGHT="17" align="right"><p ALIGN="RIGHT">2,097,152</td>
      </tr>
      <tr>
        <td WIDTH="25%" HEIGHT="17" align="right"><p ALIGN="RIGHT">5</td>
        <td WIDTH="75%" HEIGHT="17" align="right"><p ALIGN="RIGHT">536,870,912</td>
      </tr>
      <tr>
        <td WIDTH="25%" HEIGHT="17" align="right"><p ALIGN="RIGHT">6</td>
        <td WIDTH="75%" HEIGHT="17" align="right"><p ALIGN="RIGHT">137,438,953,472</td>
      </tr>
      <tr>
        <td WIDTH="25%" HEIGHT="17" align="right"><p ALIGN="RIGHT">7</td>
        <td WIDTH="75%" HEIGHT="17" align="right"><p ALIGN="RIGHT">35,184,372,088,832</td>
      </tr>
      <tr>
        <td WIDTH="25%" HEIGHT="17" align="right"><p ALIGN="RIGHT">8</td>
        <td WIDTH="75%" HEIGHT="17" align="right"><p ALIGN="RIGHT">9,007,199,254,740,990</td>
      </tr>
    </table>
    <p>Data sets containing many integer variables (such are common with data collected by
    questionnaire) or indicator variables can be reduced in size by more than 50%.</p>
    <p>Variables containing real numbers should be left with the default length of 8.</p>
    <p>Examples using the LENGTH statement:</p>
    <pre>data one;
length sex age 3 pnr 6;
...
run;</pre>
    <pre>data two;
length pnr 6 default=3;
...
run;</pre>
    <p>Details are given on pages 429-30 of the SAS Language: Reference manual (version 6
    first edition), which is reproduced in full in the online help, and the relevant host
    companion.</p>
    <p>Note that specifying a length less than that required will result in a loss of
    precision without any warning being given (see the example on page 92 of the SAS Language:
    Reference manual). For example, the following code will produce the output shown below: </p>
    <pre>data temp;
length x 4 y 3;
do x=9000 to 9010;
y=x;
output;
end;
run;

proc print;
run;

OBS  X     Y

 1 9000 9000
 2 9001 9000
 3 9002 9002
 4 9003 9002
 5 9004 9004
 6 9005 9004
 7 9006 9006
 8 9007 9006
 9 9008 9008
10 9009 9008
11 9010 9010</pre>
    <p>The variable X has length 4, which can store integers up to 2,097,152 without loss of
    precision, whereas the variable Y has length 3 which can store integers up to 8,192
    without loss of precision. As such, Y is not able to store all values precisely.</p>
    <p>Variable lengths can also be assigned using the ATTRIB statement, which can also assign
    other variable characteristics (e.g. formats, informats, labels).</p>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
