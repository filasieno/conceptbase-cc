<?
  $regfile="/home/cb/Kunden/registrations.txt";
  $fd = fopen($regfile,"r");
  while (!feof ($fd)) {
      $line = fgets($fd, 4096);
      $str=split(";",$line); // id;name;org;addr;country;email;use;date;key
      if($id==$str[0] && strcasecmp($email,$str[5]) ) {
          echo "Invalid Id/Email combination";
          exit;
      }
  }
  fclose($fd);

  if($filetype=="tgz")
     $filename="cb71.tar.gz";
  else
     $filename="cb71.zip";

  $filepath="/home/cbase/CB_NewStruct/CB_Admin/distrib";
  $fullname="$filepath/$filename";

  $size = filesize($fullname);

  header("Content-Type: application/octet-stream");
  //header("Content-Type: application/force-download");
  header("Content-Length: $size");

  // IE5.5 just downloads download.php if we don't do this...
  // for now I only check on 5.5 but what if 6.0 has the same problem??

  if(preg_match("/MSIE 5.5/", $HTTP_USER_AGENT)) {
    header("Content-Disposition: filename=$filename");
  }
  else {
    header("Content-Disposition: attachment; filename=$filename");
  }
  header("Content-Transfer-Encoding: binary");

  $fh = fopen($fullname, "r");
  fpassthru($fh);
  fclose($fh);

  exit;

?>

