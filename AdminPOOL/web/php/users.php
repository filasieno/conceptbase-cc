<html>
<head>
<title>Registered ConceptBase Users</title>
<LINK REL="SHORTCUT ICON" HREF="/CBdoc/PIC/cbico.ico">
<link rel="stylesheet" type="text/css" href="/CBdoc/cb.css">
</head>
<body>
<table border=1>
<tr><b>
<td>ID</td>
<td>Name</td>
<td>Organization</td>
<td>Address</td>
<td>Country</td>
<td>Email</td>
<td>Intended Use</td>
<td>Date</td>
<td>Registration Key</td>
</tr>
<?
     $regfile="/home/cb/Kunden/registrations.txt";
     $fd = fopen($regfile,"r");
     $i=0;
     while (!feof ($fd)) {
        $i++;
        $line = fgets($fd, 4096);
	$str=split(";",$line); // id;name;org;addr;country;email;use;date;key
	?>
	<tr>
	<td><? echo $str[0] ?></td>
	<td><? echo $str[1] ?></td>
	<td><? echo $str[2] ?></td>
	<td><? echo $str[3] ?></td>
	<td><? echo $str[4] ?></td>
	<td><? echo $str[5] ?></td>
	<td><? echo $str[6] ?></td>
	<td><? echo $str[7] ?></td>
	<td><? echo $str[8] ?></td>
        </tr>
        <?
     } // while
     fclose ($fd);
?>
</table>
<h2><? echo $i ; ?> users </h2>
</body>
