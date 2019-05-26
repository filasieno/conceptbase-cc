
<?
   include("sendmail.php");

   $regfile="/home/cb/Kunden/registrations.txt";
   $fd = fopen($regfile,"r");
   while (!feof ($fd)) {
        $line = fgets($fd, 4096);
        $str=split(";",$line); // id;name;org;addr;country;email;use;date;key
	if($id==$str[0]) {
	    sendRegistrationKey($str[0],$str[1],$str[2],$str[5],rtrim($str[8]));
	    ?>
	    <html>
            <head>
            <title>Registration Key has been re-sent</title>
	    <body background="/CBdoc/cb-bg.gif">
	    <blockquote>
	    <h2>Registration Key has been re-sent</h2>
	    Registration key has been re-sent to <? echo $str[5]; ?>.
	    <hr>
	    If you do not receive the registration key, please check the email address
	    you have specified or contact the <a href="mailto:cb@i5.informatik.rwth-aachen.de">ConceptBase Team</a>.
	    <hr>
            <address>
            <A HREF="http://www-i5.informatik.rwth-aachen.de/CBdoc/">ConceptBase</A> Team
            </address>
            </BLOCKQUOTE>
	    </body>
	    </html>
            <?
	    exit;
	}
   }
   fclose($fd);

   ?>
   <html>
   <head>
   <title>Error</title>
   <LINK REL="SHORTCUT ICON" HREF="/CBdoc/PIC/cbico.ico">
   <link rel="stylesheet" type="text/css" href="/CBdoc/cb.css">
   <body>
   <h2>Error</h2>
   Registration entry not found.
   Please register again or contact
   the <a href="mailto:cb@i5.informatik.rwth-aachen.de">ConceptBase Team</a>.
   <hr>
    <address>
    &copy; ConceptBase Team 2007. Please do not mirror this document
    or its parts without prior permission by us. Thank you! Last update: $Author: quix $, $Date: 2007/01/22 16:01:46 $
    </address>
   </body>
   </html>

