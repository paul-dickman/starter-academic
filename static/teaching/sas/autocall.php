<?PHP
$strPageStyle = 'main';
$strTitle = 'Autocall libraries';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>An autocall library contains files that define SAS macros. If you regularly use
    user-written SAS macros, it is efficient to store these macros in a separate windows
    directory (although not a subdirectory of the main SAS directory). Each macro file in the
    directory must contain a macro definition with a macro name the same as the filename. For
    example, a file named SMR. SAS must define a macro named SMR.</p>
    <p>This directory is defined as a SAS autocall library using the SASAUTOS system option.
    Note that SAS Institute supplies some autocall macros, which are stored in the library
    called SASAUTOS. That is, by default, the SASAUTOS option refers to the library called
    SASAUTOS. To add your own macro directory, your AUTOEXEC.SAS file might look something
    like this:</p>
    <pre>libname project 'c:\project';
libname paul    'c:\paul';
libname formlib 'c:\formats';
filename mymacros 'c:\mysas';

options nocenter
        fmtsearch=(formlib project)
        sasautos=(sasautos mymacros)
        mautosource
        ;</pre>
    <p>If you invoke a macro which has not been defined in the current SAS session, SAS will
    first look in the SAS autocall libraries (SASAUTOS) followed by your personal macro
    directory (MYMACROS).</p>
    <p>To use the autocall facility, you must have the SAS system option MAUTOSOURCE set.</p>
    <p>The advantage of using the autocall facility is that all user-defined macros are stored
    is a standard location and they are not compiled until they are actually needed.</p>
	<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
