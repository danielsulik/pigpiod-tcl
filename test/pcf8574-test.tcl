#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./pcf8574.tcl
source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "-----------------------------------"
puts "       RTC PCF8574 Test"
puts " Connect PCF8574 I2C address 0x27"
puts "-----------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

set Secs   60
set LedIdx  0
set IOs   { FE FD FC FF }
proc Test { pi } {
    set ChipAddr   0x27
    set Data2Write [binary format H2 [lindex $::IOs $::LedIdx]]
    PCF8574Write $pi $ChipAddr $Data2Write
    set RData [PCF8574Read $pi $ChipAddr 1]
    binary scan $RData B* bv
    puts -nonewline "Input: $bv\r"; flush stdout
    set ::LedIdx [expr ($::LedIdx + 1) % [llength $::IOs]]
    if { $::Secs } {
        set ::Secs [expr $::Secs - 1]
        after 100  Test $pi 
    } else {
        set ::done 1
    }
}

Test $pi
vwait done
pigpio_stop $pi
