<?PHP
$strPageStyle = 'main';
$strTitle = 'Introduction to SAS/GRAPH';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>The following SAS code illustrates some of the features of SAS/GRAPH for producing
    high-resolution graphs. </p>
    <p>The code can be downloaded <a href="lung_hi_res_graphics.sas">here</a>. </p>
      <p>See also the description of <a href="capability.php">PROC CAPABILITY 
        for producing histograms</a> and <a href="graph_sven.php">Sven Sandin's 
        seminar on SAS/GRAPH</a>.</p>
      <p>The SAS <a href="http://ftp.sas.com/techsup/download/sample/graph/gplot-examples-list.html">technical 
        support page</a> shows some sample graphs with downloadable code. </p>
      <p>Sample code is also available from within SAS (select Sample Programs 
        from the Help menu). </p>
      <p>Some examples of using SAS/GRAPH for regression graphics are given in 
        the file <a href="anscombe.sas">anscombe.sas</a>, including:</p>
      <ul>
        <li>Plotting raw data with a fitted regression line.</li>
        <li>Plotting residuals and influence statistics.</li>
        <li>Using the annotate facility.</li>
        <li>Using PROC GREPLAY to format 4 graphs to a page.</li>
      </ul>
      <p><strong>A PROC GPLOT example:</strong><br>
        The data show the age, sex, and height of 32 recipients of heart-lung 
        transplates along with their pre-transplate total lung capacity (TLC) 
      </p>
      <pre>proc format;
value sex
0='Females'
1='Males'
;
run;

data lung;
input patient age sex height tlc;
format sex sex.;
label
patient='Patient ID number'
age='Age in years'
sex='Sex (0=female 1=male)'
height='Height (cm)'
tlc='Total lung capacity'
;
cards;
  1   35   0  149  3.40
  2   11   0  138  3.41
  3   12   1  148  3.80
  4   16   0  156  3.90
  5   32   0  152  4.00
  6   16   0  157  4.10
  7   14   0  165  4.46
  8   16   1  152  4.55
  9   35   0  177  4.83
 10   33   0  158  5.10
 11   40   0  166  5.44
 12   28   0  165  5.50
 13   23   0  160  5.73
 14   52   1  178  5.77
 15   46   0  169  5.80
 16   29   1  173  6.00
 17   30   0  172  6.30
 18   21   0  163  6.55
 19   21   0  164  6.60
 20   20   1  189  6.62
 21   34   1  182  6.89
 22   43   1  184  6.90
 23   35   1  174  7.00
 24   39   1  177  7.20
 25   43   1  183  7.30
 26   37   1  175  7.65
 27   32   1  173  7.80
 28   24   1  173  7.90
 29   20   0  162  8.05
 30   25   1  180  8.10
 31   22   1  173  8.70
 32   25   1  171  9.45
;
run;

proc plot data=lung;
title1 'Figure 1: Total lung capacity vs height';
title2 'Low-resolution plot using default options';
plot tlc*height;
run;
quit;

/*********************************************************
A high-resolution graphics plot can be obtained using PROC
GPLOT. The code is identical to that used in PROC PLOT.
*********************************************************/
proc gplot data=lung;
title1 'Figure 2: Total lung capacity vs height';
title2 'High-resolution plot using default options';
plot tlc*height;
run;
quit;

/*********************************************************
The appearance of the plot can be improved by setting some
additional graphics options and defining plot symbols and
axis characteristics.
*********************************************************/
goptions reset=all gunit=pct rotate=landscape
         htitle=3.0 htext=2.5 noprompt
         horigin=0.4in vorigin=0.4in
         vsize=7.0in hsize=10.0in
         device=win target=winprtg ftext=swiss
;


/* define horizontal axis characteristics */
axis1   label=(h=2.5 'Height in cm')
        major=(height=0.5)
        minor=none
        ;

/* vertical axis characteristics */
axis2   label=(h=2.5 'TLC')
        order=(0 to 10 by 2)
        major=(height=0.5)
        minor=none
        ;

symbol1 color=black interpol=none height=2.5 value=circle;

proc gplot data=lung;
title1 h=3.0 'Figure 3: Total lung capacity vs height';
title2 h=2.5 'High-res. plot using additional options';
plot tlc*height / frame haxis=axis1 vaxis=axis2;
run;
quit;

/*********************************************************
Now use a different plotting symbol for each sex.
*********************************************************/
symbol1 color=black interpol=none height=2.5 value=circle;
symbol2 color=black interpol=none height=2.5 value= =;

legend1 frame label=none position=inside;

proc gplot data=lung;
title1 h=3.0 'Figure 4: Total lung capacity vs height';
title2 h=2.5 'A different plot symbol for each sex';
plot tlc*height=sex 
    / frame haxis=axis1 vaxis=axis2 legend=legend1;
run;
quit;

/*********************************************************
Now fit a regression line through the data.
The approach is to plot the data twice, using different
symbol definitions. The second symbol definition tells SAS
not to plot the individual points, but to interpolate using
a linear regression line.
*********************************************************/

symbol1 color=black interpol=none value=dot;
symbol2 color=black interpol=rl value=none;

proc gplot data=lung;
title1 h=3.0 'Figure 5: Total lung capacity vs height';
title2 h=2.5 'A linear regression model is fitted to
 the data (TLC=-9.74+0.0945*HEIGHT)';
plot tlc*height=1 tlc*height=2 
    / overlay frame haxis=axis1 vaxis=axis2;
run;
quit;
</pre>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
