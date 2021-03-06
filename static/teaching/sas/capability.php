<?PHP
$strPageStyle = 'main';
$strTitle = 'PROC CAPABILITY';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

      <p>PROC CAPABILITY is a component of SAS/QC (Quality Control). The features 
        described below are now available in PROC UNIVARIATE (part of base SAS).</p>
    <p>PROC CAPABILITY is designed for process capability analysis, but contains many useful
    features for those of us who can't tell the difference between a capable process and an
    in-control process, including:<ul>
      <li>Histograms and comparative histograms. Optionally, these can be superimposed with fitted
        probability density curves for various distributions and kernel density estimates.<br>
      </li>
      <li>Cumulative distribution function plots (cdf plots). Optionally, these can be
        superimposed with specification limits and probability distribution curves for various
        distributions.<br>
      </li>
      <li>Quantile-quantile plots (Q-Q plots), probability plots, and probability-probability
        plots (P-P plots). These plots facilitate the comparison of a data distribution with
        various theoretical distributions.<br>
      </li>
      <li>Goodness-of-fit tests for a variety of distributions including the normal.<br>
      </li>
      <li>Statistical intervals (prediction, tolerance, and confidence intervals) for a normal
        population.<br>
      </li>
      <li>The ability to inset summary statistics and capability indices in plots produced on a
        graphics device.<br>
      </li>
    </ul>
    <p>The SAS code described on this page can be downloaded <a href="capability.sas">here</a>.</p>
    <p>See also the <a href="graph.php">page on SAS/GRAPH</a>.</p>
    <pre>/* Generate some normally distributed data */
data norm;
do i=1 to 500;
x=rannor(-5);
output;
end;
run;

/* A simple example */
proc capability data=norm graphics normaltest;
title 'Histogram using default settings';
var x;
histogram x;
run;


/* A more advanced example */
/* First set some graphics options */
goptions reset=all gunit=pct rotate=landscape
         htitle=3.0 htext=2.5 noprompt
         horigin=0.4in vorigin=0.4in
         vsize=7.0in hsize=10.0in
         device=win target=winprtg ftext=swiss
;

proc capability data=norm graphics normaltest;
title 'Histogram using additional options';
var x;
histogram x /
    midpoints=-3.5 to 3.5 by 0.1
    normal;
inset min median max mean std / format=6.3;
run;

proc capability data=norm graphics normaltest;
title 'Test of normality';
var x;
qqplot x / normal (mu=est sigma=est);
run;
</pre>
	<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
