<?PHP
$strPageStyle = 'main';
$strTitle = 'SAS sample statistic functions';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

      <p>You should be familiar with <a href="variable_lists.php">'variable
      lists'</a> before reading this page.</p>
      <p>Sample statistics for a single variable across all observations are
      simple to obtain using, for example, PROC MEANS, PROC UNIVARIATE, etc. The
      simplest method to obtain similar statistics across several variables
      within an observation is with a 'sample statistics function'.&nbsp;
</p>
      <p>For example:
</p>
      <p class="sascode">sum_wt=sum(of weight1 weight2 weight3 weight4 weight5);
</p>
      <p>Note that this is equivalent to
</p>
      <p class="sascode">sum_wt=sum(of weight1-weight5);
</p>
      <p>but is not equivalent to
</p>
      <p class="sascode">sum_wt=weight1 + weight2 + weight3 + weight4 + weight5;
</p>
      <p>since the SUM function returns the sum of non-missing arguments,
      whereas the '+' operator returns a missing value if any of the arguments
      are missing.
</p>
      <p>The following are all valid arguments for the SUM function:<br>
      <font face="Courier New">sum(of variable1-variablen)</font> where n is an
      integer greater than 1<br>
      <font face="Courier New">sum(of x y z)<br>
      sum(of array-name{*})<br>
      sum(of _numeric_)<br>
      sum(of x--a)</font> where x precedes a in the PDV order
</p>
      <p>A comma delimited list is also a valid argument, for example:<br>
      <font face="Courier New">sum(x, y, z)</font>
</p>
      <p>However, I recommend always using an argument preceded by OF, since
      this minimises the chance that you write something like<br>
      <font face="Courier New">sum_wt=sum(weight1-weight5);</font>
</p>
      <p>which is a valid SAS expression, but evaluates to the difference
      between weight1 and weight5.
</p>
      <p>Other useful sample statistic functions are:
</p>
      <p>MAX(argument,...) returns the largest value&nbsp;<br>
      <br>
      MIN(argument,...) returns the smallest value&nbsp;<br>
      <br>
      MEAN(argument,...) returns the arithmetic mean (average)&nbsp;<br>
      <br>
      N(argument,....) returns the number of nonmissing arguments&nbsp;<br>
      <br>
      NMISS(argument,...) returns the number of missing values&nbsp;<br>
      <br>
      STD(argument,...) returns the standard deviation&nbsp;<br>
      <br>
      STDERR(argument,...) returns the standard error of the mean&nbsp;<br>
      <br>
      VAR(argument,...) returns the variance
</p>
      <p><b>Example usage</b><br>
      You may, for example, have collected weekly test scores over a 20 week
      period and wish to calculate the average score for all observations with
      the proviso that a maximum of 2 scores may be missing.
</p>
      <p class="sascode">if nmiss(of test1-test20) le 2 then<br>
      &nbsp;&nbsp; testmean=mean(of test1-test20);<br>
      else testmean=.;
</p>
      <p><b>References</b><br>
      Function arguments: SAS Language, version 6, first edition, pages 50-51.
</p>
      <p>Functions: SAS Language, version 6, first edition, chapter 11, page
      521.
</p>
      <p>Type 'help functions' in the command line to access the online help.
</p>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
