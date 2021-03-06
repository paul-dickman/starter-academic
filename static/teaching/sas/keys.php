<?PHP
$strPageStyle = 'main';
$strTitle = 'SAS function keys';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

    <p>I like to clear the log and the output window before I run each analysis, so I've set
    up a function key, F3, to clear all windows. I can then recall the previous code using F4,
    followed by F8 to submit the code.</p>
    <p>Function key definitions can be changed by going into the keys window (type keys in the
    command line), changing the definitions and then choosing 'Save' from the file menu.</p>
    <p>The function keys I use are as follows:</p>
    <p><strong>F1</strong> help<br>
    <strong>F2</strong> dir<br>
    <strong>F3</strong> log; clear; output; clear; pgm; clear; zoom on;<br>
    <strong>F4</strong> recall<br>
    <strong>F5</strong> pgm; zoom on<br>
    <strong>F6</strong> log; zoom on<br>
    <strong>F7</strong> output; zoom on<br>
    <strong>F8</strong> zoom off;submit<br>
    <strong>F9</strong> keys<br>
    <strong>F11</strong> command bar<br>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
	