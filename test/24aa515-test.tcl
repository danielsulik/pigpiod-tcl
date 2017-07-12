#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./24aa515.tcl
source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "------------------------------"
puts "        I2C Test"
puts " 24AA515 I2C address 0x53"
puts "------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

set  ChipAddr   0x53
set  Addr2Write 0x0000
set  Addr2Read  0x0000
set  Data2Write "Microchip M24AA515 EEPROM memory test!"
puts "Writing: $Data2Write to $ChipAddr:$Addr2Write"

M24AA515Write $pi $ChipAddr $Addr2Write $Data2Write
puts "Reading memory ..."
set RData [M24AA515Read $pi $ChipAddr $Addr2Read 256]
DumpBinData $Addr2Read $RData 


#Do some read performance test
puts "Clearing memory"
puts "Estimating write performance ..."
set D ""
set N [expr [M24AA515MemSize] / 4]
for { set i 0 } { $i < $N} { incr i } {
    append D [binary format H8 FFFFFFFF]
}
set T [clock milliseconds]
M24AA515Write $pi $ChipAddr $Addr2Write $D
set dT [expr [clock milliseconds] - $T]
puts "Time: $dT ms: BW = [format %.3f [expr [string length $D] * 1000.0 / $dT]] B/s"

puts "Estimating read performance ..."
set Chunk     2048
set Addr2Read 0x0000
set Count     1
set T [clock milliseconds]
for { set i 0 } { $i < $Count } { incr i } {
    set RData [M24AA515Read $pi $ChipAddr $Addr2Read $Chunk]
    #DumpBinData $Addr2Read $RData
    set Addr2Read [expr $Addr2Read + $Chunk]
}
set dT [expr [clock milliseconds] - $T]
puts "Time: $dT ms: BW = [format %.3f [expr $Count * $Chunk * 1000.0 / $dT]] B/s"

pigpio_stop $pi