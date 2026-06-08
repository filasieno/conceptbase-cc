<html>
<head>
<title>ConceptBase Test Statistics</title>
<LINK REL="SHORTCUT ICON" HREF="/CBdoc/PIC/cbico.ico">
<link rel="stylesheet" type="text/css" href="/CBdoc/cb.css">
</head>

<body>
<?
   $logdir = "/home/cbase/crontabs/servertest";
   $variants = array( "i86pc", "linux", "linux64", "sun4", "windows", "mac" );
   $scriptDir="/home/cbase/CB_NewStruct/CB_Admin/utils/CB_TestClient/scripts/";
   $phpdir="/home/www/php4/htdocs/cb";

   function getSumOfFile($fname) {
        global $logdir, $variants;
        checkFile($logdir . $fname,$logdir);
        if(!file_exists($logdir . $fname))
            return 0;
        $fd = fopen($logdir . $fname,"r");
        if(!$fd)
            return 0;
        $sum=0;
        $error=false;
        while (!feof ($fd)) {
            $line = fgets($fd, 4096);
            $str=split(";",$line); // id;method;text;ok/error;time
            $sum+=$str[4];
            if($str[3]=="error")
               $error=true;
        }
        if(!$error)
            return $sum;
        else
            return -$sum;
   }

   function showFile($fnames) {
        global $logdir, $variants;
        printf("<h1>Detailed Statistics<h1>\n");
        printf("Colors:<br><table>\n");
        printf("<tr><td bgcolor=\"#FF0000\">error in this operation</td></tr>\n");
        printf("<tr><td bgcolor=\"#00FF00\">fastest platform for this operation</td></tr></table>\n");

        printf("<h3>Files:</h3><ul>\n");
        foreach($fnames as $fname) {
            printf("<li><a href=\"%s?resultFile=%s\">%s</a> \n",$PHP_SELF,str_replace("+","%2B",$fname),$fname);
            printf("(<a href=\"%s?resultFile=%s\">error.log</a>)</li>\n",$PHP_SELF,str_replace("+","%2B",str_replace("stat.","error.",$fname)));
        }
        printf("</ul>\n");
        $scriptName=substr($fnames[0],strpos($fnames[0],".")+1,strrpos($fnames[0],".")-strpos($fnames[0],".")-1);
        checkFile($logdir . $fnames[0],$logdir);
        $fd = fopen($logdir . $fnames[0],"r");
        $num=0;
        while (!feof ($fd)) {
            $line = fgets($fd, 4096);
            $str=split(";",$line); // id;method;text;ok/error;time
            $results[$num]["id"]=$str[0];
            $results[$num]["method"]=$str[1];
            $results[$num]["text"]=$str[2];
            $num++;
        }
        fclose($fd);
        $max=$num;
        $filenum=0;
        foreach($fnames as $fname) {
            checkFile($logdir . $fname,$logdir);
            $fd = fopen($logdir . $fname,"r");
            $num=0;
            while (!feof ($fd)) {
                $line = fgets($fd, 4096);
                $str=split(";",$line); // id;method;text;ok/error;time
                if($str[3]=="ok") {
                   $results[$num][$filenum]=$str[4];
                }
                else {
                   $results[$num][$filenum]=-$str[4];
                }
                $num++;
            }
            fclose($fd);
            $sum[$filenum]=0;
            $filenum++;
        }
        $maxfile=$filenum;
        printf("<table border=1>\n");
        printf("<tr><td>Num</td><td>Method</td><td>Arg</td>\n");
        for($i=0;$i<$maxfile;$i++) {
            printf("<td>%s</td>\n",$fnames[$i]);
        }
        printf("<td rowspan=10><img src=\"/~cbase/stat-images/%s.png\"></td>\n",$scriptName);
        printf("</tr>\n");
        for($i=0;$i<$max;$i++) {
            printf("<tr><td>%s</td><td>%s</td><td>%s</td>\n",$results[$i]["id"],$results[$i]["method"],$results[$i]["text"]);
            if($results[$i][0]>0)
                $min=(int) $results[$i][0];
            else
                $min=-((int) $results[$i][0]);
            for($j=1;$j<$maxfile;$j++) {
                if($results[$i][$j]>0 && $results[$i][$j]<$min)
                    $min=(int) $results[$i][$j];
            }
            for($j=0;$j<$maxfile;$j++) {
                if($results[$i][$j]==$min) {
                    printf("<td align=right bgcolor=\"#00FF00\">%d</td>\n",$results[$i][$j]);
                    $sum[$j]+=$results[$i][$j];
                }
                else if($results[$i][$j]<0) {
                    printf("<td align=right bgcolor=\"#FF0000\">%d</td>\n",-$results[$i][$j]);
                    $sum[$j]+=-$results[$i][$j];
                }
                else {
                    printf("<td align=right>%d</td>\n",$results[$i][$j]);
                    $sum[$j]+=$results[$i][$j];
                }
           }
           printf("</tr>\n");
        }
        printf("<tr><td>Sum</td><td></td><td></td>\n");
        for($j=0;$j<$maxfile;$j++) {
            printf("<td align=right>%d</td>\n",$sum[$j]);
        }
        printf("</tr>\n");
        printf("</table>");
   }

   function showSummary() {
       global $variants, $scriptDir;
       $handle = opendir($scriptDir);
       $i=0;
       while(($file=readdir($handle))!=false) {
          if(strstr($file,".cbs")) {
              $files[$i]=$file;
              $i++;
          }
       }
       sort($files);

       printf("Colors:<br><table>\n");
       printf("<tr><td bgcolor=\"#FF0000\">error in test</td></tr>\n");
       printf("<tr><td bgcolor=\"#FFAA33\">strange problem (much slower or faster than before)</td></tr>\n");
       printf("<tr><td bgcolor=\"#00FF00\">more than 10 percent faster than before</td></tr>\n");
       printf("<tr><td bgcolor=\"#FFFF00\">more than 10 percent slower than before</td></tr>\n");
       printf("<tr><td bgcolor=\"#8888FF\">test did not run (stat file does not exist)</td></tr></table>\n");

       printf("<form action=\"%s\" method=GET>",$PHP_SELF);
       printf("<input name=userDir type=text size=100>");
       printf("<input type=submit value=\"Add user dir\">\n");
       printf("(must be accessible by www user on manet)\n");
       printf("</form>\n");

       printf("<form action=\"%s\" method=GET>",$PHP_SELF);
       printf("<table border=1>\n");
       printf("<tr><td>Script</td>\n");
       for($j=0;$j<count($variants);$j++) {
          printf("<td><a href=\"%s?logFile=%s\">%s</a></td>\n",$PHP_SELF,$variants[$j],$variants[$j]);
       }
       if($userDir)
           printf("<td>User</td>\n");
       printf("<td rowspan=10><img src=\"/~cbase/stat-images/all.png\">\n");
       printf("</tr>\n");

       for($j=0;$j<$i;$j++) {
           $scriptName=substr($files[$j],0,-4);
           for($k=0;$k<count($variants);$k++) {
               $curvar=$variants[$k];
               if($k==0) {
                   if($j!=0)
                      printf("</tr>\n");
                   printf("<tr><td><a href=\"%s?scriptFile=%s\">%s</a></td>\n",$PHP_SELF,$scriptName,$scriptName);
               }
               $fname="/log/stat." . $scriptName . "." . $curvar;
               $res=getSumOfFile($fname);
               $oldfname="/old/stat." . $scriptName . "." . $curvar;
               $oldres=getSumOfFile($oldfname);
               if($res<0) {
                   printf("<td bgcolor=\"#FF0000\" align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"><br>\n",-$res,$fname);
                   printf("(%d) <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",$oldres,$oldfname);
                   $sum[$curvar]+=-$res;
               }
               else if($res==0) {
                   printf("<td bgcolor=\"#8888FF\" align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"><br>\n",-$res,$fname);
                   printf("(%d) <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",$oldres,$oldfname);
                   $sum[$curvar]+=-$res;
               }
               else if($res<$oldres*0.5 || $res>$oldres*1.5) {
                   printf("<td bgcolor=\"#FFAA33\" align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"><br>\n",$res,$fname);
                   printf("(%d) <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",$oldres,$oldfname);
                   $sum[$curvar]+=$res;
               }
               else if($res<$oldres*0.9) {
                   printf("<td bgcolor=\"#00FF00\" align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"><br>\n",$res,$fname);
                   printf("(%d) <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",$oldres,$oldfname);
                   $sum[$curvar]+=$res;
               }
               else if($res>$oldres*1.1) {
                   printf("<td bgcolor=\"#FFFF00\" align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"><br>\n",$res,$fname);
                   printf("(%d) <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",$oldres,$oldfname);
                   $sum[$curvar]+=$res;
               }
               else {
                   printf("<td align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"><br>\n",$res,$fname);
                   printf("(%d) <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",$oldres,$oldfname);
                   $sum[$curvar]+=$res;
               }

               if($userDir) {
                   $fname=$userDir . "/stat." . $scriptName;
                   $res=getSumOfFile($fname);
                   $oldres=0;
                   if($res<0) {
                       printf("<td bgcolor=\"#FF0000\" align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",-$res,$fname);
                       $sum["user"]+=-$res;
                   }
                   else if($res==0) {
                       printf("<td bgcolor=\"#8888FF\" align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",-$res,$fname);
                   }
                   else {
                       printf("<td align=right>%d <input type=checkbox name=\"showFile[]\" value=\"%s\"></td>\n",$res,$fname);
                       $sum["user"]+=$res;
                   }
               }
           }
       }
       printf("<tr><td><b>Sum</b></td>\n");
       for($j=0;$j<count($variants);$j++) {
          printf("<td align=right>%d</td>\n",$sum[$variants[$j]]);
       }
       if($userDir)
           printf("<td align=right>%d</td>\n",$sum["user"]);
       printf("</tr>\n");
       printf("</table>\n");

       printf("<input type=submit value=\"Compare files\">\n");
       printf("</form>\n");
   }

    function showScriptFile($scriptFile) {
        global $scriptDir;
        checkFile($scriptDir . $scriptFile . ".cbs",$scriptDir);
        $fd = fopen($scriptDir . $scriptFile . ".cbs","r");
        printf("<pre>\n");
        while (!feof ($fd)) {
            $line = fgets($fd, 4096);
            printf("%s",$line);
        }
        fclose($fd);
        printf("</pre>\n");
    }

    function showLogFile($logFile) {
        $logprefix="/home/cbase/crontabs/log/cron.weekly.test.";
        checkFile($logprefix . $logFile. ".log",$logprefix);
        $fd = fopen($logprefix . $logFile. ".log","r");
        printf("<pre>\n");
        while (!feof ($fd)) {
            $line = fgets($fd, 4096);
            printf("%s",$line);
        }
        fclose($fd);
        printf("</pre>\n");
    }

    function showResultFile($resultFile) {
        $prefix="/home/cbase/crontabs/servertest";
        checkFile($prefix . $resultFile,$prefix);
        $fd = fopen($prefix . $resultFile,"r");
        printf("<pre>\n");
        while (!feof ($fd)) {
            $line = fgets($fd, 4096);
            printf("%s",$line);
        }
        fclose($fd);
        printf("</pre>\n");
    }

    function checkFile($fname,$prefix) {
        if(realpath($fname)=="") {
            return;
        }
        if(strstr(realpath($fname),$prefix)!=realpath($fname)) {
            printf("Invalid file name: %s<br>\n",$fname);
            exit();
        }
    }

    function appendHistoryFiles() {
       global $variants, $scriptDir, $logdir, $phpdir;
       $handle = opendir($scriptDir);
       $i=0;
       while(($file=readdir($handle))!=false) {
          if(strstr($file,".cbs")) {
              $files[$i]=$file;
              $i++;
          }
       }
       sort($files);

       for($j=0;$j<$i;$j++) {
           $scriptName=substr($files[$j],0,-4);
           $historyname="/log/history/" . $scriptName;
           $line=date("d/m/y");
           for($k=0;$k<count($variants);$k++) {
               $curvar=$variants[$k];
               $fname="/log/stat." . $scriptName . "." . $curvar;
               $res=getSumOfFile($fname);
               if($res<0) {
                   $sum[$curvar]+=-$res;
                   $line=$line . " " . -$res;
               }
               else {
                   $sum[$curvar]+=$res;
                   $line=$line . " " . $res;
               }
           }
           checkFile($logdir . $historyname,$logdir);
           $fd = fopen($logdir . $historyname,"a+");
           if(!$fd)
               return 0;
           fputs($fd,$line);
           fputs($fd,"\n");
           fclose($fd);
           $cmd="/usr/bin/sed 's/SCRIPT/" . $scriptName . "/g' " . $phpdir . "/history.gnuplot | /opt/gnu/bin/gnuplot -";
           system($cmd);
       }
       $historyname="/log/history/all";
       $line=date("d/m/y");
       for($k=0;$k<count($variants);$k++) {
           $curvar=$variants[$k];
           $line=$line . " " . $sum[$curvar];
       }
       checkFile($logdir . $historyname,$logdir);
       $fd = fopen($logdir . $historyname,"a+");
       if(!$fd)
           return 0;
       fputs($fd,$line);
       fputs($fd,"\n");
       fclose($fd);
       $cmd="/usr/bin/sed 's/SCRIPT/all/g' " . $phpdir . "/history.gnuplot | /opt/gnu/bin/gnuplot -";
           echo $cmd;
       system($cmd);
    }

   if($argc>1 && $argv[1]=="history")
      appendHistoryFiles();
   else if($showFile)
      showFile($showFile);
   else if($scriptFile)
      showScriptFile($scriptFile);
   else if($logFile)
      showLogFile($logFile);
   else if($resultFile)
      showResultFile($resultFile);
   else
      showSummary();
?>
<hr>
<address>
&copy; ConceptBase Team 2007. Please do not mirror this document
or its parts without prior permission by us. Thank you! Last update: $Author: quix $, $Date: 2007/01/22 16:01:46 $
</address>
</body>
</html>

