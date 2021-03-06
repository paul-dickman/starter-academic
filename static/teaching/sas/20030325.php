<?PHP
$strPageStyle = 'main';
$strTitle = 'The Little SAS Book Chapters 1 &amp; 2 (seminar by Anna Johansson, 25 March 2003)';
require ('config.php');
require ('header.php');
require ('sidebar_main.html');
?>

<!-- main content start -->
         
      <p>The Little SAS Book, 2nd ed.,<br>
        by Lora Delwiche &amp; Susan Slaughter, <br>
        <a href="http://www.sas.com/apps/pubscat/bookdetails.jsp?catid=1&pc=58788">SAS 
        Publishing</a><br>
      </p>
      <h3>Chpt 1: Getting started using the SAS System</h3>
      <h4>1.1 The SAS language</h4>
      <p>SAS programs consist of data steps, proc steps and comments.</p>
      <p>Example of a SAS program: </p>
      <pre>* seminar_2003-03-25_sasprogr.sas;
* 2003-03-10 / Anna Johansson, MEP;</pre>
      <pre>* uses: annaj.diet_raw; 
* (originally diet.sd7 from BiostatIII_course
Statistical models in epidemiology, 
Clayton&amp;Hills, 1993, p 274);
* creates: annaj.diet; 
* Examples for SAS seminar 2003-03-25;</pre>
      <pre>libname annaj 'h:\sas\sas seminars';</pre>
      <pre>* read in raw data, do not want to use raw data, 
  if I mess up the data;
data annaj.diet;
  set annaj.diet_raw;
run;</pre>
      <pre>* checking outcome: chd, Coronary Heart Disease;
proc freq data=annaj.diet;
  tables chd;
run;</pre>
      <pre></pre>
      <h4>1.2 SAS data sets</h4>
      <p>SAS data sets consist of observations (rows) and variables (columns).</p>
      <p>Variables are: NUM or CHAR</p>
      <p>x=42 NUM<br>
        x='42' CHAR<br>
        x='042' CHAR, eg occupational code, SES code<br>
        x=042 NUM &gt;&gt; x=42</p>
      <p>x='dead' CHAR<br>
        x=dead ERROR, dead will be interpreted as variable DEAD</p>
      <p><br>
        Missing values are represented</p>
      <p>x=. NUM<br>
        x=' ' CHAR</p>
      <p><br>
        A data set is made up of two parts or portions, the DATA PORTION which 
        is the data itself, and the DESCRIPTOR PORTION which is meta data or descriptive 
        information about the data, such as a variable list, number of observations, 
        date of creation. You can view the descriptor portion by using PROC CONTENTS. 
        See also chpt 2.8.</p>
      <p> <br>
        proc contents data=annaj.diet_raw;<br>
        run;</p>
      <p></p>
      <h4>1.3 The two parts of a SAS program</h4>
      <p>SAS programs are made up of data steps and proc (procedure) steps.</p>
      <p>Data steps read and modify data, and create a new data set.</p>
      <pre>data ...;
         statements...;
         run;</pre>
      <p>Proc steps use a data set, can produce output/result.</p>
      <pre>proc ...;
         statements...;
         run;</pre>
      <p><br>
        Data step are used for actions on rows (eg. create a new variable from 
        another variable).<br>
        Proc step are used for actions on columns (eg. calculate a mean of a variable)</p>
      <p>Good rule1: use as few data steps as possible (in most cases only one 
        step is needed!)</p>
      <pre>data annaj.diet;
         set annaj.diet_raw;</pre>
      <pre> *here I create all my variables for the analyses;</pre>
      <pre> bmi = weight/height**2;
         run;</pre>
      <p><br>
        Good rule2: keep the main data set code in a separate program, do analyses 
        in other programs, and name them properly and understandably!, use dates, 
        use comments (a good program is a green program!)</p>
      <p></p>
      <p></p>
      <p></p>
      <h4>1.8 Reading the SAS log</h4>
      <p>When a program is executed a log is generated in the log window. ALWAYS 
        read log! It contains useful information. </p>
      <p>There are three types of log messages, coloured blue, green and red.</p>
      <p>NOTE: blue, general (good) information, useful, number of obs.</p>
      <p>WARNING: green, not an error but SAS informs you that you may have a 
        problem, although it does not stop processing, still creates a data set</p>
      <p>ERROR: red, an error in the code, SAS cannot process the data step, it 
        stops! If you are running the data step to replace an older version of 
        a data set, it has NOT been replaced!</p>
      <p></p>
      <h4>1.10 Using SAS System options</h4>
      <p>You can change the SAS environment by using system options.</p>
      <p>Change font for output: Choose from the menu File &gt; Print setup &gt; 
        Font<br>
        Center|Nocenter output: Choose from the menu Tools &gt; Options &gt; System 
        &gt; Log &amp; Procedure Output Control &gt; Procedure Output &gt; Center=1 
      </p>
      <p>An easy way to work with SAS is to use the function keys (F1-F12), instead 
        of using the mouse and clicking. You can define the keys any way you like, 
        below is a suggestion.</p>
      <p>To change keys settings: type &quot;keys&quot; in the command line<br>
        F3 clear log; clear output; wpgm<br>
        F4 recall<br>
        F5 wpgm<br>
        F6 log<br>
        F7 output<br>
        F8 submit<br>
        F12 clear</p>
      <p></p>
      <h3>Chpt 2: Getting your Data into the SAS System</h3>
      <p><br>
        Not a big problem for MEP users, we usually already have SAS data sets 
        <br>
        (.sd7, .sas7bdat, .sd2). Then you only use the SET statement.</p>
      <p>If you do not have a SAS data set, ask a SAS programmer, or use Import 
        Wizard.</p>
      <p>Other data formats, we can use DBMS/Copy to convert data files, on computer 
        in biostat library, do not spend hours trying to convert a file.</p>
      <p></p>
      <h4>2.9 Temporary vs. permanent data sets</h4>
      <p>Temporary data sets disappear when you exit SAS.<br>
        Permanent data sets are stored on disk, so you can use them again. You 
        need to specify the path to the data set in the SAS code.</p>
      <pre>/*temporary data set*/
data diet_temp;
  set diet_raw;
run;</pre>
      <pre>/* permanent data set*/
data 'h:\sas\seminar\diet_perm'; 
  set diet_raw;
run;</pre>
      <pre>proc contents data='h:\sas\seminar\diet_perm';          
run;</pre>
      <p><br>
        2.10 Using LIBNAME statements with permanent data sets</p>
      <p>To avoid the extra work to write paths in code for a permanent data set, 
        there is a shortcut called LIBNAME or more correctly LIBREF.</p>
      <p>The libname is a little label that you define as the path, and then you 
        write the label in the code instead of the path.</p>
      <pre>/* permanent data set */
data 'h:\sas\sas seminars\diet'; 
  set 'h:\sas\sas seminars\diet_raw';
run;</pre>
      <pre>* create libname, i.e. path;
libname annaj 'h:\sas\sas seminars';</pre>
      <pre>data annaj.diet; /* permanent data set */
  set annaj.diet_raw;
run;</pre>
      <p>LIBREFS/LIBNAMES can be used in both data steps and proc steps</p>
      <pre>proc print data=annaj.diet_raw;
run;</pre>
      <p></p>
      <p>But, even a temporary data set must be stored physically on the disk.</p>
      <p>WORK library : 'c:\documents and settings\annaj\<br>
        SAS temporary files\_TD840\diet_temp'</p>
      <p>Libname for the temporary library is WORK.</p>
      <pre>data work.diet;
  set annaj.diet_raw;
run;</pre>
      <p>You do not need to specify the WORK library.</p>
      <pre>data diet;
  set annaj.diet_raw;
run;</pre>
      <p>The WORK library is emptied automatically when you end the SAS session, 
        thus no temporary data sets are stored.</p>
      <p>Different versions of SAS use what is known as engines. The engine is 
        specific for each version and can cause problems when you want to use 
        data sets created in different versions.</p>
      <p>Relationship between file extensions and versions:<br>
        .sd2 (v6)<br>
        .sd7 (v8)<br>
        .sas7bdat (v8)</p>
      <p>The libnames are engine-specific, i.e. a libname can only be used for 
        one type of file extensions. You specify the engine in the libname statement. 
        If no engine is specified SAS chooses the one that is most common among 
        the data set files in the directory.</p>
      <pre>libname annaj6 v612 'h:\sas\sas seminars\';
libname annaj v8 'h:\sas\sas seminars\';</pre>
      <pre>* v6 &gt;&gt; v6;
data annaj6.diet;
  set annaj6.diet_raw;
run;</pre>
      <pre>* v8 &gt;&gt; v8 ;
data annaj.diet;
 set annaj.diet_raw;
run;</pre>
      <pre>* if I want to change versions of data set;
* v6 &gt;&gt; v8;
data annaj.diet_raw;
  set annaj6.diet_raw;
run;</pre>

<!-- main content end -->

<?PHP
require ('footer.php');
?>
