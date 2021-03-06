<?PHP
$strPageStyle = 'main';
$strTitle = 'Referring to variables using SAS variable lists';
require ('config.php');
require ('header.php');
 require ('sidebar_main_ad.html');
?>

<!-- main content start -->

      <p>When a series of variables is being referred to, the use of an
      abbreviated variable list can save a great deal of time. SAS supports
      three types of abbreviated variable lists, numbered range lists (specified
      using one dash), name range lists (specified using two dashes), and
      special name lists.
</p>
      <p><b>1. Numbered range lists<br>
      </b><font face="Courier New">VAR1-VAR5</font> is equivalent to <font face="Courier New">VAR1
      VAR2 VAR3 VAR4 VAR5. </font>If you use this type of variable list then all
      variables must exist.
</p>
      <p><b>2. Name range lists<br>
      </b><font face="Courier New">X--A </font>refers to all variables between <font face="Courier New">X</font>
      and <font face="Courier New">A</font> inclusive, according to the order of
      the variables in the PDV (program data vector). That is, according to the
      SAS internal variable order.
</p>
      <p><font face="Courier New">X-numeric-A </font>refers to all numeric
      variables between <font face="Courier New">X</font> and <font face="Courier New">A
      </font>inclusive and <font face="Courier New">X-character-A </font>refers
      to all character variables between X and A inclusive.
</p>
      <p>The SAS internal sort order is the order in which SAS encountered the
      variables in the data step which created the SAS data set. If the SAS data
      set was created by, for example, reading a text file, the internal order
      will be the order in which the variables were read in. This makes it easy
      to access, for example, the variables representing a series of questions
      in a questionnaire.&nbsp;
</p>
      <p>The internal order of the variables can be determined using the
      POSITION option on PROC CONTENTS.
</p>
      <font SIZE="2">
      <p class="sascode">proc contents data=hit.cases position;<br>
      run;</p>
      </font><p>This will result in one list of variables in alphabetical order
      (the default ordering for PROC CONTENTS) and a second list according to
      the internal order.
</p>
      <p>Variables in the VAR windows (type, for example, <font face="Courier New">var
      hit.cases</font> in the command line) will, by default, be ordered by the
      internal order.
</p>
      <p><b>3. Special SAS name lists</b><br>
      These include all variables of a particular type. For example _CHARACTER_,
      _NUMERIC_, and _ALL_.
</p>
      <p><b>Examples of usage</b>
</p>
      <p class="sascode">drop x--a;
</p>
      <p class="sascode">proc means;<br>
      var _numeric_;<br>
      run;
</p>
      <p class="sascode">proc print;<br>
      var pnr name week1-week12;<br>
      run;
</p>
      <p class="sascode">proc freq;<br>
      var pnr--age;<br>
      run;
</p>
      <p><b>Reference</b><br>
      SAS Language, version 6, first edition, pages 111-113.
</p>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
