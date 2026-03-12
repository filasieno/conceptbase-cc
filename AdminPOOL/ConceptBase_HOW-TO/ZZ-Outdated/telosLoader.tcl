#!/bin/sh
####################################################################
# (C) 2000 Kees Leune <C.J.Leune@kub.nl>
####################################################################
#
# This is a concept base loader.
# usage:
#     telosLoader hostname portname filename1 filename2 ...
# eg.
#     telosLoader mycbserver 4001 generaldefs.list otherdefs.list \
#     application.list
#
# format of filenames
# /home/cbuser/file1.sml
# /home/cbuser/file2.sml
#
# lines BEGINNING with ; or # are considered to be comments and will be
# ignored. .sml is default file extension for telos files
#
# make sure CBwish is in your search path!
####################################################################\
exec $CB_HOME/bin/CBwish -f "$0" "$@"

if {[llength $argv] < 3} {
    puts "[info script] <hostname> <portname> <filename1> ..."
    exit;
}

set host [lindex $argv 0]
set port [lindex $argv 1]
set files [lrange $argv 2 end]

cb_talk server
set x [server connect $port $host telosLoader]
if {$x == 0} {
    puts "Connection to $host:$port failed"
    exit
}

puts "Connected to concept base server on $host:$port"

foreach file $files {
    set f [open $file]
    while {![eof $f]} {
        gets $f line
	if {[string trim $line] != ""} {
	    # ignore comment
	    if {[regexp {^[#;]} $line]} continue;
	    
	    # remove .sml extensions
	    regsub {(.*)\.sml} $line {\1} line

	    # what time is it
	    set begintime [clock seconds]
	    puts -nonewline "Loading file $line.sml..."
	    flush stdout
	    set x [server send_message TELL_MODEL \[\"$line\"\]]

	    if {$x > 0} { 
	        # everhting went ok. make user happy
		set endtime [clock seconds]
		puts "Success ([expr $endtime - $begintime] sec.)"
	    } else {
	        # problem. make user unhappy
	        puts "Error:\n[server lastErrormessage]"
		server disconnect
		close $f
		exit
	    }
	}
    }
    close $f
}

# bye
server disconnect
puts "Disconnected from server"
exit

