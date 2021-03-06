<?PHP
$strPageStyle = 'main';
$strTitle = 'Introduction to arrays';
require ('config.php');
require ('header.php');
require ('sidebar_main_ad.html');
?>

<!-- main content start -->

      <p>SAS arrays are useful when we wish to perform a similar operation on a
      set of variables. For example:
</p>
      <p class="sascode">array weight wt1-wt50;<br>
      <br>
      do i=1 to 50;<br>
      if weight{i}=999 then weight{i}=.;<br>
      end;
</p>
      <p>A SAS array is nothing more than a collection of variables (of the same
      type), in which each variable can be identified by referring to the array
      and, by means of an index, to the location of the variable within the
      array.
</p>
      <p>SAS arrays are defined using the ARRAY statement, and are only valid
      within the data step in which they are defined.
</p>
      <p>The syntax for the array statement is:
</p>
      <p><font face="Courier New">ARRAY array-name {subscript} &lt;$> &lt; length >&nbsp;<br>
      &lt;&lt; array-elements > &lt;( initial-values )>></font>
</p>
      <p><font face="Courier New"> array-name </font>must follow the naming
      rules for SAS variables.
</p>
      <p><font face="Courier New"> { subscript }</font> is the dimension
      (possibly multiple) of the array, and can be omitted or specified as {*}
      in which case SAS infers the dimension from the number of array elements.
</p>
      <p><font face="Courier New">&lt; array-elements > </font>is the list of
      array elements (variables) which can be omitted if the dimension is given,
      in which case SAS creates variables called <font face="Courier New"> array-name1</font>
      to <font face="Courier New"> array-name{n} </font>where <font face="Courier New">{n}
      </font>is the dimension of the array. For example:<br>
      <font face="Courier New">array wt {50};</font><br>
      will cause the variables wt1-wt50 to be created.
</p>
      <p><b>Example using data from the Swedish Fertility Registry<br>
      </b>For each record, we have information on up to 12 'events'. The event type
      (usually a birth) is stored in the variables type1-type12 and the
      corresponding date is stored in the variables date1-date12.
</p>
      <p>The coding for the 'type' variables is:<br>
      0=stillbirth<br>
      1=live boy<br>
      2=live girl<br>
      6=immigration
</p>
      <p>For each woman, we want to count the total number of live births, the
      total number of completed pregnancies (live births plus still births), and
      extract the emigration date for the women who emigrated.
</p>
      <p class="sascode">array type type1-type12;<br>
      array datum date1-date12;<br>
      births=0; fullterm=0; emigrate=0;<br>
      do i = 1 to 12;<br>
      if type[i] in (1,2) then births=sum(births,1);<br>
      if type[i] in (0,1,2) then fullterm=sum(fullterm,1);<br>
      if type[i] in (6) then do;<br>
      &nbsp;&nbsp;&nbsp; emigrate=1;&nbsp;<br>
      &nbsp;&nbsp;&nbsp; emi_date=input(datum[i],yymmdd.);<br>
      &nbsp;&nbsp;&nbsp; end;<br>
      end;<br>
      label<br>
      births='No. live births'<br>
      fullterm='No. completed pregnancies'<br>
      emigrate='Emigration indicator'<br>
      emi_date='Date of emigration (SAS date)'<br>
      ;<br>
</p>
      <p><b>References</b><br>
      Arrays: SAS Language, version 6, first edition, pages 292-306.
</p>
      <p>&nbsp;
</p>
<!-- main content end -->

<?PHP
require ('footer_ad.php');
?>
  