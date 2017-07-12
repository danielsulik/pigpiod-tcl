#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./25aa640.tcl
source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "----------------------------------"
puts "         SPI Test"
puts " Connect 25AA640 chip to spi0.0"
puts "----------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

set  Data2Write  "Microchip M25AA640 flash memory test!"
set  Addr2Write  0x33
set  Addr2Read   0x00
set  ChipAddr    0

puts "M25AA640 Status: [M25AA640StatusRead $pi $ChipAddr]"
puts "Writing: $Data2Write to $ChipAddr:$Addr2Write"
M25AA640Write $pi $ChipAddr $Addr2Write $Data2Write

#Read 256 bytes from memory from addr Addr2Write
set RData [ M25AA640Read $pi $ChipAddr $Addr2Read 512 ]
DumpBinData $Addr2Read $RData

#Do some read performance test
puts "Estimating read performance ..."
set Chunk     512
set Addr2Read 0x0000
set Count     1000
set T [clock milliseconds]
for { set i 0 } { $i < $Count } { incr i } {
    set RData [M25AA640Read $pi $ChipAddr $Addr2Read $Chunk]
    #DumpBinData $Addr2Read $RData
    set Addr2Read [expr $Addr2Read + $Chunk]
}
set dT [expr [clock milliseconds] - $T]
puts "Time: $dT ms: BW = [format %.3f [expr $Count * $Chunk * 1000.0 / $dT]] B/s"

pigpio_stop $pi