#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./pcf8583.tcl
source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "------------------------------"
puts "       RTC PCF8583 Test"
puts " PCF8583 I2C address 0x50"
puts "------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

set  ChipAddr   0x50
set  Addr2Write 0x10
set  Addr2Read  0x00
set  Data2Write "PCF8583 memory test! You should see this text in the memory dump."
puts "Writing: $Data2Write to $ChipAddr:$Addr2Write"
PCF8583RTCModeSet     $pi $ChipAddr
PCF8583RTCTimeDateSet $pi $ChipAddr [clock seconds]

#Write to RAM
PCF8583Write           $pi $ChipAddr $Addr2Write $Data2Write

#Read registers and RAM
set RData [PCF8583Read $pi $ChipAddr $Addr2Read 256]
DumpBinData $Addr2Read $RData 

pigpio_stop $pi