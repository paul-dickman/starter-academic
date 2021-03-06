<?PHP
$strPageStyle = 'main';
$strTitle = 'AUTOEXEC.SAS';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>At startup, SAS looks for a file called AUTOEXEC.SAS. If the file is found, then the
    SAS statements in the file will be processed. This is useful for setting global options
    and defining data libraries (libnames) at the beginning of a SAS session.</p>
    <p>A typical AUTOEXEC.SAS might contain an options statement and several libname
    statements. For example:</p>
    <pre>libname project 'c:\project';
libname paul    'c:\paul';
libname formlib 'c:\formats';

options nocenter fmtsearch=(formlib project);</pre>
    <p>Note that AUTOEXEC.SAS is processed once, when the SAS application is started, and not
    every time SAS commands are submitted.</p>
    <p>AUTOEXEC.SAS is not the best place for storing SAS macros. These should be kept in a <a href="autocall.php">SAS autocall library</a>.</p>
    <p>The best place to store AUTOEXEC.SAS is in the SAS root directory (usually
    C:\SAS).&nbsp; If you are running SAS from a server, or want to use a name for the file
    other than AUTOEXEC.SAS, you can specify the location of AUTOEXEC.SAS in the SAS startup
    command. For example:</p>
    <pre>G:\SAS\SAS.EXE -AUTOEXEC C:\SAS\MYAUTO.SAS</pre>
    <p>&nbsp;
	<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
