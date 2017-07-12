#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

source ./hmc5883l.tcl
source ./utils.tcl

set pi [Connect2Pigpiod $argc $argv]
if  {$pi < 0 } {
    exit -1
}

puts "---------------------------------"
puts "       MagM I2C Test"
puts " Connect MagM chip to I2C-1"
puts "---------------------------------"
puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "IF version:     [pigpiod_if_version]"
puts "Tick:           [get_current_tick $pi] us"

set Secs 0
set gain 0


proc ReadMag { pi  gain } {
    #
    # Read mag field
    #
    set x [MagMReadMagX $pi ]
    set y [MagMReadMagY $pi ]
    set z [MagMReadMagZ $pi ]
    puts "X:     $x: [MagMCount2Gauss $gain $x] Gauss"
    puts "Y:     $y: [MagMCount2Gauss $gain $y] Gauss"
    puts "Z:     $z: [MagMCount2Gauss $gain $z] Gauss"
    if  { $::Secs < 120 } {
        after 1000 ReadMag $pi  $gain
        set ::Secs [expr $::Secs + 1]
    } else {
        set ::done 1
    }
}

#
# Init magentometer
#
MagMInit $pi

#
# Read ID
#
binary scan [MagMReadID $pi ] H* n
puts "MagM ID:     0x$n"

#
# Read status
#
binary scan [MagMReadStatusReg $pi ] H* n
puts "MagM status: 0x$n"


MagMCalibration $pi  0
MagMCalibration $pi  1
MagMCalibration $pi  2
MagMCalibration $pi  3
MagMCalibration $pi  4
MagMCalibration $pi  5
MagMCalibration $pi  6
MagMCalibration $pi  7

#
# Set config A avg 2^3, rate 15 Hz, ms 0
# Set config B gain 0
# Set Mode continuous 
#
MagMWriteConfigRegA   $pi  3 4 0
MagMWriteConfigRegB   $pi  $gain
MagMWriteModeReg      $pi  0
#
# Read config
#
binary scan [MagMReadConfigRegA $pi ] H* n
puts "MagM CFGA:   0x$n"
binary scan [MagMReadConfigRegB $pi ] H* n
puts "MagM CFGB:   0x$n"

#
# Read Mode
#
binary scan [MagMReadModeReg $pi ] H* n
puts "MagM Mode:   0x$n"

ReadMag $pi  $gain
vwait done
pigpio_stop $pi
