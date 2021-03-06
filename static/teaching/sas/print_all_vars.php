<?PHP
$strPageStyle = 'main';
$strTitle = 'Printing all variables for a single observation';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

      <p>It is not uncommon to want to examine all variables for a single
      observation. That is, for data sets containing lots of variables, print
      out the values for all variables on a single page. The following code will
      achieve this:</p>
    <pre><font SIZE="2">proc fsbrowse data=hit.cases label printall;
run;</font></pre>
      <p><font size="2">The LABEL option causes variable labels to be printed rather than
      variable names. </font>
</p>
      <p><font size="2">The number of observations can be restricted using a
      WHERE statement and the number of variables can be restricted using the
      VAR statement. For example:</font>
</p>
      <p class="sascode"><font SIZE="2">proc fsbrowse data=hit.cases label
      printall;<br>
      where sex=2;<br>
      </font>var kon--ulorsak;<font SIZE="2"><br>
      run;</font>
</p>
      <p><font size="2">It is also possible to invoke the procedure using the
      FSBROWSE command. For example, type <font face="Courier New">fsbrowse
      hit.cases</font> in the command line and use the PageUp and PageDown keys
      to scroll through the observations.</font>
</p>
      <p><font size="2">The 'FS' in FSBROWSE stands for full screen. A similar
      procedure, PROC FSEDIT, allows editing of the SAS data set. It is possible
      to create customised screens and data entry procedures which include error
      checking.</font>
</p>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
