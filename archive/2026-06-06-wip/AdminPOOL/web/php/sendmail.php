
<?
function sendRegistrationKey($id,$name,$org,$email,$key) {

    $fixname=escapeshellcmd($name);
    $fixorg=escapeshellcmd($org);

    if(!$key) {
        $key=exec("/home/cbase/CB_NewStruct/CB_Admin/distrib/makeKey 3 0 \"$name\" \"$org\"");
    }

    $mimepart1 = "--cbregkey\nContent-Type: text/plain; charset=\"iso-8859-1\"\nContent-Transfer-Encoding: 7bit\n\n";
    $message = "Dear $name!\n\n";
    $message .= 'Thanks for registering and downloading ConceptBase.

Please save the attached text file (three lines containing the
registration key, your name and organization) into the file

     $CB_HOME/lib/system/reginfo.txt

where $CB_HOME is the installation directory of ConceptBase.
Please make sure that the file is stored as a plain text file
named "reginfo.txt".

This registration key is valid for 3 months. If you are interested
in using ConceptBase after this period, or if you encounter
any problems, do not hesitate to contact us.

Best regards,
  Christoph Quix
  ConceptBase Team

--
------------------
Lehrstuhl fuer Informatik 5
Prof. Dr. Matthias Jarke
c/o ConceptBase Team
RWTH Aachen, Ahornstr. 55
D-52056 Aachen, Germany
Fax: +49-241-80 22321
Email: cb@i5.informatik.rwth-aachen.de
WWW: http://www-i5.informatik.rwth-aachen.de/CBdoc/
';

    $headers = 'From: cb@i5.informatik.rwth-aachen.de
Content-Type: multipart/mixed; boundary="cbregkey";
Content-Transfer-Encoding: 7bit';


    $mimepart2 = "--cbregkey\nContent-Type: text/plain; name=\"reginfo.txt\"; charset=\"iso-8859-1\"\nContent-Transfer-Encoding: 7bit\nContent-Disposition: attachment\n\n";
    $attachment = "$key\n$org\n$name\n--cbregkey\n";

    $completemail = $mimepart1 . $message . $mimepart2 . $attachment;
    mail($email,"ConceptBase Registration Key",$completemail,$headers);

    return $key;

}

?>
