#!/bin/sh
# \
exec tclsh "$0" "$@"

package require pigpiod_tcl 1.0

set pi [pigpio_start 0 0]
if { $pi < 0 } {
   puts "ERROR: PIGPIO daemon (pigpiod) not running"
   exit -1
}

puts "pigpio version: [get_pigpio_version $pi]"
puts "HW version:     [get_hardware_revision $pi]"
puts "Tick:           [get_current_tick $pi]"

#GPIO test
set Port         4
set PADStrength  8
puts "Setting GPIO $Port as input"
set_mode         $pi $Port $::PI_INPUT
set_pull_up_down $pi $Port $::PI_PUD_UP
puts "GPIO $Port mode: [get_mode    $pi $Port]"
puts "GPIO $Port (PU): input [gpio_read  $pi 4]"
set_pull_up_down $pi $Port $::PI_PUD_DOWN
puts "GPIO $Port (PD): input [gpio_read  $pi 4]"

puts "Setting GPIO $Port as output"
set_mode    $pi $Port $::PI_OUTPUT
puts "GPIO $Port mode: [get_mode    $pi $Port]"
puts "GPIO 0-31 pad strength write: $PADStrength mA"
set_pad_strength $pi 0 $PADStrength
puts "GPIO 0-31 pad strength read: [get_pad_strength $pi 0 ] mA"

gpio_write  $pi 4 1
after 500
gpio_write  $pi 4 0

pigpio_stop $pi
