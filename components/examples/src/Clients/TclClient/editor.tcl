#!../bin/cbwish -f
wm iconify .
set cb [cb_ConnectDlg ""]
if { $cb == ""} exit
frame .fButtons 
toplevel .fOut
text .text -yscrollcommand ".scroll set"
text .fOut.text -yscrollcommand ".fOut.scroll set"
scrollbar .scroll -command ".text yview"
scrollbar .fOut.scroll -command ".fOut.text yview"
button .fButtons.bTell -text "tell" -command tell -width 12
button .fButtons.bAsk -text "ask" -command ask -width 12
button .fButtons.bQuit -text "quit" -command "$cb disconnect; exit" -width 12
pack .fButtons  -fill x
pack .fButtons.bTell .fButtons.bAsk .fButtons.bQuit -side left -pady 10 -padx 5
pack .scroll .text .fOut.scroll .fOut.text -side left -fill y
wm title . "ConceptBase Editor 47"
wm title .fOut "ConceptBase Editor 47: answers"
wm deiconify .

proc tell { } {
    global cb
    if [$cb tell [.text get 1.0 end]] {
	.fOut.text insert end "[.text get 1.0  end]\n"
    } else { .fOut.text insert end [$cb lastErrormessage] }   
    .fOut.text yview -pickplace end
}

proc ask { } {
    global cb
    if [$cb ask answer [.text get 1.0 end] TELOS] {
	.fOut.text insert end "$answer\n"
	puts $answer
    } else { .fOut.text insert end [$cb lastErrormessage] }
    .fOut.text yview -pickplace end
}

proc load { obj } {
    global cb
    if { $obj != "" } then {
	if [$cb ask answer "get_object\[$obj/objname\]" TELOS] then { 
	    .text delete 1.0 end
	    .text insert end $answer
	} else { .fOut.text insert end [$cb lastErrormessage] }
    }
}
bind .text <Double-ButtonPress-1> {load [.text get "@%x,%y wordstart" "@%x,%y wordend"]}
