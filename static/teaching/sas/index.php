<?PHP
$strPageStyle = 'main';
$strTitle = 'SAS notes';
require ('config.php');
require ('header.php');
require ('sidebar_main_ad.html');
?>

<!-- main content start -->
      
<p>These SAS seminars, delivered 1999-2000, were aimed at doctoral students in my departments. I no longer use SAS, and these files are not maintained or updated.</p>
      
<p>Click on the links to download the slides and notes.</p>

<table border="1" width="446" cellspacing="1">
  <tr> 
    <td width="64"><em>Date</em></td>
    <td width="552"><em>Topic</em></td>
    <td width="63"><em>Teacher</em></td>
  </tr>
  <tr> 
    <td width="64">990309</td>
    <td width="552"><a href="format_catalog.php">Permanent format catalogues</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">990330</td>
    <td width="552"><a href="missing.php">Missing values</a><br> <a href="length.php">The 
      LENGTH statement</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">990420</td>
    <td width="552"><a href="genmod_logistic.php">Logistic regression in SAS 
      version 6</a></td>
    <td width="63">Fredrik</td>
  </tr>
  <tr> 
    <td width="64">990527</td>
    <td width="552"><a href="graph.php">Introduction to SAS/GRAPH</a><br> <a href="capability.php">Histograms 
      using PROC CAPABILITY</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">990610</td>
    <td width="552"><a href="autoexec.php">autoexec.sas</a><br> <a href="autocall.php">SAS 
      autocall libraries</a><br> <a href="keys.php">Function keys</a><br> <a href="set_by.php">FIRST. 
      and LAST. variables</a><br> <a href="quintiles.php">Categorising a variable 
      into quintiles</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">990831</td>
    <td width="552"> <p><a href="char_to_num.php">Converting variable types (e.g. 
        char to num)</a><br>
        <a href="age.php">Calculating age in completed years</a><br>
        <a href="age_dx.php">Calculating age at diagnosis from PNR and diagnosis 
        date</a><br>
        (See also <a href="dates031125.pdf">working with SAS dates</a>)<br>
        <a href="warnings.php">Customised notes and warnings</a></p></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">990914</td>
    <td width="552"><a href="formats.php">Formats and informats</a><br> <a href="dates.php">Working 
      with SAS date time values</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">991130</td>
    <td width="552"><a href="print_all_vars.php">Printing all variables for a 
      single observation<br>
      </a><a href="variable_lists.php">Referring to variables - 'Variable lists'</a><br> 
      <a href="functions.php">Sample statistic functions</a><br> <a href="arrays.php"> 
      Introduction to arrays</a><br> <a href="pnr_check.php">Verifying the check 
      digit on person numbers</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">010424</td>
    <td width="552"><a href="sas_efficiency8.pdf">Working efficiently with SAS</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">030325</td>
    <td width="552"><a href="20030325.php">The Little SAS Book Chapters 1 &amp; 
      2</a></td>
    <td width="63">AnnaJ</td>
  </tr>
  <tr> 
    <td width="64">030415</td>
    <td width="552"><a href="20030415.pdf">The Little SAS Book Chapters 3 &amp; 
      4</a> [<a href="20030415.sas">SAS code</a>]</td>
    <td width="63">&Aring;sa</td>
  </tr>
  <tr> 
    <td width="64">030422</td>
    <td width="552"><a href="20030422.pdf">The Little SAS Book Chapter 5</a></td>
    <td width="63">AnnaT</td>
  </tr>
  <tr> 
    <td width="64">030429</td>
    <td width="552"><a href="20030427.pdf">Analysing matched case-control studies 
      using PROC PHREG</a></td>
    <td width="63">AnnaJ</td>
  </tr>
  <tr> 
    <td width="64">030506</td>
    <td width="552"><a href="sas_tips_cleaning8.pdf">Tips and tricks (with a focus 
      on data cleaning)</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">030603</td>
    <td width="552"><a href="20030603.pdf">Debugging your SAS programs (The Little 
      SAS Book Chapter 8)</a></td>
    <td width="63">&Aring;sa</td>
  </tr>
  <tr> 
    <td width="64">031028</td>
    <td width="552"><a href="sas_logistic_seminar8.pdf">Logistic regression in 
      SAS version 8</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">031111</td>
    <td width="552"><a href="20031111.pdf">Modifying and combining SAS data sets, 
      merging with registry data</a></td>
    <td width="63">&Aring;sa</td>
  </tr>
  <tr> 
    <td width="64">031118</td>
    <td width="552"><a href="sas_efficiency8.pdf">Working efficiently with SAS</a></td>
    <td width="63">PaulD</td>
  </tr>
  <tr> 
    <td width="64">031125</td>
    <td width="552"><a href="dates031125.pdf">Working with SAS dates</a></td>
    <td width="63">AnnaJ</td>
  </tr>
  <tr>
    <td>031202</td>
    <td><a href="graph_sven.php">Creating Graphs with SAS. An overview and some
        examples</a></td>
    <td>Sven</td>
  </tr>
  <tr>
    <td>041026</td>
    <td><a href="proc_sql_slides_20041026.pdf">PROC SQL</a> [<a href="proc_sql_code_20041026.pdf">code</a>] </td>
    <td>Gustaf</td>
  </tr>
  <tr>
    <td>050603</td>
    <td><a href="phreg/index.php">Cox regression using PROC PHREG</a></td>
    <td>PaulD</td>
  </tr>
  <tr>
    <td>041026</td>
    <td>PROC SQL II [<a href="sql2_seminar_slides.pdf" target="_blank">handout</a>, <a href="sql2_pass-through_seminar_slides.pdf" target="_blank">pass-through slides</a>] </td>
    <td>Gustaf</td>
  </tr>
  <tr>
    <td>061122</td>
    <td><a href="rr/index.php">Estimating ratios of proportions (risk ratios)</a></td>
    <td>PaulD</td>
  </tr>
  <tr>
    <td>120227</td>
    <td>SAS Formats and SAS Dates [<a href="20120227_dates.pdf" target="_blank">handout</a>]</td>
    <td>AnnaJ</td>
  </tr>
  <tr>
    <td>120412</td>
    <td>Introduction to PROC SQL [<a href="ninoa_malki_SAS_20120412.pdf" target="_blank">handout</a>] [<a href="sascode_20120412.pdf" target="_blank">code</a>]</td>
    <td> Ninoa</td>
  </tr>
  <tr>
    <td>120607</td>
    <td><a href="survival.php">Survival analysis using SAS</a></td>
    <td>AnnaJ</td>
  </tr>
</table>
<!-- main content end -->
<br>
<?PHP
require ('footer_ad.php');
?>
