<?
   $regfile="/home/cb/Kunden/registrations.txt";
   $fd = fopen($regfile,"r");
   while (!feof ($fd)) {
       $line = fgets($fd, 4096);
       $str=split(";",$line); // id;name;org;addr;country;email;use;date;key
       if($id==$str[0] && strcasecmp($email,$str[5])) {
	  echo "Invalid Id/Email combination";
	  exit;
       }
   }
   fclose($fd);
?>

<html>
<head>
<title>Download ConceptBase</title>
<LINK REL="SHORTCUT ICON" HREF="/CBdoc/PIC/cbico.ico">
<link rel="stylesheet" type="text/css" href="/CBdoc/cb.css">
</head>
<body>

<h1>Download ConceptBase</h1>
<h2>1. Download Installation Instructions</h2>
To install ConceptBase, you have to read carefully the installation instructions in the installation guide
provided below. Installation can be simplified by using the CBinstall script
(Unix only) or the CBinstaller program (any platform, requires Java 1.4).

<ul>
<li><a href="/CBdoc/download6/InstallationGuide.txt">Installation Guide</a>
</ul>
<hr>

<h2>2. Download Archive</h2>
Select the archive which you want to download:

<ul>
<li> <b>cb71.tar.gz:</b><br>TAR.GZ Archive containing binaries for all platforms, documentation, examples
<form action="downloadfile.php/" METHOD="POST">
<input type=hidden name=filetype value=tgz>
<input type=hidden name=id value="<? echo $id; ?>">
<input type=hidden name=email value="<? echo $email; ?>">
<input type=submit name="Download" value="Download"></form>
<br><a href="/CBdoc/download6/CBinstall">CBinstall</a> script to install this archive on Solaris or Linux
</ul>
<hr>
<ul>
<li> <b>cb71.zip:</b><br>ZIP Archive containing binaries for all platforms, documentation, examples
<form action="downloadfile.php/" METHOD="POST">
<input type=hidden name=filetype value=zip>
<input type=hidden name=id value="<? echo $id; ?>">
<input type=hidden name=email value="<? echo $email; ?>">
<input type=submit name="Download" value="Download"></form>
<br><a href="/CBdoc/download6/CBinstaller.jar">CBinstaller.jar</a> (Installation program in Java, to install the ZIP archive on any platform, requires JDK 1.4)
</ul>
<br>
<hr>
<address>
&copy; ConceptBase Team 2007. Please do not mirror this document
or its parts without prior permission by us. Thank you! Last update: $Author: cbase $, $Date: 2008/05/29 09:43:23 $
</address>
</body>
</html>

