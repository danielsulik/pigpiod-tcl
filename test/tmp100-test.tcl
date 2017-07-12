#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./tmp100.tcl
source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "---------------------------------"
puts "       TMP100 I2C Test"
puts " Connect TMP100 chip to I2C-1"
puts " Set TMP100 A0 A1 to H (0x4E)"
puts " This code runs for few seconds."
puts "---------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

#
# call this proc every second
#
set Secs 0
proc ReadT { pi ChipAddr } {
    puts "Temperature: [TMP100ReadTemp $pi $ChipAddr] deg.C"
    if  { $::Secs < 6 } {
        after 1000 ReadT $pi $ChipAddr
        set ::Secs [expr $::Secs + 1]
    } else {
        set ::done 1
    }
}

set ChipAddr 0x4E
puts "Reading internal registers ..."
puts "CFG  reg: [TMP100ReadReg $pi $ChipAddr $::TMP100_CFG_REG_ADDR]"
puts "TMPL reg: [TMP100ReadReg $pi $ChipAddr $::TMP100_LOW_TEMP_ADDR]"
puts "TMPH reg: [TMP100ReadReg $pi $ChipAddr $::TMP100_HIGH_TEMP_ADDR]"

puts "Temperature: [TMP100ReadTemp $pi $ChipAddr] deg.C"

ReadT $pi $ChipAddr
vwait done
pigpio_stop $pi
