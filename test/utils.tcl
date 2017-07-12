#####################################
# utils.tcl fo examples
#####################################
proc String2Hex { txt } {
    binary scan [binary format a* "$txt"] H* l
    return $l
}

proc DumpBinData { Addr bindata } {
    set l   0
    set rem 0
    set al ""
    set bd [ split $bindata {} ]
    foreach n $bd { 
        set rem [expr $l % 16]
        if { 0 == $rem } {
            puts -nonewline "[format %08X $Addr]: " 
        }
        binary scan $n H2 c
        set d [expr 0x$c]
        puts -nonewline "[format %02X $d] "
        if { ($d >= 0x20) && ($d < 0x80) } {
            append al $n
        } else {
            append al "."
        }
        incr l
        set rem [expr $l % 16]
        if { 0 == $rem } {
            puts " $al"
            set Addr [expr $Addr + 16]
            set al ""
        }
    }
    #dump the rest if any
    if { 0 != $rem } {
        set n [expr 16 - $rem]
        while {$n} {
           puts -nonewline "   "
           set n [expr $n - 1]
        }
        puts " $al"
    }
    puts ""
}

##########################################
# GPIO callbac implementation via pipe 
##########################################
array set _gpioCallbackArr {}
proc gpioCallbackInit { pi } {
    #Remove any garbage left in /dev/pigpiod* from previous run.
    #/dev/pigpiod* might left-overs if previous run was killed 
    # or did not finsih for some reason
    catch {foreach f [glob /dev/pigpio*] {
        if { [ regexp {/dev/pigpio[0-7]} $f l ] } {
            exec sudo rm -f $f
        }
    }}

    #Callback proc called on each entry in pipe
    proc gpioCallback { f } {
        global _gpioCallbackArr 
        
        #read pipe
        set d [read $f]
        binary scan [string range $d 0  1] su seqno
        binary scan [string range $d 2  3] su flags
        binary scan [string range $d 4  7] iu tick
        binary scan [string range $d 8 11] iu level

        #Run users procs
        #puts "sq:$seqno,fl:$flags,t:$tick,l:[format %08X $level]"
        foreach { a v } [array get _gpioCallbackArr] {
            if { [expr [lindex $v 2] << [lindex $v 1]] == [expr $level & (1 << [lindex $v 1])] } {
                # eval callback pi pin level tick
                eval "[lindex $v 3] [lindex $v 0] [lindex $v 1] [lindex $v 2] $tick"; #Call user registered proc
            }
        }
    }

    global _gpioCallbackArr 
    array set _gpioCallbackArr {}
    #Get pipe handle
    set nh [notify_open $pi]
    if { $nh < 0} {
        puts "ERROR: [pigpio_error $rc]"
        return -1
    }
    if {  [ catch {open /dev/pigpio$nh r} npipe] } {
        puts "ERROR: $npipe"
        return -1
    }
    fconfigure $npipe -blocking 0 -translation binary
    fileevent  $npipe readable [list gpioCallback $npipe]
    return [list $nh $npipe]
}

proc gpioCallbackRegister { pi handle pin level callback } {
    if { ($pin < 0) || ($pin > 31)} { 
       puts "ERROR: pi parameter 3 out of range (0-31)!"
       return -1 
    }
    if { !(($level == 0) || ($level == 1)) } { 
       puts "ERROR: level parameter 4 out of range (0-11)!"
       return -1 
    }

    global _gpioCallbackArr
    set _gpioCallbackArr($pin) [list $pi $pin $level $callback]
    set cbpins 0
    foreach { a v } [array get _gpioCallbackArr] {
        if { [lindex $v 3 ] == "" } {
            set cbpins [expr $cbpins & ~(1 << [lindex $v 1]) ]
        } else {
            set cbpins [expr $cbpins | (1 << [lindex $v 1]) ]
        }
    }
    #if { $callback == "" } {
    #    puts "Unregistered: g:$pin"
    #} else {
    #    puts "Registered:$callback g:$pin l:$level CBPINS:[format %02X $cbpins]"
    #}
    set nh [lindex $handle 0]
    set rc [notify_begin $pi $nh $cbpins]
    if { $rc < 0} {
        puts "ERROR:[lindex [info level 0] 0]: [pigpio_error $rc]"
        return -1
    }
    return 0
}

proc gpioCallbackRemove { pi handle pin } {
    global _gpioCallbackArr
    #Call gpioCallbackRegister with empty proc to clear pin
    gpioCallbackRegister $pi $handle $pin 0 ""
    #remove callback completelly
    unset _gpioCallbackArr($pin)
}

proc gpioCallbackStop { pi handle } {
    set nh  [lindex $handle 0]
    global _gpioCallbackArr
    
    #remove all
    array set _gpioCallbackArr {}
    #close notification
    notify_close $pi $nh
    #close pipe
    close [lindex $handle 1]
}

proc IPValidate { ip } {
    if { $ip == "localhost" } {return 1}
    return [regexp {^(?:(?:[2][5][0-5]|[1]?[1-9]{1,2}|0)(?:\.|$)){4}} $ip match]
}

proc TCPPortValidate { port } {
    if { $port > 1023 && $port < 65536 } { return 1 }
    return 0
}

###############################################
# Connect to daemon runing on ip port
# Expects ip and port number passed in argv
###############################################
proc Connect2Pigpiod { argc argv } {
    set ip   0
    set port 0
    if { $argc } {
        foreach { opt value } $argv {
            if { $value == "" } { 
                puts "ERROR: Missing $opt parameter!"
                return -1 
            }
            switch -exact $opt {
                -i {
                    if { ![IPValidate $value] } {
                        puts "ERROR: invalid IP $value !"
                        return -1
                    }
                    set ip $value
                }

                -p {
                    if { ![TCPPortValidate $value] } {
                        puts "ERROR: invalid port $value ! Allowed range (1024 - 65535)."
                        return -1
                    }
                    set port $value
                }

                default {
                    puts "ERROR: unknown option $opt"
                    return -1
                }
            }
        }
    }

    #Connect to pigpiod daemon
    set pi [pigpio_start $ip $port]
    if { $pi < 0 } {
       puts "ERROR: PIGPIO daemon (pigpiod) not running at $ip:$port"
       return -1
    }
    
    return $pi
}
