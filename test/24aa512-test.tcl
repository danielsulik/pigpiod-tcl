#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

set pi [pigpio_start 0 0]
if { $pi < 0 } {
   puts "ERROR: PIGPIO daemon (pigpiod) not running"
   exit -1
}

puts "------------------------------"
puts "        I2C Test"
puts " Connect 24AA512 A0,A1,A2 to H"
puts " I2C address 0x57"
puts "------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"

source ./24aa512.tcl
source ./utils.tcl

set  ChipAddr   0x57
set  Addr2Write 0x0033
set  Addr2Read  0x0000
set  Data2Write "Microchip M24AA512 EEPROM memory test!"
puts "Writing: $Data2Write to $ChipAddr:$Addr2Write"

M24AA512Write $pi $ChipAddr $Addr2Write $Data2Write
set RData [M24AA512Read $pi $ChipAddr $Addr2Read 256]
DumpBinData $Addr2Read $RData

#Do some read performance test
puts "Estimating read performance ..."
set Chunk     512
set Addr2Read 0x0000
set Count     10
set T [clock milliseconds]
for { set i 0 } { $i < $Count } { incr i } {
    set RData [M24AA512Read $pi $ChipAddr $Addr2Read $Chunk]
    set Addr2Read [expr $Addr2Read + $Chunk]
}
set dT [expr [clock milliseconds] - $T]
puts "Time: $dT ms: BW = [format %.3f [expr $Count * $Chunk * 1000.0 / $dT]] B/s"

pigpio_stop $pi