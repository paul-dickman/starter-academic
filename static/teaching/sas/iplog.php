<?php

# IP-LOGGER by Michael McSky	        
# 
# www.debilsoft.de      



// CONFIGUARATION

$version = '1.59b';

$name = 'daten.txt';	// file for datastoring

$reloadlock = 1;		// ReloadLoggingLock 	
$useronlinetime = 600;	// Set the range in seconds while a user is regarded as online



$showcounter = 1;		// Show visits, 
$showdayvisits = 1;	// Show visits per day
$showlastvisit = 0;		// Show last visit
$showyestvisit = 1;		// Show visits of yesterday
$showbrowsertyp = 0;	// Show browsertyp of the user
$showip = 0;		// Show IP addresse of the user
$showdnsn = 0;		// Show DNS name of the user
$showuseronline = 1;	// Show useronline
$hidecounter = 1;		// Makes the counter invisible




// MAKE FILE

if ( file_exists( $name) == FALSE)
{

$file = fopen($name, "w");
if($file) {

fputs($file, "0#########");
fputs($file, "\r\n");
fputs($file, "\r\n");


      
       fclose($file);
}
}

// Reload protection and daycounting



$useronline = 1;
$visitsyester = 0;
$visitsaday = 1;
$ipok = 1;
$datum = date("d.m.Y");
$datumyester = $last_week = date("d.m.Y", mktime(0,0,0, date(m), date(d)-1,date(Y)));


if(getenv("HTTP_CLIENT_IP")) { 
$ipad = getenv("HTTP_CLIENT_IP"); 
} elseif(getenv("HTTP_X_FORWARDED_FOR")) { 
$ipad = getenv("HTTP_X_FORWARDED_FOR"); 
} else { 
$ipad = getenv("REMOTE_ADDR"); 
}
$ipad = substr($ipad, 0,14);



$file = fopen ($name, "r");
while (!feof($file)) {
    $buffer = fgets($file, 4096);

// USRERONLINE INSTERT



if (strpos($buffer, 'T') == 15 ) {

$dayof = substr($buffer, 21,2);
$monthof = substr($buffer, 24,2);	
$yearof = substr($buffer, 27,4);

$hourof = substr($buffer, 34,2);
$minof = substr($buffer, 37,2);
$secof = substr($buffer, 40,2);


$timerec =  mktime($hourof, $minof, $secof , $monthof, $dayof, $yearof);
$realtime = time();



if (($realtime-$timerec) <= $useronlinetime) { if (strpos($buffer, $ipad) == false) {$useronline++;}} 	// refresh-counting protection


}

//  DAYCOUNTER


if ($buffer <> '' ) {$lastline = $buffer;}			
if (strpos($buffer, $datum) <> false) 
{ 
if (strpos($buffer, $ipad) <> false) {$ipok = 0;}
if (strpos($buffer, $ipad) == false) {$visitsaday++;}
}

if (strpos($buffer, $datumyester) <> false) 
{$visitsyester++; }


}
fclose ($file);


// end
// end




// HTML IP-LOGGER visitors data output

$HTTP_GET_VARS['showhtml'];  
if ($showhtml == '' ) {$showhtml = '0';}



if ($showhtml == 1 ) 
{

$bgs = 0;

echo '<html>
<head>
<title>debilsoft IP-LOGGER visitors data</title>

<style type="text/css">
<!--
td { 	 	font-family : verdana, arial;	font-size : 11px; color : #000000; }
//-->
</style>
</head>
<body>
debilsoft IP-LOGGER visitors data. (please wait while loading...)<br><br>
<table border="0" cellpadding="0" cellspacing="3" style="border-collapse: collapse" borderColor="#000000"  width="1800">
  <tr>
    <td width="75"><b>Visitor</b></td>
    <td width="129"><b>Time</b></td>
    <td width="100"><b>IP</b></td>
    <td width="300"><b>DNS-NAME</b></td>
    <td width="590"><b>Browser</b></td>
    <td width="400"><b>Referer</b></td>
  </tr>';

$file = fopen ($name, "r");

$buffer = fgets($file, 4096);

while (!feof($file)) {


if ($bgs == 0 ) {$BGC = '#eaeaea'; $BGC2 = '#d4d4d4'; $bgs = 1; } else { $BGC = '#ffffff'; $BGC2 = '#e9e9e9'; $bgs = 0; }

$buffer = fgets($file, 4096);

$buffer= eregi_replace("<", " ", $buffer);  
$buffer= eregi_replace(">", " ", $buffer);  

echo '<tr>';

$f1 =  substr($buffer, 2,10);
echo '<td bgcolor='.$BGC.'>'.$f1.'</td>';

$f2 =  substr($buffer, 21,21);
echo '<td bgcolor='.$BGC2.'>'.$f2.'</td>';

$f3 =  trim(substr($buffer, 48,17));
echo '<td bgcolor='.$BGC.'>'.$f3.'</td>';

$f4 =  trim(substr($buffer, 76,48));
echo '<td bgcolor='.$BGC2.'>'.$f4.'</td>';

$f5 =  substr($buffer, 124,92);
echo '<td bgcolor='.$BGC.'>'.$f5.'</td>';

$f6 =  substr($buffer, 222,strlen($buffer)); 


if (strlen($f6) >= 5  ) {
$f6b = $f6;
if (strlen($f6) >= 70 ) { $f6 = substr($f6, 0, 70); $f6 = $f6.'<b>...</b>'; }
echo '<td bgcolor='.$BGC2.'><a href="'.$f6b.'"  target="_new">'.$f6.'</a></td>';
} else { echo '<td bgcolor='.$BGC2.'></td>';}



echo '</tr>';





}
fclose ($file);



echo '</table><br>Users: ';

}

// end

// WRITE COUNTERVALUE




$file = fopen($name, "r+");
$count = fgets($file, 4096);
$count = trim($count);


if ($ipok == 1) { $count = $count+1; } 
$count = $count+0;

rewind($file);

if ($showhtml == 0 ) { fputs($file, $count);  }



fclose($file);

if ($showhtml == 0 )  {



// LOGGING


if ($reloadlock == 0) { $ipok = 1;}   

if ($ipok == 1) {


$datum =date("d.m.Y - H:i:s ");;
$agent = getenv("HTTP_USER_AGENT");
$from = $HTTP_REFERER;
$dns = @gethostbyaddr($ipad);

if ($from == '') {$from = '';}

$lange = strlen($ipad);

for ($i = 1; $i <= (16-$lange); $i++) {
   $leer= $leer." ";    
}

$lange =  strlen($agent);
if (strlen($agent) > 90 ) { $agent = substr($agent, 1,90); }

if ($lange < 91) {
for ($i = 1; $i <= (90-$lange); $i++) {
   $leer2= $leer2." ";    
}
}


$lange =  strlen($dns);
if (strlen($dns) > 46 ) { $dns = substr($dns, 1,46); }

if ($lange < 47) {
for ($i = 1; $i <= (46-$lange); $i++) {
   $leer3= $leer3." ";    
}
}


// make zeros
for ($i = 1; $i <= 10-strlen($count); $i++) {
    $null = $null.'0';
}



$zeile= "# $null$count - TIME: $datum IP: $ipad $leer DNS-Name: $dns $leer3 $agent $leer2 FROM: $from";


$file = fopen($name, "a");
if($file) {
        
       fputs($file, $zeile);
       fputs($file,  "\r\n");
       fclose($file);
}
}
}

// end

// OUTPUTS THE COUNTERVALUES

if ($showhtml == 1 ) {$hidecounter = 0;}

if ($hidecounter == 0 )  {


if ($showcounter == 1) { echo $count;}
if ($showdayvisits == 1) { echo ' -  '.$visitsaday.' today';}
if ($showyestvisit   == 1) { echo ' -  '.$visitsyester.' yesterday';}
if ($showlastvisit   == 1) { echo ' -  last visit '.substr($lastline,33,6);}
if ($showbrowsertyp   == 1) { echo ' -  Your DNS: '.@gethostbyaddr(getenv("REMOTE_ADDR"));}
if ($showip   == 1) { echo ' -  Your IP: '.$ipad;}
if ($showbrowsertyp   == 1) { echo ' -  Your Browsertyp: '.getenv("HTTP_USER_AGENT");}
if ($showuseronline   == 1) { echo ' -  '.$useronline.' user online';}


if ($showhtml == 1) {echo '<br><br>debilsoft IP-LOGGER Version '.$version;}

if ($showhtml == 1 )  { echo '</body></html>';}



}

?>