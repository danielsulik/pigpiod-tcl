#!/usr/bin/tclsh
#exec tclsh "$0" "$@"

proc Usage {} {
    puts "USAGE\n[info script] <infile.c>"
    puts "    Find functions listed in replace.txt in <infile.c>" 
    puts "    and replace them with user's code functions of the same "
    puts "    name defined in corresponding c files."
    puts " Example replace.txt:"
    puts "    function1"
    puts "    function2"
    puts "    function3"
    puts "    Files function1.c, function2.c, function3.c defining"
    puts "    corresponding functions must exist."
}

set rfile "replace.txt"

if { [catch { open $rfile "r" } rf ] } {
    puts "ERROR: Could not open $rfile!"
    Usage
    exit -1
}
set funclist {}
while { [gets $rf line] >= 0 } {
    lappend funclist $line
}
close $rf

if { $::argc == 1 } {
    puts "Running [info script]"
    set infile [lindex $::argv 0]
    if { [catch { open $infile "r" } inf ] } {
        puts "ERROR: Could not open $infile!"
        Usage
    }
    if { [catch {open $infile\_tmp "w" } outf ] } {
        puts "ERROR: Could not open temporary file for writing!"
        Usage
    }

    set opbr 0
    set state "SEARCH"
    while { [gets $inf line] >= 0 } {
        if { $state == "SEARCH" } {
            foreach f $funclist {
                set re \[\\\ |\\t\]*_wrap_$f\[\\\ |\\t\]*\\(ClientData.*\\)
                if { [regexp "$re" $line] }  {
                     puts $line
                     set opbr [regexp -all {\{} $line ]
                     set state "IGNORE"
                     set funcfile $f.c
                     puts "INFO:Replacing function $f"
                     break
                }
            }
            if { $state != "IGNORE" } { puts $outf $line }
        } elseif { $state == "IGNORE" } {
            puts $line
            # brackets balancing
            set opbr [expr $opbr + [regexp -all {\{} $line ] - [regexp -all {\}} $line ]]
            if { $opbr == 0 } {
                set state "SEARCH"
                
                #copy new function to the file
                if { [catch {open $funcfile "r" } ff ] } {
                    puts "ERROR: Could not open $funcfile."
                    Usage
                    exit -1
                }
                while { [gets $ff line] >= 0 } {
                    puts $outf $line
                }
                close $ff
            }
        }
    }

    close $inf
    close $outf
    file copy   -force $infile\_tmp $infile
    file delete -force $infile\_tmp
} else {
    puts "ERROR: No arguments passed!"
    Usage
}