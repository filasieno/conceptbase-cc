#!/opt/info5/gnu/bin/perl -- -*-perl-*-
# Script to process the input of the registration at
#  http://www-i5.informatik.rwth-aachen.de/CBdoc/onlineReg.html
# 
#--------------------------
require "./libwww.pl";

print STDOUT &PrintHeader;

print STDOUT "<head><title>Thanks</title></head>\n";
print STDOUT "<body>";

print "The following data has been stored:<P>";


$tmpFile = "/tmp/tmpMailFile";
$logFile = "/home/www/cgi-bin/cb/regLog";

# Get the input
read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
# Split the name-value pairs
@pairs = split(/&/, $buffer);
foreach $pair (@pairs)
{

    ($name, $value) = split(/=/, $pair);

    # Un-Webify plus signs and %-encoding
    $value =~ tr/+/ /;
    $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;

    # Stop people from using subshells to execute commands
    # Not a big deal when using sendmail, but very important
    # when using UCB mail (aka mailx).
    # $value =~ s/~!/ ~!/g; \

    # Uncomment for debugging purposes
    print "$value<P>";

    $FORM{$name} = $value;
}

$error = 0;
foreach $key (keys(%FORM))
{
  if ($key ne "use") { 
    $entry = $FORM{$key};
    if (!$entry) {$error = 1}
  }
}

if ($error) {
  print "<P> ERROR: empty input field found";
}
else
{
  $now = `date`;

  open(TMPFILE,"> $tmpFile");
  print TMPFILE "\nDate: $now\n";
  print TMPFILE "$FORM{inst}\n";
  print TMPFILE "$FORM{name}\n";
  print TMPFILE "$FORM{strasse}\n";
  print TMPFILE "$FORM{stadt}\n";
  print TMPFILE "$FORM{land}\n";
  print TMPFILE "$FORM{email}\n";
  print TMPFILE "$FORM{use}\n\n";
  print TMPFILE "ConceptBase Version: 5.2\n";
  close(TMPFILE);

  open(TMPFILE,">> $logFile");
  print TMPFILE "\n\n\n===========================================\n";
  print TMPFILE "\nDate: $now\n";
  print TMPFILE "$FORM{inst}\n";
  print TMPFILE "$FORM{name}\n";
  print TMPFILE "$FORM{strasse}\n";
  print TMPFILE "$FORM{stadt}\n";
  print TMPFILE "$FORM{land}\n";
  print TMPFILE "$FORM{email}\n";
  print TMPFILE "$FORM{use}\n\n";
  print TMPFILE "ConceptBase Version: 5.2\n";
  close(TMPFILE);

  $command = " cat $tmpFile | mail cb\@i5.informatik.rwth-aachen.de";
  system($command);
#  unlink($tmpFile);

  print STDOUT "<P> Thanks for registering your ConceptBase installation";
  print STDOUT "<P> The key-file will be sent to  $FORM{email}";
}

print STDOUT "</body>\n";


